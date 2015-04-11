function listViewPhoneController() 
{
	this.fieldIdsFound = false;
	
    this.replacePhoneNumbers = function() {

        var j$ = jQuery.noConflict();
		var phIndex = 0;
		j$(document).ready(function()
		{
			//getting phone number fields for the object in context and saving it in an array
			var objDesc=''; 
			var objectPefix = window.location.href.substring( window.location.href.indexOf('.com/') + 5, window.location.href.indexOf('.com/') + 8 );
			
			var objectId = '';
			if(window.location.href.length >= (window.location.href.indexOf('.com/') + 20))
				objectId = window.location.href.substring( window.location.href.indexOf('.com/') + 5, window.location.href.indexOf('.com/') + 20 );
			
			this.fieldIdsFound = false;
			var result = sforce.connection.describeGlobal();
			var sobjects = result.getArray("sobjects");  
			for (var i=0; i<sobjects.length; i++) 
			{    
				if(sobjects[i].keyPrefix == objectPefix) 
				{ 
					var result1 = sforce.connection.describeSObject(sobjects[i].name); 
					
					if(objectPefix == "00T")
					{
						phoneFieldsName[phIndex] = "Phone";
						phoneFieldsLabel[phIndex] = "Phone";
						phIndex++;
					}
					for (var a=0; a<result1.fields.length; a++) 
					{    
						
						var field = result1.fields[a];    
						//objDesc+=field.name + ":" + field.label + ":" + field.type + '<br />';  
						
						if(objectPefix == "500" && (field.name == "SuppliedPhone" && field.label == "Phone"))
						{
							phoneFieldsName[phIndex] = "SuppliedPhone";
							phoneFieldsLabel[phIndex] = "Contact Phone";
							phIndex++;
						}
						else if(objectPefix == "003" && (field.name == "MobilePhone" && field.label == "Mobile Phone"))
						{
							phoneFieldsName[phIndex] = "MobilePhone";
							phoneFieldsLabel[phIndex] = "Mobile Phone";
							phIndex++;
							phoneFieldsName[phIndex] = "MobilePhone";
							phoneFieldsLabel[phIndex] = "Mobile";
							phIndex++;
						}
						else if(field.type == "phone")
						{
							if((field.name == "Fax" && field.label == "Business Fax") && objectPefix == "003")
							{
								phoneFieldsName[phIndex] = "Fax";
								phoneFieldsLabel[phIndex] = "Fax";
							}
							else if((field.name == "Fax" && field.label == "Account Fax") && objectPefix == "001")
							{
								phoneFieldsName[phIndex] = "Fax";
								phoneFieldsLabel[phIndex] = "Fax";
							}
							else if((field.name == "Phone" && field.label == "Business Phone") && objectPefix == "003")
							{
								phoneFieldsName[phIndex] = "Phone";
								phoneFieldsLabel[phIndex] = "Phone";
							}
							else if((field.name == "Phone" && field.label == "Account Phone") && objectPefix == "001")
							{
								phoneFieldsName[phIndex] = "Phone";
								phoneFieldsLabel[phIndex] = "Phone";
							}
							else if((field.name == "MobilePhone" && field.label == "Mobile Phone") && objectPefix == "00Q")
							{
								phoneFieldsName[phIndex] = "MobilePhone";
								phoneFieldsLabel[phIndex] = "Mobile";
							}
							else
							{
								phoneFieldsName[phIndex] = field.name;
								phoneFieldsLabel[phIndex] = field.label;
							}
							phIndex++;
						}
					}
					
					//document.getElementById('objectDesc').innerHTML=objDesc; 
				}  
			}
			
			objDesc='';  
						
			//Getting section table from record detail page
			var tables = document.getElementsByClassName('detailList');
			//alert(tables.length);
			//alert(objectId);
			for( var i = 0; i < tables.length; i++) 
			{ 
				var cols = tables[i].getElementsByTagName('td');
				//alert(cols.length);
				
				for( var j = 0; j < cols.length; j++) 
				{
					if(cols[j].className == 'labelCol')
					{
						var isPhoneField = false;
						for(var a=0; a<phoneFieldsLabel.length; a++)
						{
							if(phoneFieldsLabel[a] == cols[j].innerHTML)
							{
								isPhoneField = true;
								break;
							}
						}
						
						if(isPhoneField)
						{
							//objDesc+= cols[j].innerHTML + '=';
							j++;
							
							//objDesc+= cols[j].innerHTML + '<br />';
							//if(cols[j].innerHTML != '&nbsp;' && cols[j].innerHTML != '')
							//{
								var phoneElem = '';
								if(cols[j].innerHTML.indexOf('div') >= 0)
								{
									var divElem = cols[j].getElementsByTagName('div');
									phoneElem = divElem[0];//.innerHTML; = '<!--do not replace--><a href="#" onclick="return openCallWindow(\''+objectId+'\', \''+divElem[0].innerHTML +'\');">'+divElem[0].innerHTML +'<img src="/resource/synety__tinyPhoneIcon"/></a>';									
								}
								else
								{
									phoneElem = cols[j];//.innerHTML = '<!--do not replace--><a href="#" onclick="return openCallWindow(\''+objectId+'\', \''+cols[j].innerHTML +'\');">'+cols[j].innerHTML +'<img src="/resource/synety__tinyPhoneIcon"/></a>';
								}
							//}
							
							if(phoneElem.innerHTML != '&nbsp;' && phoneElem.innerHTML != '')
							{
								if(objectPefix == "500")
								{
									var caseresult = sforce.connection.query("Select ContactId from Case where id = '"+objectId+"'");
									var caserecord = caseresult.getArray("records");
									//alert(caserecord);
									var contactId = caserecord[0].ContactId;
									  
									phoneElem.innerHTML = '<!--do not replace--><a href="#" onclick="return openCallWindow(\''+contactId+'\', \''+ phoneElem.innerHTML +'\', \''+ objectId +'\');">'+phoneElem.innerHTML +'<img src="/resource/synety__tinyPhoneIcon"/></a>';
								}
								else
									phoneElem.innerHTML = '<!--do not replace--><a href="#" onclick="return openCallWindow(\''+objectId+'\', \''+phoneElem.innerHTML +'\');">'+phoneElem.innerHTML +'<img src="/resource/synety__tinyPhoneIcon"/></a>';
							}
						}
						
					}
					//objDesc+= i + ',' + j + '=' +cols[j].innerHTML + '<br />';  			
				}
			}
			
			//document.getElementById('objectDesc').innerHTML=objDesc; 
			
			//getting phone number html elements from related lists
			var cnt = 0; 
			var recordId = new Array(); 
			var recStart = 0; 
			var recLength = 15; 
			var datacellStr = document.getElementsByClassName(" dataRow"); 
			/*alert(datacellStr.length);*/ 
			for (var i = 0; i < datacellStr.length; i++) 
			{ 
				var thisRecordId = '';
				var nameElement = datacellStr[i].getElementsByTagName('th');
				if(nameElement.length > 0)
				{
					var recordLink = nameElement[0].getElementsByTagName('a');
					//alert(nameElement[0].innerHTML);
					//alert(recordLink);
					if(recordLink.length > 0)
					{
						thisRecordId = recordLink[0].href;
						thisRecordId = thisRecordId.substring(thisRecordId.indexOf('.com/') + 5, thisRecordId.indexOf('.com/') + 20);
						thisRecordId=thisRecordId.replace('/','');
					}
				}
				
				var phone = datacellStr[i].getElementsByClassName(" dataCell PhoneNumberElement"); 
				for (var j = 0; j < phone.length; j++) 
				{
					if(phone[j].innerHTML != '&nbsp;') 
					{ 
						/*alert('Required');*/ 
						phone[j].innerHTML = '<!--do not replace--><a href="#" onclick="return openCallWindow(\''+thisRecordId+'\', \''+phone[j].innerHTML +'\');">'+phone[j].innerHTML +'<img src="/resource/synety__tinyPhoneIcon"/></a>';
						//'<a href="" onclick="opencallWindow(\''+recordId[i]+'\', \''+phone[i].innerHTML+'\');">'+phone[i].innerHTML+'<img src="/resource/synety__tinyPhoneIcon"/></a>'; 
					} 
				}
				
			} 
			
			//getting phone number divs from listviews and changing them into the link
			var listView = document.getElementsByTagName('div'); 
			for( var i = 0; i < listView.length; i++) 
			{ 
				if(/_listBody/i.test(listView[i].id)) 
				{ 
					j$('#'+listView[i].id).bind('DOMNodeInserted DOMNodeRemoved', function(event) { 
						if (event.type == 'DOMNodeInserted') 
						{
							var textNode = event.target;
							if(typeof textNode === 'Comment')
							{
								//nothing	
							}
							else
							{
								//document.getElementById('objectDesc').innerHTML+=textNode+';'+textNode.id+';'+textNode.className+'<br />';
								//var headers = document.getElementsByClassName('x-grid3-hd-inner ');
								//alert(this.fieldIdsFound);
								
								var headers = document.getElementsByClassName('x-grid3-hd-inner ');
								if(headers.length > 0 && this.fieldIdsFound != true)
								{
									this.fieldIdsFound = true;
									//alert(headers+','+headers.length);
									for(var a=0; a<phoneFieldsLabel.length; a++)
									{
										for(var b=0; b<headers.length; b++)
										{
											//alert(headers[b].title + '==' + phoneFieldsLabel[a]);
											if(headers[b].title == phoneFieldsLabel[a])
											{
												var className = headers[b].className;
												className = className.replace("x-grid3-hd-inner x-grid3-hd-","");
												phoneFieldsId[a] = className;
											}
										}
										
										//alert(phoneFieldsId[a]+';'+phoneFieldsName[a]);
									}
								}
								
								//alert('phoneFieldsId.length='+phoneFieldsId.length);
								
								for(var z=0; z<phoneFieldsId.length; z++)
								{
									//alert(phoneFieldsId[z]);
									if (typeof phoneFieldsId[z] === "undefined") 
									{
										//do nothing
									}
									else
									{
										var phoneArray = document.getElementsByClassName("x-grid3-cell-inner x-grid3-col-"+phoneFieldsId[z]); 
										
										//var recordArray = document.getElementsByClassName("x-grid3-cell-inner x-grid3-col-Name"); 
										//if (recordArray.length == 0 ) 
										//{ 
										//	recordArray = document.getElementsByClassName("x-grid3-cell-inner x-grid3-col-FULL_NAME"); 
										//} 
										
										//document.getElementById('phoneArrayCount').innerHTML += 'Count('+phoneFieldsId[z]+') = '+phoneArray.length; 
										for(var a=0; a<phoneArray.length; a++) 
										{ 
											if(phoneArray[a].innerHTML.indexOf("<!--do not replace-->") <0 && phoneArray[a].innerHTML != '&nbsp;' ) 
											{ 
												//phoneArray[a].innerHTML = '<!--do not replace--><a href="" onclick="opencallWindow(\''+recordArray[a].id.substr(0, recordArray[a].id.indexOf("_") )+'\', \''+phoneArray[a].innerHTML+'\');">'+phoneArray[a].innerHTML+'<img src="/resource/synety__tinyPhoneIcon"/></a>';
												phoneArray[a].innerHTML = '<!--do not replace--><a href="#" onclick="return openCallWindow(\''+phoneArray[a].id.substr(0, phoneArray[a].id.indexOf("_") )+'\', \''+phoneArray[a].innerHTML+'\');">'+phoneArray[a].innerHTML+'<img src="/resource/synety__tinyPhoneIcon"/></a>';
											} 
										}   
									}
								}
							}							
						} 
					} ); 
				} 
			}
			
		});
		
		 
		//} ); 
		
		
    }
}