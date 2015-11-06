
package fluidity;

import haxe.ds.StringMap;

import evsm.FState;

import fluidity.backends.Backend;

import fluidity.utils.StringBin;
import fluidity.utils.Vec2;

class GameLayer{

    public var state:FState<GameLayer,GameEvent>;

    // public var width(get,set):Float;
    // public var height(get,set):Float;

    // private var _width:Float; 
    // private var _height:Float; 

    public var position:Vec2 = new Vec2();
    public var sceneOffset:Vec2 = new Vec2();

    public var width:Int = 1;
    public var height:Int = 1;

    public var vWidth:Int = 1;
    public var vHeight:Int = 1;

    // public var lockAspectRatio:Bool = false;

    public static var activeLayers:Array<GameLayer> = [];

    private var states:Map<String,FState<GameLayer,GameEvent>> = new Map<String,FState<GameLayer,GameEvent>>();

    private var scenes:Map<String,GameScene> = new Map<String,GameScene>();

    public function new()
    {
        width = vWidth = Backend.graphics.width;
        height = vHeight = Backend.graphics.height;
    }

    public function setX(x:Int):GameLayer
    {
        position.x = x;
        Backend.graphics.layerPositionsChanged(this);
        return this;
    }
    public function setY(y:Int):GameLayer
    {
        position.y = y;
        Backend.graphics.layerPositionsChanged(this);
        return this;
    }
    public function setPosition(pos:Vec2):GameLayer
    {
        position.set(pos);
        Backend.graphics.layerPositionsChanged(this);
        return this;
    }
    public function setSceneX(x:Int):GameLayer
    {
        sceneOffset.x = x;
        Backend.graphics.layerPositionsChanged(this);
        return this;
    }
    public function setSceneY(y:Int):GameLayer
    {
        sceneOffset.y = y;
        Backend.graphics.layerPositionsChanged(this);
        return this;
    }
    public function setScenePosition(pos:Vec2):GameLayer
    {
        sceneOffset.set(pos);
        Backend.graphics.layerPositionsChanged(this);
        return this;
    }

    public function setWidth(w:Int):GameLayer
    {
        width = w;
        Backend.graphics.layerDimensionsChanged(this);
        return this;
    }
    public function setHeight(h:Int):GameLayer
    {
        height = h;
        Backend.graphics.layerDimensionsChanged(this);
        return this;
    }
    public function setDimensions(w:Int,h:Int):GameLayer
    {
        width = w;
        height = h;
        Backend.graphics.layerDimensionsChanged(this);
        return this;
    }
    public function setVWidth(vw:Int):GameLayer
    {
        vWidth = vw;
        Backend.graphics.layerDimensionsChanged(this);
        return this;
    }
    public function setVHeight(vh:Int):GameLayer
    {
        vHeight = vh;
        Backend.graphics.layerDimensionsChanged(this);
        return this;
    }
    public function setVDimensions(vw:Int,vh:Int):GameLayer
    {
        vWidth = vw;
        vHeight = vh;
        Backend.graphics.layerDimensionsChanged(this);
        return this;
    }

    public function addScene(stateName:String,scene:GameScene)
    {
        scenes.set(stateName,scene);
        states.set(stateName,new FState<GameLayer,GameEvent>(stateName));
        return this;
    }

    public function addTransition(eventID:String,stateFrom:String,reset1:Bool = false,stateTo:String,reset2:Bool = false)
    {
        var fromScene = scenes.get(stateFrom);
        var toScene = scenes.get(stateTo);

        states.get(stateFrom)
            .setTransition(eventID,states.get(stateTo))
            .onEvent(eventID,function(l:GameLayer)
                {
                    fromScene.layer = null;
                    Backend.input.removeScene(fromScene);
                    if(toScene.layer == null)
                    {
                        toScene.setLayer(this);
                        Backend.input.addScene(toScene);
                        // toScene.layer = this;
                    }
                    else
                    {
                        trace('scene from state ' + stateTo + 'owned by other layer');
                    }
                    if(reset1)
                    {
                        fromScene.reset();
                    }
                    if(reset2)
                    {
                        toScene.reset();
                    }
                    if(!toScene.active)
                    {
                        toScene.start();
                    }
                })
        ;
        return this;
    }

    public function start(stateName:String)
    {
        state = states.get(stateName);
        scenes.get(stateName).setLayer(this).start();
        Backend.input.addScene(scenes.get(stateName));
        activeLayers.push(this);
        return this;
    }

    public function update()
    {
        scenes.get(state.name).update();
        return this;
    }

    public function render()
    {
        scenes.get(state.name).render();
        return this;
    }

    public function processEvent(event:GameEvent)
    {
        state.processEvent(this,event);
        return this;
    }

    public static function sendEventToLayers(event:GameEvent)
    {
        for(layer in activeLayers)
        {
            layer.processEvent(event);
        }
    }

    public function getScene():GameScene
    {
        return scenes.get(state.name);
    }

    public function worldPointToLocal(point:Vec2)
    {
        var xScale = vWidth/width;
        var yScale = vHeight/height;
        var x = point.x * xScale;
        var y = point.y * yScale;
        var camera = getScene().camera;

        return new Vec2(x - position.x*xScale - sceneOffset.x + camera.x, y - position.y*yScale - sceneOffset.y + camera.y);
    }

    public function localPointToWorld(point:Vec2)
    {
        var xScale = width/vWidth;
        var yScale = height/vHeight;
        var camera = getScene().camera;
        var x = point.x - camera.x + sceneOffset.x + position.x/xScale;
        var y = point.y - camera.y + sceneOffset.y + position.y/yScale;

        return new Vec2(x*xScale, y*yScale);
    
    }
}