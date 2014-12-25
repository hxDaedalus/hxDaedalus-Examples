
import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.data.ConstraintSegment;
import hxDaedalus.data.Edge;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.data.math.Point2D;
import hxDaedalus.data.math.RandGenerator;
import hxDaedalus.data.Vertex;
import hxDaedalus.factories.RectMesh;
import hxDaedalus.view.SimpleView;

#if flash
	import flash.Lib;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
#elseif js
	import hxDaedalus.canvas.BasicCanvas;
	import js.Browser;
	import js.html.Event;
	import js.html.MouseEvent;
#end

#if flash
	typedef UpDownEvent = MouseEvent;
#elseif js
	typedef UpDownEvent = Event;
#end
	
class GridMaze05 
#if flash 	extends Sprite #end
{
    
    var mesh : Mesh;
    var view : SimpleView;
	
	#if flash
		var entityView:SimpleView;
		var meshView:SimpleView;
    #end
	
    var entityAI : EntityAI;
    var pathfinder : PathFinder;
    var path : Array<Float>;
    var pathSampler : LinearPathSampler;
    
    var newPath:Bool = false;
	
	var rows:Int = 15;
	var cols:Int = 15;
	
	#if js
    	var mx: Float;
    	var my: Float;
		var basicCanvas: BasicCanvas;
	#end
    
    public static function main():Void {
        #if flash		Lib.current.addChild(new GridMaze05());
		#elseif js		new GridMaze05();
		#end
    }
    
    public function new() {
        #if flash super(); #end
        
		// build a rectangular 2 polygons mesh of 600x600
        mesh = RectMesh.buildRectangle(600, 600);
        
		// create a viewport
		#if flash
			meshView = new SimpleView(graphics);
			var viewSprite = new Sprite();
        	view = new SimpleView(viewSprite.graphics);
        	addChild(viewSprite);
			var entitySprite = new Sprite();
			entityView = new SimpleView(entitySprite.graphics);
			addChild(entitySprite);
        
		#elseif js
      		basicCanvas = new BasicCanvas();
        	view = new SimpleView(basicCanvas);	
		#end
		
		GridMaze.generate(600, 600, cols, rows);
		mesh.insertObject(GridMaze.object);
		#if flash
			var v = meshView;
			var rad = GridMaze.tileWidth * .3;
		#elseif js
			var v = view;
			var rad = 10;
		#end
		
		v.constraintsWidth = 4;
		#if js	v.edgesWidth = .5; #end
        v.drawMesh(mesh);
		
        // we need an entity
        entityAI = new EntityAI();
        // set radius as size for your entity
        entityAI.radius = rad;
        // set a position
        entityAI.x = GridMaze.tileWidth / 2;
        entityAI.y = GridMaze.tileHeight / 2;
        
        // show entity on screen
        view.drawEntity(entityAI);
        
        // now configure the pathfinder
        pathfinder = new PathFinder();
        pathfinder.entity = entityAI;  // set the entity  
        pathfinder.mesh = mesh;  // set the mesh  
        
        // we need a vector to store the path
        path = new Array<Float>();
        
        // then configure the path sampler
        pathSampler = new LinearPathSampler();
        pathSampler.entity = entityAI;
        pathSampler.samplingDistance = 12;
        pathSampler.path = path;
        
		#if flash
			var s = Lib.current.stage;
        	// click/drag
        	s.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        	s.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        	// animate
        	s.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        	// key presses
        	s.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		#elseif js
			var bc = basicCanvas.canvas;
        	// click/drag
        	bc.onmousedown = onMouseDown;
        	bc.onmouseup = onMouseUp;
        	bc.onmousemove = onMouseMove;
			// animate
        	basicCanvas.onEnterFrame = onEnterFrame;
			
			// keypress
			js.Browser.document.onkeydown = onKeyDown;
		#end
	}
    
	#if js
    function onMouseMove( e: Event ): Void {
        var p: MouseEvent = cast e;
        mx = p.clientX;
        my = p.clientY;
    }
	#end
	
    function onMouseUp( event: UpDownEvent ): Void {
		newPath = false;
    }
    
    function onMouseDown( event: UpDownEvent ): Void {
        newPath = true;
    }
    
    function onEnterFrame( #if flash	event: Event #end ): Void {
		if (newPath) {
			#if flash	
				view.graphics.clear();				
				var mx = stage.mouseX;
				var my = stage.mouseY;
			#elseif js
				view.drawMesh(mesh, true);
			#end
				
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
		#if flash
			entityView.drawEntity(entityAI, true);
		#elseif js
			view.drawEntity(entityAI);
		#end
    }
    
	#if flash
    function onKeyDown( event:KeyboardEvent ): Void {
        if( event.keyCode == 27 ) {  // ESC
		#if flash
			flash.system.System.exit(1);
		#elseif sys
			Sys.exit(1);
		#end
        } else if (event.keyCode == 32) { // SPACE
			reset(true);
		} else if (event.keyCode == 13) { // ENTER
			reset(false);
		}
    }
	#elseif js
    function onKeyDown( event:js.html.KeyboardEvent ): Void {
		if (event.keyCode == 32) { // SPACE
			reset(true);
			event.preventDefault();
		} else if (event.keyCode == 13) { // ENTER
			reset(false);
			event.preventDefault();
		}
    }
	#end
	
	function reset(newMaze:Bool = false):Void {
		var seed = Std.int(Math.random() * 10000 + 1000);
		if (newMaze) {
			mesh = RectMesh.buildRectangle(600, 600);
			GridMaze.generate(600, 600, 30, 30, seed);
			GridMaze.object.scaleX = .92;
			GridMaze.object.scaleY = .92;
			GridMaze.object.x = 23;
			GridMaze.object.y = 23;
			mesh.insertObject(GridMaze.object);
		}
        entityAI.radius = GridMaze.tileWidth * .27;
		#if flash 
			var v = meshView;
		#elseif js
			var v = view;
		#end
		v.drawMesh(mesh, true);
		pathfinder.mesh = mesh;
		entityAI.x = GridMaze.tileWidth / 2;
		entityAI.y = GridMaze.tileHeight / 2;
		#if flash
			entityView.graphics.clear();
			view.graphics.clear();
		#end
		path = [];
		pathSampler.path = path;
	}
}