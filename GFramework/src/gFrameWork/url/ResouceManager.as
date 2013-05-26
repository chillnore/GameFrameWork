
package gFrameWork.url
{
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	import gFrameWork.JT_internal;
	import gFrameWork.url.AssetsLoader;
	import gFrameWork.url.FileLoader;
	
	import mx.resources.ResourceManager;

	use namespace JT_internal
	
	
	/**
	 * 外部资源加载管理，控制资源加载和装载时的缓冲过程。 
	 * @author JT
	 * 
	 */	
	public class ResouceManager
	{
		
		private static var mInstance:_ResourceManager
		
		/**
		 * 下载资源文件管理，如果碰到相同的文件加载会合并到同一个进程中处理。
		 */
		public function ResouceManager()
		{
			
		}
		
		/**
		 * 获取一个资源下载进程,如果当前下载进程已经存在则不会再去创建，如果不存在会创建一个新的下载进程。
		 * @param request
		 * @return 
		 */		
		public static function getFileLoader(request:URLRequest):FileLoader
		{
			return instance.getFileLoader(request);
		}
		
		/**
		 * 根据网络请求地址获取一个资源装载对像，如果资源相同则不会重复的构建筑装载对像。 
		 * @param request
		 * @return 
		 * 
		 */		
		public static function getAssetsLoader(request:URLRequest):AssetsLoader
		{
			return instance.getAssetsLoader(request);
		}
		
		/**
		 * 清除一个下载进程，如果当前进程存在则会清除掉，如果下载进程不存则不会有任何处理。 
		 * @param request
		 * 
		 */		
		public static function destoryFileLoader(request:URLRequest):void
		{
			return instance.destoryFileLoader(request);
		}
		
		/**
		 * 销毁一个资源装对像 
		 * @param request
		 * 
		 */		
		public static function destoryAssetsLoader(request:URLRequest):void
		{
			return instance.destoryAssetsLoader(request);
		}
		
		/**
		 * 根据网络请求地址产生一个应用域所回，同一个地址只会产生一个应用域 
		 * @param request
		 * @return 
		 * 
		 */		
		public static function getAssetsDomain(request:URLRequest):ApplicationDomain
		{
			return instance.getAssetsDomain(request);
		}
		
		private static function get instance():_ResourceManager
		{
			if(mInstance == null)
			{
				mInstance = new _ResourceManager();
			}
			return mInstance;
		}
	}
}

import flash.events.Event;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

import gFrameWork.JT_internal;
import gFrameWork.url.AssetsLoader;
import gFrameWork.url.FileLoader;


use namespace JT_internal;

class _ResourceManager
{
	
	/**
	 * 当前正在下载的资源缓充列表 
	 */	
	private var mCacheDict:Dictionary;
	
	/**
	 * 资源应用域缓充列表
	 */	
	private var mAssetsDomainDict:Dictionary;
	
	/**
	 * 资源应用装载器 
	 */	
	private var mAssetsLoaderDict:Dictionary;
	
	public function _ResourceManager():void
	{
		mCacheDict = new Dictionary();
		mAssetsDomainDict = new Dictionary();
		mAssetsLoaderDict = new Dictionary();
		
	}
	
	/**
	 * 根据下载的文件地址来获取一个下载器，如果有并行下载同一个文件时这时会有一个缓冲指向同一个下载器 
	 * @param request
	 * @return 
	 * 
	 */	
	public function getFileLoader(request:URLRequest):FileLoader
	{
		if(request == null)
		{
			throw new ArgumentError("Parameters can't for empty!");
		}
		var url:String = request.url;
		if(mCacheDict[url])
		{
			return mCacheDict[url];
		}
		else
		{
			var assets:FileLoader = new FileLoader(request);
			assets.addEventListener(Event.COMPLETE,destoryFileLoader,false,0,true);
			mCacheDict[url] = assets;
			return assets;
		}
	}
	
	/**
	 * 按文件地址摧毁文件下载器 
	 * @param request
	 * 
	 */	
	public function destoryFileLoader(request:URLRequest):void
	{
		if(request == null)
		{
			throw new ArgumentError("Parameters can't for empty!");
		}
		var url:String = request.url;
		if(mCacheDict[url])
		{
			var assets:FileLoader = mCacheDict[url] as FileLoader;
			assets.removeEventListener(Event.COMPLETE,destoryFileLoader);
			assets.dispose();
			delete mCacheDict[url];
		}
	}
	
	/**
	 * 根据文件地址获取资源的装载器，如果同时并行装载同一个文件会产生一个缓冲指向同一个装载器
	 * @param request
	 * @return 
	 * 
	 */	
	public function getAssetsLoader(request:URLRequest):AssetsLoader
	{
		if(request == null)
		{
			throw new ArgumentError("Parameters can't for empty!");
		}
		
		var url:String = request.url;
		
		var assetsLoader:AssetsLoader;
		
		if(mAssetsLoaderDict[url])
		{
			assetsLoader = mAssetsLoaderDict[url];
		}
		else
		{
			AssetsLoader.internalCall = true;
			assetsLoader = new AssetsLoader();
			AssetsLoader.internalCall = false;
			mAssetsLoaderDict[url] = assetsLoader;
		}
		assetsLoader.mReferenceCount++;
		return assetsLoader;
	}
	
	/**
	 * 按文件地址摧毁文件装载器 
	 * @param request
	 * 
	 */	
	public function destoryAssetsLoader(request:URLRequest):void
	{
		if(request == null)
		{
			throw new ArgumentError("Parameters can't for empty!");
		}
		
		var url:String = request.url;
		var assetsLoader:AssetsLoader = mAssetsLoaderDict[url];
		
		if(assetsLoader)
		{
			assetsLoader.mReferenceCount--;
			if(assetsLoader.mReferenceCount == 0)
			{
				assetsLoader.unloadAndStop(false);
				delete mAssetsLoaderDict[url];
			}
		}
	}
	
	/**
	 * 根据文件来获取一个资源应用域 
	 * @param request
	 * @return 
	 * 
	 */	
	public function getAssetsDomain(request:URLRequest):ApplicationDomain
	{
		if(request == null)
		{
			throw new ArgumentError("Parameters can't for empty!");
		}
		var url:String = request.url;
		if(mAssetsDomainDict[url])
		{
			return mAssetsDomainDict[url];
		}
		else
		{
			var assetsDomain:ApplicationDomain = new ApplicationDomain();
			mAssetsDomainDict[url] = assetsDomain;
			return assetsDomain;
		}
	}
	
	
	private function fileLoaderComplete(event:Event):void
	{
		var curAf:FileLoader = event.currentTarget as FileLoader;
		destoryFileLoader(curAf.request);
	}
	
}