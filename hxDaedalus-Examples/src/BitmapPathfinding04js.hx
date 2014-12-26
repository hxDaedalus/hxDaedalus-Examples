package;

import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.factories.BitmapObject;
import hxDaedalus.factories.RectMesh;
import hxDaedalus.view.SimpleView;
import hxDaedalus.graphics.js.ImageLoader;
import hxDaedalus.canvas.BasicCanvas;
import hxDaedalus.graphics.js.CanvasPixelMatrix;
import haxe.ds.StringMap;
import js.html.ImageElement;
import js.Browser;
import js.html.Event;
import js.html.MouseEvent;

typedef UpDownEvent = Event;

class BitmapPathfinding04js
{
    var mesh : Mesh;
    var view : SimpleView;
    var object : Object;
	var entityAI: EntityAI;
	var pathfinder:PathFinder;
	var path: Array<Float>;
	var pathSampler: LinearPathSampler;
	var newPath:Bool = false;
	var basicCanvas: BasicCanvas; 
	var imageLoader: ImageLoader;
	var mx: Float;
	var my: Float;
	
	public static function main(): Void {
		new BitmapPathfinding04js();
	}
	
	public function new(){
		// build a rectangular 2 polygons mesh
		mesh = RectMesh.buildRectangle( 1024, 780 );
		
		imageLoader = new ImageLoader([ 'https://raw.githubusercontent.com/Justinfront/hxDaedalus-Examples/master/hxDaedalus-Examples/web//assets/galapagosBW.png', 'https://raw.githubusercontent.com/Justinfront/hxDaedalus-Examples/master/hxDaedalus-Examples/web/assets/galapagosColor.png' ], onLoaded );
	}
	
	private function onLoaded():Void {
		var images: StringMap<ImageElement> = imageLoader.images;
      	basicCanvas = new BasicCanvas();
        view = new SimpleView(basicCanvas);
		var img = images.get('galapagosBW.png');
		var surface = basicCanvas.surface;
		var w: Int = img.width;
		var h: Int = img.height;
		surface.drawImage( img, 0, 0, w, h );
		var pixels = CanvasPixelMatrix.createCanvasPixelMatrixFromContext( surface, w, h );
		trace( 'pixels.lookup ' + pixels.lookup );
		
		surface.clearRect( 0, 0, w, h );
		img = images.get("galapagosColor.png");
		surface.drawImage( img, 0, 0, w, h );
		object = BitmapObject.buildFromBmpData( pixels, 1.8 );
		object.x = 0;
		object.y = 0;
		var s = haxe.Timer.stamp();
		mesh.insertObject( object );
		
		// we need an entity
		entityAI = new EntityAI();
		
		// set radius size for your entity
		entityAI.radius = 4;
		
		// set a position
		entityAI.x = 50;
		entityAI.y = 50;
		
		// now configure the pathfinder
		pathfinder = new PathFinder();
		pathfinder.entity = entityAI; // set the entity
		pathfinder.mesh = mesh; // set the mesh
		
		// we need a vector to store the path
		path = new Array<Float>();
		
		// then configure the path sampler
		pathSampler = new LinearPathSampler();
		pathSampler.entity = entityAI;
		pathSampler.samplingDistance = 10;
		pathSampler.path = path;
		
		var bc = basicCanvas.canvas;
    	// click/drag
    	bc.onmousedown = onMouseDown;
    	bc.onmouseup = onMouseUp;
    	bc.onmousemove = onMouseMove;
		// animate
    	basicCanvas.onEnterFrame = onEnterFrame;
		
		// keypress
		//js.Browser.document.onkeydown = onKeyDown;
		
	}
	
    function onMouseMove( e: Event ): Void {
        var p: MouseEvent = cast e;
        mx = p.clientX;
        my = p.clientY;
    }
	
    function onMouseUp( event: UpDownEvent ): Void {
		newPath = false;
    }
    
    function onMouseDown( event: UpDownEvent ): Void {
        newPath = true;
    }
    
    function onEnterFrame( #if flash	event: Event #end ): Void {
		if (newPath) {
			view.drawMesh(mesh, false);
				
            // find path !
            pathfinder.findPath( mx, my, path );
            
			// show path on screen
            view.drawPath( path );
            
			// reset the path sampler to manage new generated path
            pathSampler.reset();
        }
        
        // animate !
        if ( pathSampler.hasNext ) {
            // move entity
            pathSampler.next();            
        }
		
		// show entity position on screen
		view.drawEntity(entityAI);
    }
    
    function onKeyDown( event:js.html.KeyboardEvent ): Void {
		if (event.keyCode == 32) { // SPACE
			//
			event.preventDefault();
		} else if (event.keyCode == 13) { // ENTER
			//
			event.preventDefault();
		}
    }
	
}