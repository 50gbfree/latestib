<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
	<meta name="description" content="Download and Convert your favorite online videos and audio to MP3, MP4, WEBM, F4V, and 3GP formats for free!" /><meta name="keywords" content="The,Best,YouTube,to,MP3,Converter" /><meta property="og:image" content="http://mp3downloader.com/css/images/default-share-image.jpg" /><title>The Best YouTube to MP3 Converter - MP3Downloader.com</title>	<link rel="stylesheet" type="text/css" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/themes/base/jquery-ui.css" />
	<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" />
	    <link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" />
    <link rel="stylesheet" type="text/css" href="css/media-icons.css" />
    <link rel="stylesheet" type="text/css" href="css/flag-icon.css" />
			<link rel="stylesheet" type="text/css" href="css/prettySocial.css" />
		<link rel="stylesheet" type="text/css" href="css/colorbox.css" />
		<link rel="stylesheet" type="text/css" href="css/custom.css">
	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
	<script type="text/javascript" src="js/jquery.ui.touch-punch.min.js"></script>
	<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
			<script type="text/javascript" src="js/jquery.colorbox-min.js"></script>
		<script type="text/javascript" src="js/jquery.prettySocial.min.js"></script>
		<script type="text/javascript" src="js/jquery.cookie.js"></script>
		<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/modernizr/2.7.1/modernizr.min.js"></script>
	<script type="text/javascript" src="https://ws.sharethis.com/button/buttons.js"></script>
			<script type="text/javascript" src="js/navbar_language_fix.js" id="navbar-lang-fix" more="More" langMenuPosition="right"></script>
		<script type="text/javascript">
		var conversionLogLength = 0;
		var conversionInProgress = false;
		var failedAjaxRequests = 0;
		var maxAjaxRequestTries = 20;
		var conversionStopping = false;
		var timer;

		function updateVideoDownloadProgress(percentage, isRealTime)
		{
			percentage = parseInt(percentage);
			if (isRealTime)
			{
				$("#progress").css("width", percentage + "%").html(percentage + "%");
			}
			else
			{
				$("#progress").addClass("progress-striped").css("width", percentage + "%").html("&nbsp;");
			}
		}

		function updateConversionProgress(convertedFile, convertedFileNiceName, tempFileType, vidTitle)
		{
			conversionInProgress = true;
			var progress = document.getElementById('progress');
			document.getElementById('conversion-status').innerHTML = "Converting file. . .";
			$.ajax({
				type : "POST",
				url : "ffmpeg_progress.php",
				data : "uniqueId=1499601765_59621b65bc33c3.07994033&logLength=" + conversionLogLength + "&convertedFile=" + encodeURI(convertedFile) + "&tempFileType=" + encodeURI(tempFileType),
				success : function(retVal, status, xhr) {
					var retVals = retVal.split('|');
					if (retVals[3] == 2)
					{
						progress.style.width = progress.innerHTML = parseInt(retVals[1]) + '%';
						if (parseInt(retVals[1]) < 100)
						{
							conversionLogLength = parseInt(retVals[0]);
							if (!conversionStopping)
							{
								timer = setTimeout(function(){updateConversionProgress(convertedFile, convertedFileNiceName, tempFileType, vidTitle);}, 500);
							}
						}
						else
						{
							conversionInProgress = false;
							validateConvertedFile(convertedFile, convertedFileNiceName, vidTitle, retVals[2]);
						}
					}
					else
					{
						if (++failedAjaxRequests < maxAjaxRequestTries && !conversionStopping)
						{
							timer = setTimeout(function(){updateConversionProgress(convertedFile, convertedFileNiceName, tempFileType, vidTitle);}, 100);
						}
						else
						{
							conversionInProgress = false;
							validateConvertedFile(convertedFile, convertedFileNiceName, vidTitle, 2);
						}
					}
				},
				error : function(xhr, status, ex) {
					if (++failedAjaxRequests < maxAjaxRequestTries && !conversionStopping)
					{
						timer = setTimeout(function(){updateConversionProgress(convertedFile, convertedFileNiceName, tempFileType, vidTitle);}, 100);
					}
					else
					{
						conversionInProgress = false;
						validateConvertedFile(convertedFile, convertedFileNiceName, vidTitle, 2);
					}
				}
			});
		}

		function showConversionResult(convertedFile, convertedFileNiceName, vidTitle, success)
		{
			$("#preview").css("display", "none");
			var convertSuccessMsg = '';
			if (success == 1)
			{
				var isEditableRegex = new RegExp('(\.(webm|mp4|mp3|aac|m4a|f4v))$', 'i');
				var isEditable = isEditableRegex.test(convertedFile);
				        		convertSuccessMsg += '<p class="bg-success padding-msg"><b><i class="fa fa-thumbs-up"></i> Success!</b></p>';
        		convertSuccessMsg += '<p><img src="" alt="preview image" style="width:150px" /></p>';
        		convertSuccessMsg += '<p dir="ltr"><b></b></p>';
        		convertSuccessMsg += '<h4 style="margin-bottom:15px;text-transform:uppercase;"><span class="label label-default"></span></h4>';
        		convertSuccessMsg += '<p><a class="btn btn-success download-buttons" href="http://mp3downloader.com/index.php?output=' + (encodeURI(convertedFile)).replace(/~/g, "%7e") + '" onclick="showShareButtonsWindow(this.href, false); return false;"><i class="fa fa-download"></i> Download your converted file</a></p>';
								        		convertSuccessMsg += (isEditable) ? '<p><a id="editFurtherButton" class="btn btn-warning download-buttons" href="edit.php?vid_name=' + encodeURI(convertedFile) + '&vid_title=' + encodeURI(vidTitle) + '&vid_id=&vid_image=&vid_host=" title="Crop file and/or Edit file info (i.e., title, artist, etc.)."><i class="fa fa-scissors"></i> Edit file further</a></p>' : '';
        		convertSuccessMsg += '<p><a class="btn btn-danger download-buttons" href="http://mp3downloader.com/"><i class="fa fa-reply"></i> Return to homepage.</a></p>';
			}
			else
			{
        		convertSuccessMsg = '<p class="bg-danger padding-msg"><i class="fa fa-exclamation-triangle"></i> Error generating converted file!<br /><br /><a href="http://mp3downloader.com/">Please, try again.</a></p>';
			}
			$("#conversionSuccess").html(convertSuccessMsg).find("#dropboxLink, #onedriveLink, #editFurtherButton").each(function(){
				if ($(this).attr("id") == "editFurtherButton")
				{
					$(this).tooltip();
				}
				else
				{
										
					$(this).click(function() {
						saveToCloud($(this), convertedFileNiceName);
						return false;
					});
				}
			});
		}
		
		function validateConvertedFile(convertedFile, convertedFileNiceName, vidTitle, succeeded)
		{
			$.ajax({
				type : "POST",
				url : "ffmpeg_validate.php",
				data : "convertedFile=" + encodeURI(convertedFile) + "&duration=&succeeded=" + encodeURI(succeeded),
				success : function(retVal, status, xhr) {
					succeeded = parseInt(retVal);
					showConversionResult(convertedFile, convertedFileNiceName, vidTitle, succeeded);
				},
				error : function(xhr, status, ex) {
					showConversionResult(convertedFile, convertedFileNiceName, vidTitle, succeeded);
				}
			});		
		}

		function saveToCloud(buttonObj, convertedFileNiceName)
		{
			var options = {
				success: function() {
					// Indicate to the user that the file has been saved.
					buttonObj.html('<span class="fa fa-check" style="color:#fff"></span> ' + buttonObj.text());
				},
				progress: function(progress) {
					buttonObj.html('<span class="fa fa-refresh fa-spin" style="color:#fff"></span> ' + buttonObj.text());
				},
				error: function(errorMessage) {
					buttonObj.html('<span class="fa fa-exclamation-triangle" style="color:red"></span> ' + buttonObj.text());
				}
			};
			switch (buttonObj.attr("id"))
			{
				case "dropboxLink":
					Dropbox.save(buttonObj.attr("href"), convertedFileNiceName, options);
					break;
				case "onedriveLink":
					options.file = buttonObj.attr("href");
					options.fileName = convertedFileNiceName;
					OneDrive.save(options);
					break;
			}
		}

		function stopConversion()
		{
			var redirectUrl = 'http://mp3downloader.com/index.php';
			if (!conversionStopping)
			{
				failedAjaxRequests = 0;
				clearTimeout(timer);
				conversionStopping = true;
			}
			if (conversionInProgress)
			{
				$.ajax({
					type : "POST",
					url : "ffmpeg_stop.php",
					data : "token=1499601765_59621b65bc33c3.07994033",
					success : function(retVal, status, xhr) {
						window.location.href = redirectUrl;
					},
					error : function(xhr, status, ex) {
						if (++failedAjaxRequests < maxAjaxRequestTries)
						{
							timer = setTimeout(function(){stopConversion();}, 100);
						}
					}
				});
			}
			else
			{
				window.location.href = redirectUrl;
			}
		}

		// If this is iframe, and parent receives URL-initiated conversion request, forward request to iframe
		if (window.location != window.parent.location)
		{
			if (parent.location.search != "")
			{
				var queryStrParams = [];
				var queryStrParts = parent.location.search.replace(/\?/, "").split("&");
				for (var i=0; i<queryStrParts.length; i++)
				{
					queryStrParams.push(queryStrParts[i].split("=")[0]);
				}
				if (($.inArray('vidHost', queryStrParams) != -1 && $.inArray('vidID', queryStrParams) != -1) || $.inArray('url', queryStrParams) != -1)
				{
					var iframeQueryStr = parent.location.search;
					parent.history.replaceState("object or string", "Title", "/");
					window.location.href = window.location.href.replace(/\?.*/, "") + iframeQueryStr;
				}
			}
		}

		$(document).ready(function(){
			$(function(){
				$('[data-toggle="tooltip"]').tooltip();
			});
			$("#volumeSlider").slider({
				range: "min",
				min: 0,
				max: 1024,
				value: 256,
				slide: function(event, ui) {
					var percent = Math.floor((ui.value / 256) * 100);
					$("#volumeVal").html(percent + '%');
					$("input[name='volume']").val(ui.value);
				}
			});
			$("#toggleOptionsDisplay span").click(function(){
				$("#moreOptions").toggle('fast', function(){
					var linkText = ($(this).css('display') == 'none') ? "Show more options &#187;" : "Hide more options &#171;";
					$("#toggleOptionsDisplay span").html(linkText);
				});
			});
			(function(){
				var siteNames = $(".siteNames");
				var examples = $("#examples span");
				var exampleIndex = -1;
				function animateIt(elementGroup){
					var nextFuncCall = (elementGroup != examples) ? showNextExample : null;
					elementGroup.eq(exampleIndex)
						.fadeIn({
							duration: 700
						})
						.delay(6000)
						.fadeOut(700, nextFuncCall);
				}
				function showNextExample(){
					exampleIndex = (++exampleIndex > examples.length - 1) ? 0 : exampleIndex;
					animateIt(siteNames);
					animateIt(examples);
				}
				showNextExample();
			})();
			if (typeof stLight != "undefined")
			{
				stLight.options({publisher: "INSERT_PUBLIC_KEY_HERE", doNotHash: true, doNotCopy: false, hashAddressBar: false});
			}
			if (!document.getElementById('preview'))
			{
				$("#conversionForm").css("display", "block");
			}
			$("#videoURL").focus();
		});
	</script><!---google-analytics---alan--->
  <script>
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

    ga('create', 'UA-9997026-66', 'auto');
    ga('send', 'pageview');

  </script>
