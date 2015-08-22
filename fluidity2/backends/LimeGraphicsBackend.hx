package fluidity2.backends;

import fluidity2.GameObject;
import fluidity2.TypeBin;
import lime.graphics.opengl.*;
// import lime.utils.Float32Array;
import lime.utils.GLUtils;
import lime.ui.Window;

class LimeGraphicsBackend implements IGraphicsBackend { 

    public var objectLists:TypeBin<LimeGraphicsObject,Array<GameObject>>;
    public var objects:EnumBin<Graphic,LimeGraphicsObject>;

    public var program:GLProgram;

    public var window:Window;

    public var customRenderer:CustomRenderer;

    public function new(w)
    {
        window = w;

        initBins();
        initGL();
    };

    public function setCustom(custom:CustomRenderer)
    {
        customRenderer = custom;
        initGL();
    }

    private function initBins()
    {

        objectLists = new TypeBin<LimeGraphicsObject,Array<GameObject>>(
            function(g:LimeGraphicsObject)
            {
                return [];
            });

        objects = new EnumBin<Graphic,LimeGraphicsObject>(
            function(g:Graphic)
            {
                var obj = new LimeGraphicsObject(g);
                if(customRenderer != null && customRenderer.customRenderPreFunc != null)
                {
                    obj.customRenderPreFunc = customRenderer.customRenderPreFunc;
                }
                if(customRenderer != null && customRenderer.customRenderPostFunc != null)
                {
                    obj.customRenderPostFunc = customRenderer.customRenderPostFunc;
                }
                return obj;
            });
    }

    private function initGL()
    {

        // var vertexSource = 
            
        //     "attribute vec4 aPosition;
        //     attribute vec2 aTexCoord;
        //     varying vec2 vTexCoord;
            
        //     uniform mat4 uMvMatrix;
        //     uniform mat4 uProjectionMatrix;
        //     uniform vec2 uTexOffset;
        //     uniform vec2 uTexSize;
            
        //     void main(void) {
                
        //         vTexCoord = aTexCoord*uTexSize + uTexOffset;
        //         gl_Position = uProjectionMatrix * uMvMatrix * aPosition;
                
        //     }";
        var vertexSource = '';
        if(customRenderer != null && customRenderer.vertexSource != null)
        {
            vertexSource = customRenderer.vertexSource;
        }
        else
        {
            vertexSource = 
            
            "attribute vec4 aPosition;
            attribute vec2 aTexCoord;
            varying vec2 vTexCoord;
            
            uniform mat4 uProjectionMatrix;
            uniform mat4 uModelViewMatrix;
            uniform vec2 uTexSize;
            uniform vec2 uTexOffset;
            
            void main(void) {
                
                vTexCoord = uTexOffset + aTexCoord * uTexSize;
                gl_Position = uProjectionMatrix * uModelViewMatrix * aPosition;
                
            }";
        }
        
        var fragmentSource = '';
        if(customRenderer != null && customRenderer.fragmentSource != null)
        {
            fragmentSource = customRenderer.fragmentSource;
        }
        else
        {
            fragmentSource = 
            
            #if !desktop
            "precision mediump float;" +
            #end
            "varying vec2 vTexCoord;
            uniform sampler2D uImage0;
            
            void main(void)
            {
                gl_FragColor = texture2D (uImage0, vTexCoord);
            }";
        }
        
        program = GLUtils.createProgram (vertexSource, fragmentSource);
        GL.useProgram (program);

        var vertexAttribute = GL.getAttribLocation (program, "aPosition");
        GL.enableVertexAttribArray (vertexAttribute);
        
        var textureAttribute = GL.getAttribLocation (program, "aTexCoord");
        GL.enableVertexAttribArray (textureAttribute);
        
        var imageUniform = GL.getUniformLocation (program, "uImage0");
        GL.uniform1i (imageUniform, 0);
        
        if(customRenderer != null && customRenderer.customInitFunc != null)
        {
            customRenderer.customInitFunc(program);
        }
        
        // var texOffsetUniform = GL.getUniformLocation (program, "uTexOffset");
        
        GL.blendFunc (GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
        GL.enable (GL.BLEND);

        LimeGraphicsObject.init(program);
    }

    public function newScene(scene:GameScene){};
    public function sceneAdd(scene:GameScene,obj:GameObject){};
    public function sceneRemove(scene:GameScene,obj:GameObject){};
    public function sceneUpdate(scene:GameScene){};
    public function sceneStart(scene:GameScene){};
    public function sceneStop(scene:GameScene){};

    public function sceneRender(scene:GameScene)
    {

        GL.viewport (0, 0, window.width, window.height);
        GL.clearColor (0,0,0,1);
        GL.clear (GL.COLOR_BUFFER_BIT);

        var projectionMatrixUniform = GL.getUniformLocation (program, "uProjectionMatrix");
        var matrix = lime.math.Matrix4.createOrtho (-800/2, 800/2, 600/2, -600/2, -1000, 1000);
        GL.uniformMatrix4fv (projectionMatrixUniform, false, matrix);

        for(object in objects.binMap)
        {
            object.renderList(objectLists.get(object));
        }
    };

    public function newObject(obj:GameObject){};
    public function objectSet(obj:GameObject,graphic:Graphic)
    {
        objectLists.get(objects.get(graphic)).push(obj);
    };

    public function objectUpdate(obj:GameObject){};
}