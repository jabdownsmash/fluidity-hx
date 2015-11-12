
package fluidity;

import fluidity.input.Key;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import fluidity.input.Touch;
import fluidity.input.Pointer;

class Input
{

    public var scenes:Array<GameScene> = [];

    public var pointers:Array<Pointer> = [];
    public var touches:Array<Touch> = [];

    public function new()
    {

    }

    public function addScene(scene:GameScene)
    {
        if(!(scenes.indexOf(scene) >= 0))
        {
            scenes.push(scene);
        }
    }

    public function removeScene(scene:GameScene)
    {
        scenes.remove(scene);
    }

    public function reset()
    {
        scenes = [];
    }

    public function onMouseMove(x:Float,y:Float)
    {
        Pointer.mousePosition.x = x;
        Pointer.mousePosition.y = y;

        for(scene in scenes)
        {
            for(ev in scene.input.pointerMoveEvents)
            {
                switch (ev) {
                    case Object(obj,eventName):
                        var event = new GameEvent(eventName);
                        event.pointer = new Pointer(scene);
                        obj.processEvent(event);
                    case Function(func):
                        func(new Pointer(scene));
                    default:
                }
            }
        }
    }

    public function onMouseDown(x:Float,y:Float,button:Int)
    {
        Pointer.mousePosition.x = x;
        Pointer.mousePosition.y = y;
        
        for(scene in scenes)
        {
            for(ev in scene.input.pointerClickEvents)
            {
                switch (ev) {
                    case ButtonObject(but,obj,eventName):
                        if(button == but)
                        {
                            var event = new GameEvent(eventName);
                            event.pointer = new Pointer(scene);
                            obj.processEvent(event);
                        }
                    case ButtonFunction(but,func):
                        if(button == but)
                        {
                            func(new Pointer(scene));
                        }
                    default:
                }
            }
        }
    }

    public function onMouseUp(x:Float,y:Float,button:Int)
    {
        Pointer.mousePosition.x = x;
        Pointer.mousePosition.y = y;
        
        for(scene in scenes)
        {
            for(ev in scene.input.pointerReleaseEvents)
            {
                switch (ev) {
                    case ButtonObject(but,obj,eventName):
                        if(button == but)
                        {
                            var event = new GameEvent(eventName);
                            event.pointer = new Pointer(scene);
                            obj.processEvent(event);
                        }
                    case ButtonFunction(but,func):
                        if(button == but)
                        {
                            func(new Pointer(scene));
                        }
                    default:
                }
            }
        }
    }

    public function onTouchBegin(touch:Touch)
    {

    }

    public function onTouchMove(touch:Touch)
    {
        
    }

    public function onTouchEnd(touch:Touch)
    {

    }

    public function onKeyDown(key:Key)
    {
        for(scene in scenes)
        {
            var keyName = scene.input.keyMap.get(key);
            if(keyName != null)
            {
                if(!scene.input.inputStates.get(keyName))
                {
                    scene.input.inputStates.set(keyName,true);
                    for(ev in scene.input.keyDownEvents)
                    {
                        switch(ev)
                        {
                            case Object(inputName,object,event):
                                if(inputName == keyName)
                                {
                                    object.processEvent(new GameEvent(event));
                                }
                            case Function(inputName, func):
                                if(inputName == keyName)
                                {
                                    func();
                                }
                        }
                    }
                }
            }
            if(scene.input.positiveKeyAxisMap.exists(key))
            {
                scene.input.positiveKeyAxisMap.get(key).positive = true;
                scene.input.positiveKeyAxisMap.get(key).value = 1;
            }
            if(scene.input.negativeKeyAxisMap.exists(key))
            {
                scene.input.negativeKeyAxisMap.get(key).negative = true;
                scene.input.negativeKeyAxisMap.get(key).value = -1;
            }
        }
    }

    public function onKeyUp(key:Key)
    {
        for(scene in scenes)
        {
            var keyName = scene.input.keyMap.get(key);
            if(keyName != null)
            {
                if(scene.input.inputStates.get(keyName))
                {
                    scene.input.inputStates.set(keyName,false);
                    for(ev in scene.input.keyUpEvents)
                    {
                        switch(ev)
                        {
                            case Object(inputName,object,event):
                                if(inputName == keyName)
                                {
                                    object.processEvent(new GameEvent(event));
                                }
                            case Function(inputName, func):
                                if(inputName == keyName)
                                {
                                    func();
                                }
                        }
                    }
                }
            }
             
            if(scene.input.positiveKeyAxisMap.exists(key))
            {
                var axis = scene.input.positiveKeyAxisMap.get(key);
                axis.positive = false;
                if(axis.negative)
                {
                    axis.value = -1;
                }
                else
                {
                    axis.value = 0;
                }
            }
            
            if(scene.input.negativeKeyAxisMap.exists(key))
            {       
                var axis = scene.input.negativeKeyAxisMap.get(key);
                axis.negative = false;
                if(axis.positive)
                {
                    axis.value = 1;
                }
                else
                {
                    axis.value = 0;
                }
            }
        }
    }
}