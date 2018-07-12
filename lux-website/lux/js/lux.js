//This is used to slide matches up/down (i.e., hide/show them) via the red arrow
function SlideRows(element, rows, wwwRoot)
{
	myImg=document.getElementById(element);

	if(myImg.name =="arrow-down.gif")
	{
		myImg.src = wwwRoot + "/images/arrow-side.gif";
		myImg.name = "arrow-side.gif";
		Effect.BlindUp(rows);; return false;		
	}

	else
	{
		myImg.src = wwwRoot + "/images/arrow-down.gif";
		myImg.name = "arrow-down.gif";
		Effect.BlindDown(rows);; return false;
	}
}

//Reset the config input form values to defaults/examples
function resetLuxConfig(luxConfig)
{
	luxConfig.searchRoot.value = "/usr/local/apache2/htdocs";
	luxConfig.indexRoot.value = "/usr/local/apache2/htdocs";
	luxConfig.wwwRoot.value = "/lux";
	luxConfig.cgiRoot.value = "/cgi-bin/lux";
	luxConfig.fileExtensions.value = ".php, .htm, .html, .tpl, .inc, .js, .css, .sql";
	luxConfig.database.value = "luxphp";
	luxConfig.host.value = "localhost";
	luxConfig.port.value = "3306";
	luxConfig.username.value = "username";
	luxConfig.password.value = "password";
}

var addBookmarkCallback =
{
        success: function(o)
                 {
                        //alert("Bookmark has been added");
			var tagImage = document.getElementById("b_" + o.argument);
			tagImage.setAttribute("src", "/lux/images/tag_red.png");

			var tagHref = document.getElementById("a_" + o.argument);
			tagHref.setAttribute("href", "javascript:openWindow('viewBookmarks.pl?id=" + o.argument + "');");
                 },
        failure: function(o)
                 {
                        alert("There was a problem with the URL.");
                 },
        argument: ''
};

//Adds a bookmark
function addBookmark(strFile, intProjectID, intLineNumber, strQuery)
{
	strQuery = strQuery.replace(/\$/g, "\\$");
	strQuery = strQuery.replace(/\'/g, "\\'");
	strQuery = strQuery.replace(/\"/g, "\\\"");

        var url = "/pl/lux/bookmarks.pl?intProjectID=" + intProjectID + "&strQuery=" + strQuery + "&strFile=" + strFile + "&intLineNumber=" + intLineNumber;
	addBookmarkCallback.argument = intLineNumber;
        var transaction = YAHOO.util.Connect.asyncRequest('GET', url, addBookmarkCallback, null);
}

var updateProjAssocCallback =
{
        success: function(o)
                 {
			alert("Association has been updated");
                 },
        failure: function(o)
                 {
                        alert("There was a problem with the URL.");
                 },
        argument: ''
};

//Updates a project association for a file
function updateProjectAssociation(strFile, strProject)
{
	var url = "/pl/lux/projects.pl?strFile=" + strFile + "&strProject=" + strProject;
	var transaction = YAHOO.util.Connect.asyncRequest('GET', url, updateProjAssocCallback, null);
}

//Displays an element
function displayElement(element)
{
	myElement=document.getElementById(element);
	myElement.style.display="block";
}

//Opens a new window. Needed to avoid [object window] (window.open returns undefined)
function openWindow(url, name, options)
{
	window.open(url, name, options);
}

//Opens a new window. Needed to avoid [object window] (window.open returns undefined)
function openBookmarksWindow(url, name, options)
{
        var project = document.getElementById("lux_projectsDropDownSearchID");
        var projectID = project.options[project.selectedIndex].value;

        url = url + "&p=" + projectID;

        window.open(url, name, options);
}

//Like the prior function, but gets the project ID and appends it to the url first
function openNotesWindow(url, name, options)
{
	var project = document.getElementById("lux_projectsDropDownSearchID"); 
	var projectID = project.options[project.selectedIndex].value;

	url = url + "&p=" + projectID;

        window.open(url, name, options);
}

//
//Image rollover code
//
function MM_swapImgRestore()
{
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages()
{
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d)
{
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage()
{
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
