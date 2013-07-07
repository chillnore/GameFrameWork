package gFrameWork.sceneShanred
{
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import gFrameWork.IDisabled;
	import gFrameWork.JT_internal;
	import gFrameWork.display.BitTextureAtlas;
	import gFrameWork.url.SWFResource;

	use namespace JT_internal;
	
	public class SharedScene implements IDisabled
	{
		
		/**
		 * 场景 
		 */		
		private var mScene:Sprite;
		
		/**
		 * 共享的位图集 
		 */		
		private var sharedBitTextureAltas:Dictionary;
		
		/**
		 * 共享下载的swf文件资源 
		 */		
		private var sharedSwfResource:Dictionary;
		
		
		public function SharedScene()
		{
			sharedBitTextureAltas = new Dictionary();
			sharedSwfResource = new Dictionary();
		}
		
		/**
		 * 初始化场景，由子级覆盖实现
		 */		
		public function initScene():void
		{
			
		}
		
		/**
		 * 获取swf资源 
		 * @param url
		 * @return 
		 * 
		 */		
		public function getSwfResource(url:String):SWFResource
		{
			if(sharedSwfResource[url])
			{
				sharedSwfResource[url].growthRef();
				return sharedSwfResource[url];
			}
			else
			{
				
				SWFResource.canCreate = true;
				var swfResource:SWFResource = new SWFResource();
				sharedSwfResource[url] = swfResource;
				SWFResource.canCreate = false;
				return swfResource;
			}
		}
		
		/**
		 * 挂载销毁一个swf文件资源，如果的资的引用次数为0时则直接销毁
		 * @param url
		 * 
		 */		
		public function autoReleaseSwfResource(url:String):void
		{
			if(sharedSwfResource[url])
			{
				var swfResource:SWFResource = sharedSwfResource[url];
				swfResource.dispose();
			}
		}
		
		/**
		 * 清空场景资源 
		 */		
		public function dispose():void
		{
			if(mScene is IDisabled)
			{
				IDisabled(mScene).dispose();
				if(mScene.parent)
				{
					mScene.parent.removeChild(mScene);
				}
			}
			mScene = null;
			
			var k:String;
			for(k in sharedBitTextureAltas)
			{
				if(sharedBitTextureAltas[k] == null) continue;
				if(sharedBitTextureAltas[k] is IDisabled)
				{
					IDisabled(sharedBitTextureAltas[k]).dispose();
				}
			}
			sharedBitTextureAltas = null;
			
			for(k in sharedSwfResource)
			{
				if(sharedSwfResource[k] == null) continue;
				if(sharedSwfResource[k] is IDisabled)
				{
					IDisabled(sharedSwfResource[k]).dispose();
				}
			}
			sharedSwfResource = null;
		}
		
	}
}