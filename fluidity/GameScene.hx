
package fluidity;

import haxe.ds.StringMap;

import evsm.FState;

import fluidity.input.SceneInput;
import fluidity.backends.Backend;

import fluidity.utils.StringBin;
import fluidity.utils.Vec2;

class GameScene{

    public var layer:GameLayer;

    public var active(default,null):Bool = false;
    public var input:SceneInput;

    public var camera:Vec2 = new Vec2();

    public var cameraScale:Float = 1;

    public var states:StringBin<FState<GameObject,GameEvent>>;

    public var updating:Bool = false;

    public var toAdd:Array<GameObject> = [];
    public var toRemove:Array<GameObject> = [];
    public var toDelete:Array<GameObject> = [];

    public var inUpdate = false;

    public function new(?gravity:Vec2)
    {
        input = new SceneInput();

        Backend.physics.newScene(this);
        Backend.graphics.newScene(this);

        states = new StringBin<FState<GameObject,GameEvent>>(function(name:String)
            {
                return new FState<GameObject,GameEvent>(name);
            });
    }

    public function setLayer(l:GameLayer)
    {
        layer = l;
        Backend.graphics.sceneLayerSet(this);
        return this;
    }

    private function __add(obj:GameObject)
    {
        if(obj.scene != null)
        {
            obj.scene.remove(obj);
        }
        objects.push(obj);
        obj.scene = this;

        Backend.graphics.sceneAdd(this,obj);
        Backend.physics.sceneAdd(this,obj);
        return this;
    }

    public function add(obj:GameObject)
    {
        toAdd.push(obj);
    }

    private function __remove(obj:GameObject)
    {
        obj.scene = null;
        if(objects.remove(obj))
        {
            Backend.graphics.sceneRemove(this,obj);
            Backend.physics.sceneRemove(this,obj);
        }
        return this;
    }

    public function remove(obj:GameObject)
    {
        toRemove.push(obj);
    }

    private function __delete(obj:GameObject)
    {
        if(obj != null)
        {
            if(obj.type != null)
            {
                obj.type.removeObject(obj);
            }
            input.delete(obj);
            __remove(obj);
            Backend.graphics.objectDispose(obj);
            Backend.physics.objectDispose(obj);
        }
    }

    public function delete(obj:GameObject)
    {
        toDelete.push(obj);
        return this;
    }

    public function update()
    {
        Backend.physics.sceneUpdate(this);
        input.update();
        inUpdate = true;
        onUpdate();
        for(obj in objects)
        {
            obj.update();
        }
        inUpdate = false;
        Backend.graphics.sceneUpdate(this);

        for(obj in toAdd)
        {
            __add(obj);
        }
        toAdd = [];

        for(obj in toRemove)
        {
            __remove(obj);
        }
        toRemove = [];

        for(obj in toDelete)
        {
            __delete(obj);
        }
        toDelete = [];
        return this;
    }

    public function render()
    {
        Backend.graphics.sceneRender(this);
    }

    public function start()
    {
        active = true;
        
        onStart();

        Backend.graphics.sceneStart(this);
        Backend.physics.sceneStart(this);

        return this;
    }

    public function reset()
    {
        while(objects.length > 0)
        {
            __delete(objects[objects.length - 1]);
        }
        Backend.graphics.sceneReset(this);
        Backend.physics.sceneReset(this);
        input = new SceneInput();
        onReset();

        active = false;
        camera = new Vec2();

        cameraScale = 1;

        return this;
    }

    public function onStart()
    {

    }

    public function onUpdate()
    {

    }

    public function onReset()
    {

    }

    public function processEvent(?e:GameEvent, ?s:String)
    {
        var event:GameEvent;
        if(e == null && s == null)
        {
            trace("No argument given to processEvent on scene");
            return this;
        }
        if(e != null && s != null)
        {
            trace("Too many arguments given to processEvent on scene");
            return this;
        }

        if(e != null)
        {
            event = e;
        }
        // if(s != null)
        else
        {
            event = new GameEvent(s);
        }
        for(obj in objects)
        {
            obj.processEvent(event);
        }
        return this;
    }

    public function addGenerator(name:String, ?generatorWithoutArgs:Void->GameObject, ?generatorWithArgs:Array<Dynamic>->GameObject)
    {
        if(generatorWithoutArgs == null && generatorWithArgs == null)
        {
            trace("No argument given to set generator " + name);
            return this;
        }
        if(generatorWithoutArgs != null && generatorWithArgs != null)
        {
            trace("Too many arguments given to set generator " + name);
            return this;
        }
        if(generatorWithoutArgs != null)
        {
            generatorMap.set(name,function(a:Array<Dynamic>){return generatorWithoutArgs();});
        }
        if(generatorWithArgs != null)
        {
            generatorMap.set(name,generatorWithArgs);
        }
        return this;
    }

    public function generate(name:String, ?args:Array<Dynamic>)
    {
        if(args == null)
        {
            args = [];
        }
        if(generatorMap.exists(name))
        {
            if(active)
            {
                var obj = generatorMap.get(name)(args);
                add(obj);
                return obj;
            }
            else
            {
                trace('Cannot generate objects before this scene has started. Override onStart() and generate objects there. Obj name: ' + name);
            }
        }
        else
        {
            trace('Generator with name ' + name + ' does not exist');
        }
        return null;
    }


    private var objects:Array<GameObject> = [];

    private var generatorMap:StringMap<Array<Dynamic>->GameObject> = new StringMap<Array<Dynamic>->GameObject>();

}