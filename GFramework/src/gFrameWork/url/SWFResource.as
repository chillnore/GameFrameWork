package gFrameWork.url
{
	import flash.display.Loader;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	
	public class SWFResource
	{
		/**
		 * 资源装载器 
		 */		
		private var mLoader:AssetsLoader
		
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
		 * 是否可以清理回收 
		 */		
		private var mCanDispose:Boolean = false;
		
 		/**
		 * 
		 * swf文件装载,可以指定一个资源文件加载，
		 * 文件加载完成后就装载此文件的数据流内容。使其得到swf资文件里的要关对像。 
		 * 
		 */		
		public function SWFResource(weekkeys:Boolean = true)
		{
			mCanDispose = weekkeys;	
		}
		
		
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
			if(mFileLoader)
			{
				mFileLoader.removeEventListener(Event.COMPLETE,assetsCompleteHandler);
				mFileLoader.removeEventListener(IOErrorEvent.IO_ERROR,assetsIOErrorHandler);
			}
			
			mAppDomain = ResouceManager.getAssetsDomain(request);
			mFileLoader = ResouceManager.getFileLoader(request);

			/*验证资源文件是否已经被下载完成*/
			if(mFileLoader.isComplete)
			{
				//装载
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
		
		/**
		 * 
		 * 卸载安装的资源文件 
		 * 
		 */		
		public function unInstall():void
		{
			if(mLoader)
			{
				mLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,completeHandler);
				mLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
//				mLoader.unloadAndStop(true);
				if(mCanDispose)
				{
					//销毁当前使用的资源
					ResouceManager.destoryAssetsLoader(mRequest);
				}
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
				if(mCanDispose)
				{
					//销毁当前使用的资源
					ResouceManager.destoryAssetsLoader(mRequest);
				}
			}
			
			mLoader = ResouceManager.getAssetsLoader(mRequest);
			
			if(mLoader)
			{
				
//				mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
//				mLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
//				var loadcontent:LoaderContext = new LoaderContext(false,mAppDomain);
//				mLoader.loadBytes(mFileLoader.fileByte,loadcontent);
				
				if(mLoader.isComplete)
				{
					if(mInstallComplete != null)
					{
						mInstallComplete(new Event(Event.COMPLETE));
					}
				}
				else
				{
					mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
					mLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
					var loadcontent:LoaderContext = new LoaderContext(false,mAppDomain);
					mLoader.loadBytes(mFileLoader.fileByte,loadcontent);
				}
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