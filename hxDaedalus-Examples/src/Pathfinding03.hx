import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.data.math.Point2D;
import hxDaedalus.data.math.RandGenerator;
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
typedef UpDownEvent = flash.events.Event;
#elseif js
typedef UpDownEvent = js.html.Event
#end

class Pathfinding03
#if flash 
extends Sprite
#end
{
    
    var mesh : Mesh;
    var view : SimpleView;
    
    var entityAI : EntityAI;
    var pathfinder : PathFinder;
    var path : Array<Float>;
    var pathSampler : LinearPathSampler;
    var newPath:Bool = false;
    
	#if js
    var x: Float;
    var y: Float;
	var basicCanvas: BasicCanvas;
	#end
	
    public static function main():Void {
		#if flash	Lib.current.addChild(new Pathfinding03());
    	#elseif js 	new Pathfinding03();
		#end
	}
    
    public function new(){
        #if flash	super();
		#elseif js
		#end
		
        // build a rectangular 2 polygons mesh of 600x600
        mesh = RectMesh.buildRectangle(600, 600);
        
		#if flash
        	Lib.current.addChild(this);
		
        	// create a viewport
			var viewSprite = new Sprite();
        	view = new SimpleView(viewSprite.graphics);
        	addChild(viewSprite);
			var meshView = new SimpleView(this.graphics);
		#elseif js
        	basicCanvas = new BasicCanvas();
		
        	// create a viewport
        	view = new SimpleView(basicCanvas);
		#end
			
		
        // pseudo random generator
        var randGen : RandGenerator;
        randGen = new RandGenerator();
        randGen.seed = 7259;  // put a 4 digits number here  
        
        // populate mesh with many square objects
        var object : Object;
        var shapeCoords : Array<Float>;
        for (i in 0...50){
            object = new Object();
            shapeCoords = new Array<Float>();
            shapeCoords = [ -1, -1, 1, -1,
                             1, -1, 1, 1,
                            1, 1, -1, 1,
                            -1, 1, -1, -1];
            object.coordinates = shapeCoords;
            randGen.rangeMin = 10;
            randGen.rangeMax = 40;
            object.scaleX = randGen.next();
            object.scaleY = randGen.next();
            randGen.rangeMin = 0;
            randGen.rangeMax = 1000;
            object.rotation = (randGen.next() / 1000) * Math.PI / 2;
            randGen.rangeMin = 50;
            randGen.rangeMax = 600;
            object.x = randGen.next();
            object.y = randGen.next();
            mesh.insertObject(object);
        }  // show result mesh on screen  
        
        #if flash
			meshView.drawMesh(mesh);
		#elseif js
			view.drawMesh(mesh);
		#end
		
        // we need an entity
        entityAI = new EntityAI();
        // set radius as size for your entity
        entityAI.radius = 4;
        // set a position
        entityAI.x = 20;
        entityAI.y = 20;
        
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
        pathSampler.samplingDistance = 10;
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
		
			#if openfl
				var fps = new openfl.display.FPS();
				s.addChild(fps);
			#end
		#elseif js
        	// click/drag
        	basicCanvas.canvas.onmousedown = onMouseDown;
        	basicCanvas.canvas.onmouseup = onMouseUp;
        	basicCanvas.canvas.onmousemove = onMouseMove;
		
        	// animate
        	basicCanvas.onEnterFrame = onEnterFrame;
		#end
	}
    
	#if js
    function onMouseMove( e: Event ): Void {
        var p: MouseEvent = cast e;
        x = p.clientX;
        y = p.clientY;
    }
	#end
	
    function onMouseUp( event: UpDownEvent ): Void {
		newPath = false;
    }
    
    function onMouseDown( event: UpDownEvent ): Void {
        newPath = true;
    }
    
    function onEnterFrame( #if flash event: Event #end ): Void {
		if( newPath ){
			#if flash
				view.graphics.clear();
			#elseif js
				view.drawMesh(mesh, true);
			#end
		}
			
        if( newPath ){
            // find path !
            #if flash
				var x = stage.mouseX;
				var y = stage.mouseY;
			#end
			
			pathfinder.findPath( x, y, path );
				
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
		view.drawEntity( entityAI );
    }
	
    #if flash
    function onKeyDown( event:KeyboardEvent ): Void {
        if( event.keyCode == 27 ) {  // ESC
		#if flash
			flash.system.System.exit(1);
		#elseif sys
			Sys.exit(1);
		#end
        }
    }
	#end
	
}