</head>
<body dir="ltr">
	<!--Navbar -->
	<nav class="navbar navbar-default bluebar">
		<div class="container-fluid">
			<!-- Brand and toggle get grouped for better mobile display -->
			<div class="navbar-header">
				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
					<span class="sr-only">Toggle navigation</span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>				</button>
				<a class="navbar-brand" href="http://mp3downloader.com/"> MP3Downloader.com </a>			</div>
			<!-- Collect the nav links, forms, and other content for toggling -->
			<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
				<ul id="menuPageLinks" class="nav navbar-nav">
										<li class="active"><a href="index.php"><i class="fa fa-home"></i>Home</a></li>
					<!--<li><a href="faq.php"><i class="fa fa-question"></i>FAQ</a></li>
					<li><a href="plugin.php"><i class="fa fa-plug"></i>Get Plugin</a></li>
					<li><a href="about.php"><i class="fa fa-user"></i>About</a></li>
					<li><a href="contact.php"><i class="fa fa-envelope-o"></i>Contact</a></li>-->				</ul>
				<ul class="nav navbar-nav navbar-right">
					<li class="dropdown">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><span class="flag-icon flag-icon-us"></span> US<span class="caret"></span></a>						<ul class="dropdown-menu" role="menu">
						<li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=DE"><span class="flag-icon flag-icon-de"></span>&nbsp;&nbsp;Deutsch</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=US"><span class="flag-icon flag-icon-us"></span>&nbsp;&nbsp;English (US)</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=ES"><span class="flag-icon flag-icon-es"></span>&nbsp;&nbsp;Español</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=FR"><span class="flag-icon flag-icon-fr"></span>&nbsp;&nbsp;Français</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=HR"><span class="flag-icon flag-icon-hr"></span>&nbsp;&nbsp;Hrvatski</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=IT"><span class="flag-icon flag-icon-it"></span>&nbsp;&nbsp;Italiano</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=LT"><span class="flag-icon flag-icon-lt"></span>&nbsp;&nbsp;Lietuvių</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=HU"><span class="flag-icon flag-icon-hu"></span>&nbsp;&nbsp;Magyar</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=PH"><span class="flag-icon flag-icon-ph"></span>&nbsp;&nbsp;Pilipino</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=PL"><span class="flag-icon flag-icon-pl"></span>&nbsp;&nbsp;Polski</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=PT"><span class="flag-icon flag-icon-pt"></span>&nbsp;&nbsp;Português</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=RU"><span class="flag-icon flag-icon-ru"></span>&nbsp;&nbsp;Pусский</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=RO"><span class="flag-icon flag-icon-ro"></span>&nbsp;&nbsp;Română</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=FI"><span class="flag-icon flag-icon-fi"></span>&nbsp;&nbsp;Suomi</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=TR"><span class="flag-icon flag-icon-tr"></span>&nbsp;&nbsp;Türkce</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=GR"><span class="flag-icon flag-icon-gr"></span>&nbsp;&nbsp;ελληνικά</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=BG"><span class="flag-icon flag-icon-bg"></span>&nbsp;&nbsp;Български</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=SA"><span class="flag-icon flag-icon-sa"></span>&nbsp;&nbsp;عربي</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=IN"><span class="flag-icon flag-icon-in"></span>&nbsp;&nbsp;हिन्दी</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=CN"><span class="flag-icon flag-icon-cn"></span>&nbsp;&nbsp;中国</a></li><li><a dir="ltr" href="http://mp3downloader.com/index.php?utm_medium=301&utm_source=ClickMP3.com&ccode=JP"><span class="flag-icon flag-icon-jp"></span>&nbsp;&nbsp;日本の</a></li>						</ul>
					</li>
				</ul>
			</div><!-- /.navbar-collapse -->
		</div><!-- /.container-fluid -->
	</nav>
	<div class="container">
		<!-- Converter Box -->
		<div class="row">
			<div class="col-lg-8 col-lg-offset-2">
				<div class="converter-box text-center bg-white">
					<div class="converter converter2 text-center">
												<form action="/index.php" method="post" id="conversionForm" style="display:none">
              <h3 class="alan2">
