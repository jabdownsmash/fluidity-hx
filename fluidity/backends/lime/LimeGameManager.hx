
package fluidity.backends.lime;

import haxe.ds.StringMap;

import evsm.FState;

import fluidity.backends.Backend;

import fluidity.utils.StringBin;
import fluidity.utils.Vec2;

import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;

class LimeGameManager extends Application{

    public var gameManager:GameManager = new GameManager();
    public var lgb:GraphicsLime;

    public var layers:StringBin<GameLayer>;

    public var limeInput:LimeInput;
    public var started:Bool = false;

    public function new()
    {
        super();

        layers = new StringBin<GameLayer>(function (name:String)
            {
                return gameManager.layers.get(name);
            });
        
    }

    public function _init()
    {
        lgb = new GraphicsLime(window);
        limeInput = new LimeInput();
        Backend.graphics = lgb;
        // Backend.physics = new PhysicsNape();
        Backend.physics = new PhysicsSimple();
        Backend.input = limeInput;
        gameManager.init();
        window.onResize.add(_onResize);
        onUpdate.add(function (i){gameManager.update();});
        onInit();
    }

    public function onInit()
    {
    }

    public override function render (renderer):Void
    {
        if(!started)
        {
            started = true;
            _init();
        }
        // gameManager.update();
        gameManager.render();
    }
    
    
    public override function onKeyDown (window,key:KeyCode, modifier:KeyModifier):Void {
        limeInput.limeOnKeyDown(key);
    }
    public override function onKeyUp (window,key:KeyCode, modifier:KeyModifier):Void {
        limeInput.limeOnKeyUp(key);
    }

    public override function onTouchStart(touch)
    {
        GameLayer.sendEventToLayers(new GameEvent('titleFinished'));
        // if(gameScene != null)
        // {
        //  gameScene.finished = true;
        // }
    }

    public override function onTouchEnd(touch)
    {

    }

    public override function onTouchMove(touch)
    {

    }

    public override function onMouseMove(window:Window,x:Float, y:Float)
    {
        limeInput.onMouseMove(x - window.width/2,y - window.height/2);
    }

    public override function onMouseDown(window:Window,x:Float, y:Float, button:Int)
    {
        limeInput.onMouseDown(x - window.width/2,y - window.height/2,button);
    }

    public override function onMouseUp(window:Window,x:Float, y:Float, button:Int)
    {
        limeInput.onMouseUp(x - window.width/2,y - window.height/2,button);
    }

    public function _onResize(width:Int,height:Int)
    {
        lgb.width = width;
        lgb.height = height;
        onResize();
        gameManager.onResize();
    }

    public function onResize()
    {
    }

}