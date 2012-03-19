//------------------------------------------------------------------------------
//
//   creator : minie.pe.kr (irismin@gmail.com)
//   date : 2010.11  
//	 license : ALL FREE
//
//------------------------------------------------------------------------------

package com.charts.SubClasses.Pie3DChart {
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import mx.core.UIComponent;
	
	
	public class PieDrawer extends UIComponent {
		public function PieDrawer() {
			super();
		}
		
		
		public var isPlaying:Boolean = false;
		
		
		public var motionSpeed:Number = 0.6;
		
		
		public var pieDrawAngleStep:Number = 5;
		
		
		protected var drawAreaUnits:Object;
		
		
		protected var keepData:Array;
		
		
		protected var labelArea:UIComponent;
		
		
		protected var lineArea:UIComponent;
		
		
		protected var lineGap:Number;
		
		
		protected var lineRadiusScale:Number;
		
		
		protected var nowAngle:Number = 0;
		
		
		protected var openGap:Number = 40;
		
		
		protected var pieUnitArea:UIComponent;
		
		
		protected var rotationAngle:Number;
		
		
		protected var scaleNum:Number;
		
		
		protected var toAngle:Number = 0;
		
		
		public function setData(v:Array, rotationAngle:Number=0, lineRadiusScale:Number=1.4, lineGap:Number=10):void {
			this.scaleNum = 0.8;
			this.lineRadiusScale = lineRadiusScale;
			this.lineGap = lineGap;
			this.rotationAngle = rotationAngle;
			this.keepData = v;
			
			drawAreaUnits = new Object();
			drawAreaUnits.area1 = new Array();
			drawAreaUnits.area2 = new Array();
			drawAreaUnits.area3 = new Array();
			drawAreaUnits.area4 = new Array();
			
			
			for (var i:int = 0; i < v.length; i++) {
				var obj:Object = v[i];
				obj.startAngle += rotationAngle;
				obj.endAngle += rotationAngle;
				var makedUnit:Array = makeUnit(obj, obj.startAngle, obj.endAngle, obj.radius, obj.depth, obj.colorTop, obj.colorSide1, obj.colorSide2, obj.colorSide3, obj.fromCenter);
				
				
				for (var j:int = 0; j < makedUnit.length; j++) {
					if (drawAreaUnits["area" + checkArea(makedUnit[j].startAngle)] == null) {
						drawAreaUnits["area" + checkArea(makedUnit[j].startAngle)] = new Array();
					}
					drawAreaUnits["area" + checkArea(makedUnit[j].startAngle)].push(makedUnit[j]);
				}
			}
			drawPie();
			drawLabel(v);
		}
		
		
		public function startMotion():void {
			if (isPlaying) {
				return;
			}
			
			isPlaying = true;
			this.addEventListener("enterFrame", enterFunc,false,0,true);
		}
		
		
		public function stopMotion():void {
			this.removeEventListener("enterFrame", enterFunc,false);
			isPlaying = false;
		}
		
		
		public function turnPie(angle:Number):void {
			toAngle += angle;
			startMotion();
		}
		
		
		protected function calculateSqrt(c:Number, a:Number):Number {
			var ret:Number;
			
			
			if (c < a) {
				return 0;
			}
			ret = Math.sqrt(c*c-a*a);
			
			return ret;
		}
		
		
		/**
		   90도 단위의 Area중 어느곳에 속하는 지를 반환한다.
		 **/
		protected function checkArea(Angle:Number):int {
			return int(Math.floor(Angle%360 / 90)) + 1;
		}
		
		
		protected function drawLabel(v:Array):void {
			if (labelArea == null) {
				labelArea = new UIComponent();
				this.addChild(labelArea);
			} else {
				while (labelArea.numChildren > 0) {
					labelArea.removeChildAt(0);
				}
			}
			
			
			if (lineArea == null) {
				lineArea = new UIComponent();
				this.addChild(lineArea);
				lineArea.blendMode = BlendMode.INVERT;
			} else {
				while (lineArea.numChildren > 0) {
					lineArea.removeChildAt(0);
				}
			}
			
			var labelArray1:Array = new Array();
			var labelArray2:Array = new Array();
			
			
			for (var i:int = 0; i < v.length; i++) {
				var drawUnit:Object = v[i];
				/*
				   if(drawUnit.endAngle<drawUnit.startAngle){
				   drawUnit.endAngle=drawUnit.endAngle%360+360;
				   } else {
				   drawUnit.endAngle=drawUnit.endAngle%360;
				   }
				   drawUnit.startAngle=drawUnit.startAngle%360;
				 */
				var centerAngle:Number = (drawUnit.endAngle - drawUnit.startAngle) / 2 + drawUnit.startAngle;
				var pt:Point = rotationLocate(centerAngle,0,-(drawUnit.radius + lineGap + drawUnit.fromCenter));
				
				var labelData:Object = new Object();
				labelData.subject = Math.round((drawUnit.endAngle - drawUnit.startAngle)/360*1000) / 10 + "% " + drawUnit.subject;
				labelData.objData = drawUnit;
				labelData.x = pt.x;
				labelData.y = pt.y * scaleNum + drawUnit.depth;
				labelData.radius = drawUnit.radius + lineGap + drawUnit.fromCenter;
				labelData.centerAngle = centerAngle;
				
				//trace(drawUnit.startAngle, drawUnit.endAngle, centerAngle);
				centerAngle = centerAngle % 360;
				
				
				if (centerAngle > 180) {
					labelArray1.push(labelData);
				} else {
					labelArray2.push(labelData);
				}
			}
			
			labelArray1.sortOn("y", Array.NUMERIC);
			labelArray2.sortOn("y", Array.NUMERIC);
			
			var keepData:Object;
			
			
			if (labelArray1.length > 1) {
				keepData = labelArray1[0];
				
				
				for (i = 1; i < labelArray1.length; i++) {
					labelData = labelArray1[i];
					
					
					if (labelData.y < keepData.y + 15) {
						labelData.y += ((keepData.y + 15) - labelData.y);
					}
					
					
					if (!(labelData.centerAngle % 360 > 90 && labelData.centerAngle % 360 < 270)) {
						labelData.x = -calculateSqrt(labelData.radius,labelData.y);
						var tempAngle:Number = findAngle(labelData.x,labelData.y);
						pt = rotationLocate(tempAngle,0,-labelData.radius);
						
						
						if (labelData.y <= pt.y) {
							labelData.x = pt.x;
							labelData.y = pt.y;
						}
					}
					keepData = labelData;
				}
			}
			
			
			if (labelArray2.length > 1) {
				keepData = labelArray2[0];
				
				
				for (i = 1; i < labelArray2.length; i++) {
					labelData = labelArray2[i];
					
					
					if (labelData.y < keepData.y + 15) {
						labelData.y += ((keepData.y + 15) - labelData.y);
					}
					
					
					if (!(labelData.centerAngle % 360 > 90 && labelData.centerAngle % 360 < 270)) {
						labelData.x = calculateSqrt(labelData.radius,labelData.y);
						tempAngle = findAngle(labelData.x,labelData.y);
						pt = rotationLocate(tempAngle,0,-labelData.radius);
						
						
						if (labelData.y <= pt.y) {
							labelData.x = pt.x;
							labelData.y = pt.y;
						}
					}
					keepData = labelData;
				}
			}
			
			var gl:Graphics = lineArea.graphics;
			gl.clear();
			gl.lineStyle(1,0x999999,1);
			
			var pt1:Point;
			var pt2:Point;
			
			var labelItem:PieLabel;
			
			
			for (i = 0; i < labelArray1.length; i++) {
				labelData = labelArray1[i];
				labelItem = new PieLabel();
				labelItem.addEventListener("click", pieUnitAreaClickHandler,false,0,true);
				labelItem.objData = labelData.objData;
				labelItem.x = labelData.x - 10;
				labelItem.y = labelData.y;
				labelItem.setText(labelData.subject, "right");
				labelArea.addChild(labelItem);
				
				pt1 = rotationLocate(labelData.centerAngle,0,-labelData.radius*(2 - lineRadiusScale));
				pt1 = pieUnitArea.localToGlobal(pt1);
				pt1 = labelArea.globalToLocal(pt1);
				pt2 = new Point(labelItem.x+5,labelItem.y-2);
				gl.moveTo(pt1.x,pt1.y);
				gl.lineTo(pt2.x,pt2.y);
				gl.lineTo(pt2.x-+labelItem.textWidth-10,pt2.y);
			}
			
			
			for (i = 0; i < labelArray2.length; i++) {
				labelData = labelArray2[i];
				labelItem = new PieLabel();
				labelItem.addEventListener("click", pieUnitAreaClickHandler,false,0,true);
				labelItem.objData = labelData.objData;
				labelItem.x = labelData.x + 10;
				labelItem.y = labelData.y;
				labelItem.setText(labelData.subject, "left");
				labelArea.addChild(labelItem);
				
				pt1 = rotationLocate(labelData.centerAngle,0,-labelData.radius*(2 - lineRadiusScale));
				pt1 = pieUnitArea.localToGlobal(pt1);
				pt1 = labelArea.globalToLocal(pt1);
				pt2 = new Point(labelData.x+5,labelData.y-2);
				gl.moveTo(pt1.x,pt1.y);
				gl.lineTo(pt2.x,pt2.y);
				gl.lineTo(pt2.x+labelItem.textWidth+10,pt2.y);
			}
		
		}
		
		
		protected function drawPie():void {
			if (pieUnitArea == null) {
				pieUnitArea = new PieUnit();
				pieUnitArea.scaleY = scaleNum;
				pieUnitArea.addEventListener("click", pieUnitAreaClickHandler,false,0,true);
				
				var dropShadow:DropShadowFilter = new DropShadowFilter(20, 90, 0x000000, 0.5, 20, 20, 1, 2, false, false, false);
				pieUnitArea.filters = new Array(dropShadow);
				
				this.addChild(pieUnitArea);
			} else {
				while (pieUnitArea.numChildren > 0) {
					pieUnitArea.removeChildAt(0);
				}
			}
			
			var drawOrder:Array = ["area1", "area4", "area3", "area2"];
			
			
			for (var i:int = 0; i < drawOrder.length; i++) {
				var drawArray:Array = drawAreaUnits[drawOrder[i]];
				
				
				for (var k:int = 0; k < drawArray.length; k++) {
					drawArray[k].startAngle = drawArray[k].startAngle % 360;
					drawArray[k].endAngle = drawArray[k].endAngle % 360;
				}
				
				
				// 정렬
				switch (drawOrder[i]) {
					case "area4":
					case "area3":
						drawArray.sortOn("startAngle", Array.DESCENDING | Array.NUMERIC);
						break;
					default:
						drawArray.sortOn("startAngle", Array.NUMERIC);
						break;
				}
				
				
				for (var j:int = 0; j < drawArray.length; j++) {
					var drawUnit:Object = drawArray[j];
					var temp:PieUnit = new PieUnit();
					temp.x = drawUnit.tx;
					temp.y = drawUnit.ty;
					temp.pieDrawAngleStep = pieDrawAngleStep;
					pieUnitArea.addChild(temp);
					temp.drawPie(drawUnit.objData, drawUnit.startAngle,drawUnit.endAngle,drawUnit.radius,drawUnit.depth,drawUnit.colorTop,drawUnit.colorSide1,drawUnit.colorSide2,drawUnit.colorSide3);
				}
			}
		}
		
		
		protected function enterFunc(event:Event):void {
			var checkMove:Boolean = false;
			var plusAngle:Number = 0;
			
			
			if (nowAngle != toAngle) {
				checkMove = true;
				plusAngle = (toAngle - nowAngle) * motionSpeed;
				
				
				if (Math.abs(toAngle-(nowAngle + plusAngle)) < 1) {
					plusAngle = toAngle - nowAngle;
					nowAngle = toAngle;
				} else {
					nowAngle += plusAngle;
				}
			}
			
			
			for (var i:int = 0; i < keepData.length; i++) {
				var now:Number = keepData[i].fromCenter;
				var toN:Number = keepData[i].toFromCenter;
				
				keepData[i].startAngle += plusAngle;
				keepData[i].endAngle += plusAngle;
				
				
				while (keepData[i].startAngle < 0) {
					keepData[i].startAngle += 360;
				}
				
				
				while (keepData[i].endAngle < 0) {
					keepData[i].endAngle += 360;
				}
				
				
				if (now == toN) {
					continue;
				}
				
				checkMove = true;
				
				
				if (Math.abs(now-toN) < 1) {
					keepData[i].fromCenter = toN;
				} else {
					keepData[i].fromCenter = (toN - now) * motionSpeed + now;
				}
			}
			
			
			if (checkMove) {
				setData(keepData, rotationAngle, lineRadiusScale, lineGap);
			} else {
				stopMotion();
			}
		}
		
		
		protected function findAngle(x1:Number, y1:Number, x2:Number=0, y2:Number=0):Number {
			var a:Number = y2 - y1;
			var c:Number = Math.sqrt( (x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1) );
			
			var ang:Number = Math.acos(a/c);
			ang *= 180.0 / Math.PI;
			
			
			if (x1 < 0) {
				ang = 360 - ang;
			}
			return ang;
		}
		
		
		/**
		   drawUnit function
		   한 개의 파이 조각을 만든다.
		   파이가 그려질 360도의 범위를 90도 단위로 네 조각으로 나누어
		   각 단위를 넘어설 경우 조각을 나누어 배열로 반환한다.
		 **/
		protected function makeUnit(objData:Object, startAngle:Number, endAngle:Number, radius:Number, depth:Number, colorTop:Array, colorSide1:Array, colorSide2:Array, colorSide3:Array, fromCenter:Number=0):Array {
			var ret:Array = new Array();
			var retObj:Object;
			
			var keepAngle:Number = -1;
			var keepStartAngle:Number = startAngle;
			
			var tx:Number = 0;
			var ty:Number = 0;
			
			
			if (fromCenter > 0) {
				var toPt:Point = rotationLocate(startAngle+(endAngle - startAngle)/2,0,-fromCenter);
				tx = toPt.x;
				ty = toPt.y;
			}
			
			
			while (keepAngle != endAngle) {
				keepAngle = (Math.floor(keepStartAngle/90) + 1) * 90;
				
				
				if (keepAngle > endAngle) {
					keepAngle = endAngle;
				}
				retObj = new Object();
				retObj.objData = objData;
				
				retObj.startAngle = (int(keepStartAngle*10) / 10) % 360;
				retObj.endAngle = (int(keepAngle*10) / 10) % 360;
				
				
				if (retObj.startAngle != retObj.endAngle) {
					retObj.radius = radius;
					retObj.depth = depth;
					retObj.colorTop = colorTop;
					retObj.colorSide1 = colorSide1;
					retObj.colorSide2 = colorSide2;
					retObj.colorSide3 = colorSide3;
					retObj.tx = tx;
					retObj.ty = ty;
					ret.push(retObj);
				}
				keepStartAngle = keepAngle;
			}
			return ret;
		}
		
		
		protected function pieUnitAreaClickHandler(event:Event):void {
			var tg:Object = event.target as Object;
			
			
			if (!("objData" in tg)) {
				return;
			}
			
			var objData:Object = tg.objData;
			
			
			if (objData.toFromCenter == openGap) {
				objData.toFromCenter = 0;
			} else {
				objData.toFromCenter = openGap;
			}
			
			this.removeEventListener("enterFrame", enterFunc,false);
			this.addEventListener("enterFrame", enterFunc,false,0,true);
		}
		
		
		
		protected function rotationLocate(nAngle:Number, x1:Number, y1:Number, x0:Number=0, y0:Number=0):Point {
			//x0, y0 : 원점
			//x1, y1 : 이동할 점
			var rad:Number = nAngle / 180 * Math.PI;
			
			var ret:Point = new Point(0,0);
			ret.x = Math.cos(rad) * (x1 - x0) - Math.sin(rad) * (y1 - y0) + x0;
			ret.y = Math.sin(rad) * (x1 - x0) + Math.cos(rad) * (y1 - y0) + y0;
			return ret;
		}
	}
}