Welcome to MP3Downloader.com.              </h3>
              <div class="alan1">
Firstly, enter the video link you wish to convert...
             <translation name="Downloading_Process_Message">
              </div>
							<div class="supported-portals" dir="ltr">
														</div>
							<div class="alancontainer">
									<div class="input-group" style="width:100%">
										<span class="input-group-addon" style="border-color:#ccc"><i class="fa fa-globe fa-fw"></i></span>
										<input type="text" id="videoURL" name="videoURL" class="form-control bg-light-gray" style="width:100%;"/>
									</div>
							</div>

                <!--snippet2 start--->
                                </p>
              <!---snippet 2 end--->

							<p class="file-type-text">Choose file type to convert to:</p>
							<select class="form-control input-lg bg-light-gray" name="ftype" id="ftype">
							<optgroup dir="ltr" label="audio"><option dir="ltr" value="5">.aac</option><option dir="ltr" value="6">.m4a</option><option dir="ltr" value="3" selected="selected">.mp3 (128kb)</option><option dir="ltr" value="4">.mp3 (256kb)</option></optgroup><optgroup dir="ltr" label="video"><option dir="ltr" value="8">.3gp</option><option dir="ltr" value="2">.mp4</option><option dir="ltr" value="7">.f4v</option><option dir="ltr" value="1">.webm</option></optgroup>							</select>
							<div id="moreOptions" class="margin-top-10" style="display:none" align="center">
								<p>Volume control: (<span id="volumeVal">100%</span>)</p>
								<p id="volumeSlider"></p>
								<input type="hidden" name="volume" />
							</div>
							<div id="toggleOptionsDisplay"><span>Show more options &#187;</span></div>
							<button type="submit" name="submitForm" class="btn btn-success btn-lg"><i class="fa fa-cogs"></i> Convert It!</button><input type="hidden" name="formToken" value="1499601765_59621b65bc33c3.07994033" />
						</form>

            <div class="alan1">
              <p>What we do.</p>
              <p>Okay so we're like an mp3 downloader.  What's that when it's not at home?  It takes a video from the web, and it makes into an MP3.</p>
              <p>Really that's it!</p>
              <p>Stay tuned as we hope to bring in a section where you can get your videos featured for free on the site.  That's a bit further down the line.  But we'll hopefully get there :)</p>
            </div>
          </p>
    			</div>


											</div>
				</div>
		</div>





				<!-- Info boxes -->
		
		<!-- Alan note: this is the boxes code from Randall.  I'm deleting it all.  See Folder v6 Randall fixes again! if u want to put the boxes back in-->
		
		
		
	<!-- Fixed Footer -->
	<footer class="footer">
		<div class="container-fluid">
			<div class="social-buttons" dir="ltr">
				<span class='st_fblike_hcount' displayText='Facebook Like'></span>
				<span class='st_twitterfollow_hcount' displayText='Twitter Follow' st_username='YourTwitterName'></span>
				<span class='st_plusone_hcount' displayText='Google +1'></span>
			</div><!-- /.social-buttons -->
			<div class="copyright" dir="ltr">
				<p>&copy; 2017 MP3Downloader.com</p>
			</div>
			<div class="clearfix"></div><!-- /.clearfix -->
		</div>
	</footer>
</body>
</html>