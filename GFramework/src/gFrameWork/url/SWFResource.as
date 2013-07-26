package gFrameWork.url
{
	import flash.display.Loader;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import gFrameWork.IDisabled;
	import gFrameWork.JT_internal;
	
	use namespace JT_internal;
	
	
	/**
	 * Swf文件资源加载 
	 * @author taojiang
	 * 
	 */	
	[Event(name="complete",type="flash.Events.Event")]
	public class SWFResource extends EventDispatcher implements IDisabled
	{
		/**
		 * 资源装载器 
		 */		
		private var mLoader:Loader
		
		/**
		 * 文件的装载 
		 */		
		private var mFileLoader:FileLoader;
		
		/**
		 *装载的应用域 
		 */		
		private var mAppDomain:ApplicationDomain;
		
		/**
		 * 网络远程请求 
		 */		
		private var mRequest:URLRequest;
		
		/**
		 * 装载完成后回调 
		 */		
		private var mInstallComplete:Function;
		
		/**
		 * 装载失败后回调 
		 */		
		private var mInstallFault:Function;
		
		/**
		 * 是否已经装载完成 
		 */		
		private var mIsComplete:Boolean = false;	
		
		/**
		 * 装载资源 
		 * @param assets									指定的资源文件
		 * @param appDomain									指定需要装载的程序应用域
		 * @param installSucceed							装载完成执行的回调函数
		 * @param installFault								装载失改后执行的回调函数
		 * 
		 */		
		public function install(request:URLRequest,installSucceed:Function,installFault:Function = null):void
		{
			
			mInstallComplete = installSucceed;
			mInstallFault = installFault;
			mRequest = request;
			
			//资源是已经装载成，如果装完成则直接调用完成函数
			if(mIsComplete)
			{
				if(mInstallComplete != null)
				{
					mInstallComplete(new Event(Event.COMPLETE));
				}
			}
			else
			{
				if(mFileLoader)
				{
					mFileLoader.removeEventListener(Event.COMPLETE,assetsCompleteHandler);
					mFileLoader.removeEventListener(IOErrorEvent.IO_ERROR,assetsIOErrorHandler);
				}
				
				mAppDomain = new ApplicationDomain();
				mFileLoader = ResouceManager.getFileLoader(request);
				
				/*验证资源文件是否已经被下载完成*/
				if(mFileLoader.isComplete)
				{
					//开始装载资源
					internalInstall();
				}
				else
				{
					//监听下载过程
					mFileLoader.addEventListener(Event.COMPLETE,assetsCompleteHandler,false,0,true);
					mFileLoader.addEventListener(IOErrorEvent.IO_ERROR,assetsIOErrorHandler,false,0,true);
					mFileLoader.loader();
				}
			}
		}
		
		/**
		 * 
		 * 卸载安装的资源文件 
		 * 
		 */		
		public function dispose():void
		{
			
			if(mLoader)
			{
				mLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,completeHandler);
				mLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				mLoader.unloadAndStop(false);
			}
			
			if(mFileLoader)
			{
				mFileLoader.removeEventListener(Event.COMPLETE,assetsCompleteHandler);
				mFileLoader.removeEventListener(IOErrorEvent.IO_ERROR,assetsIOErrorHandler);
				mFileLoader.dispose();
			}
		}
		
		private function assetsCompleteHandler(event:Event):void
		{
			internalInstall();
		}
		
		private function assetsIOErrorHandler(event:IOErrorEvent):void
		{
			if(mInstallFault != null)
			{
				mInstallFault(event);
			}
			else
			{
				throw new IOError(event.text);
			}
		}
		
		private function internalInstall():void
		{
			if(mLoader)
			{
				mLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,completeHandler);
				mLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				mLoader.unloadAndStop(true);
			}
			
			mLoader = new Loader();
			
			if(mLoader)
			{
				
				mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
				mLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				var loadcontent:LoaderContext = new LoaderContext(false,mAppDomain);
				mLoader.loadBytes(mFileLoader.fileByte,loadcontent);
			}
		}
		
		private function completeHandler(event:Event):void
		{
			if(mInstallComplete != null)
			{
				mInstallComplete(event);
			}
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			if(mInstallFault != null)
			{
				mInstallFault(event);
			}
		}
		
		/**
		 * 获取加载的资源文件 
		 * @return 
		 */		
		public function getFileLoader():FileLoader
		{
			return mFileLoader;
		}
		
		public function getAssetsLoader():Loader
		{
			return mLoader;
		}
		
		public function getDomain():ApplicationDomain
		{
			return mAppDomain;
		}
	}
}