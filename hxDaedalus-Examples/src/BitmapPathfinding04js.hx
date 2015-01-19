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
import hxDaedalus.graphics.Pixels;
import haxe.ds.StringMap;
import js.html.ImageElement;
import js.Browser;
import js.html.Event;
import js.html.MouseEvent;
import js.html.CanvasRenderingContext2D;

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
	var img: ImageElement;
	var w: Int;
	var h: Int;
	var surface: CanvasRenderingContext2D;
	 
	public static function main(): Void {
		new BitmapPathfinding04js();
	}
	
	public function new(){
		// build a rectangular 2 polygons mesh
		mesh = RectMesh.buildRectangle( 1024, 780 );//'assets/galapagosBW.png', 
		imageLoader = new ImageLoader([ 'assets/galapagosColor.png' ], onLoaded );
	}
	
	private function onLoaded():Void {
		var images: StringMap<ImageElement> = imageLoader.images;
      	basicCanvas = new BasicCanvas();
        view = new SimpleView(basicCanvas);		
		
		// Replaced this image 'assets/galapagosBW.png'
		// with encoded gif at bottom of class    galapagosBW66encoded
		// due to limitations when trying to display example using github raw.galapagosBW66encoded
		img = js.Browser.document.createImageElement();
		var imgStyle = img.style;
		imgStyle.left = '0px';
		imgStyle.top = '0px';
		imgStyle.paddingLeft = "0px";
		imgStyle.paddingTop = "0px";
		imgStyle.position = "absolute";
		img.src = galapagosBW66encoded;
		
		surface = basicCanvas.surface;
		w = img.width;
		h = img.height;
		surface.drawImage( img, 0, 0, w, h );
		
		var pixels =  Pixels.fromImageData(surface.getImageData(0, 0, w, h));
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
			
			surface.clearRect( 0, 0, w, h );
			surface.drawImage( img, 0, 0, w, h );
			
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
	private var galapagosBW66encoded: String = "data:image/gif;base64,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";

}