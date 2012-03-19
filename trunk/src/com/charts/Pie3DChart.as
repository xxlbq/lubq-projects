//------------------------------------------------------------------------------
//
//   creator : minie.pe.kr (irismin@gmail.com)
//   date : 2010.11  
//	 license : ALL FREE
//
//------------------------------------------------------------------------------

package com.charts {
	import com.charts.SubClasses.Pie3DChart.PieDrawer;
	import flash.events.Event;
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	
	public class Pie3DChart extends Canvas {
		
		public function Pie3DChart() {
			super();
			
			randChart();
		}
		
		
		protected var dr:String = "in";
		
		
		protected var keepData:Array;
		
		
		protected var keepPie:PieDrawer;
		
		
		protected var toSetList:Array;
		
		
		private var _colors:Array = [{r: Math.random() * 255, g: Math.random() * 255, b: Math.random() * 255}, {r: Math.random() * 255, g: Math.random() * 255, b: Math.random() * 255}, {r: Math.random() * 255, g: Math.random() * 255, b: Math.random() * 255}, {r: Math.random() * 255, g: Math.random() * 255, b: Math.random() * 255}, {r: Math.random() * 255, g: Math.random() * 255, b: Math.random() * 255}, {r: Math.random() * 255, g: Math.random() * 255, b: Math.random() * 255}, {r: Math.random() * 255, g: Math.random() * 255, b: Math.random() * 255}, {r: Math.random() * 255, g: Math.random() * 255, b: Math.random() * 255}, {r: Math.random() * 255, g: Math.random() * 255, b: Math.random() * 255}, {r: Math.random() * 255, g: Math.random() * 255, b: Math.random() * 255}];
		
		
		private var _dataProvider:ArrayCollection;
		
		
		private var _pieDepth:Number = 20;
		
		
		private var _pieRadius:Number = 200;
		
		
		private var _titleField:String = "title";
		
		
		private var _valueField:String = "value";
		
		
		public function get colors():Array {
			return _colors;
		}
		
		
		public function set colors(value:Array):void {
			_colors = value;
			randChart();
		}
		
		
		public function get dataProvider():ArrayCollection {
			return _dataProvider;
		}
		
		
		public function set dataProvider(value:ArrayCollection):void {
			_dataProvider = value;
			
			var i:int;
			var sumValue:Number = 0;
			
			toSetList = [];
			
			
			if (_dataProvider == null) {
				return;
			}
			var item:Object;
			
			
			for (i = 0; i < _dataProvider.length; i++) {
				item = _dataProvider[i];
				sumValue += Number(item[valueField]);
			}
			
			var startAngle:Number = 0;
			var endAngle:Number = 0;
			var r:int;
			var g:int;
			var b:int;
			var toDataUnit:Object;
			
			
			for (i = 0; i < _dataProvider.length; i++) {
				item = _dataProvider[i];
				endAngle = 360 * item[valueField] / sumValue + startAngle;
				
				
				if (i == _dataProvider.length - 1) {
					endAngle = Math.round(endAngle);
				}
				
				r = colors[i].r;
				g = colors[i].g;
				b = colors[i].b;
				toDataUnit = returnDataObject(item[titleField], startAngle,endAngle,pieRadius,pieDepth,r,g,b,0);
				toSetList.push(toDataUnit);
				startAngle = endAngle;
			}
			
			keepData = toSetList;
			
			randChart();
		}
		
		
		public function get pieDepth():Number {
			return _pieDepth;
		}
		
		
		public function set pieDepth(value:Number):void {
			_pieDepth = value;
			randChart();
		}
		
		
		public function get pieRadius():Number {
			return _pieRadius;
		}
		
		
		public function set pieRadius(value:Number):void {
			_pieRadius = value;
			
			
			if (toSetList != null) {
				for (var i:int = 0; i < toSetList.length; i++) {
					toSetList[i].radius = _pieRadius;
				}
			}
			randChart();
		}
		
		
		override public function setActualSize(w:Number, h:Number):void {
			super.setActualSize(w,h);
			this.pieRadius = Math.max(100,Math.min(this.width,this.height)) / 2;
		}
		
		
		public function get titleField():String {
			return _titleField;
		}
		
		
		public function set titleField(value:String):void {
			_titleField = value;
			randChart();
		}
		
		
		public function turnPie(angle:Number):void {
			if (keepPie == null) {
				return;
			}
			keepPie.turnPie(angle);
		}
		
		
		public function get valueField():String {
			return _valueField;
		}
		
		
		public function set valueField(value:String):void {
			_valueField = value;
			randChart();
		}
		
		
		protected function clickHandler2(event:Event):void {
			randChart();
		}
		
		
		protected function colorUint(r:int,g:int,b:int):uint {
			var ret:uint = uint("0x"+returnHex(r)+returnHex(g)+returnHex(b));
			return ret;
		}
		
		
		protected function getGradientColor(r:Number = 255, g:Number = 255, b:Number = 255):Array {
			var ret:Array = new Array();
			
			ret.push(colorUint(r+(255 - r)/3,g+(255 - g)/3,b+(255 - b)/3));
			ret.push(colorUint(r,g,b));
			ret.push(colorUint(r/2,g/2,b/2));
			
			return ret;
		}
		
		
		protected function randChart():void {
			if (toSetList == null || toSetList.length == 0) {
				if (keepPie != null) {
					this.removeChild(keepPie);
					keepPie = null;
				}
				return;
			}
			
			
			if (keepPie == null) {
				keepPie = new PieDrawer();
				this.addChild(keepPie);
			}
			
			keepPie.x = (this.width) / 2;
			keepPie.y = (this.height) / 2;
			
			keepPie.setData(toSetList,0,1.4,30);
		}
		
		
		protected function returnDataObject(subject:String, startAngle:Number, endAngle:Number, radius:Number, depth:Number, r:int,g:int,b:int,fromCenter:Number):Object {
			var ret:Object = new Object();
			ret.startAngle = startAngle;
			ret.endAngle = endAngle;
			ret.radius = radius;
			ret.depth = depth;
			ret.colorTop = getGradientColor(r,g,b);
			ret.colorSide1 = getGradientColor(r/1.8,g/1.8,b/1.8);
			ret.colorSide2 = getGradientColor(r/1.6,g/1.6,b/1.6);
			ret.colorSide3 = getGradientColor(r/1.4,g/1.4,b/1.4);
			ret.fromCenter = 0;
			ret.toFromCenter = fromCenter;
			ret.subject = subject;
			return ret;
		}
		
		
		protected function returnHex(v:int):String {
			var k:String = v.toString(16);
			
			
			if (k.length < 2) {
				return "0" + k;
			}
			return k;
		}
		
		
		protected function turnHandler(event:Event):void {
			switch (event.target.name) {
				case "t1":
					this.dispatchEvent(new Event("PieRotateLeft", true));
					break;
				case "t2":
					this.dispatchEvent(new Event("PieRotateRight", true));
					break;
			}
		}
	}
}