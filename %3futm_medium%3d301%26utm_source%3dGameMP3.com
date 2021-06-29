<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>MP3Downloader.com :: mp3downloader.com</title>
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" />
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css" />
	<link rel="stylesheet" href="assets/css/media-icons.css" />
	<link rel="stylesheet" href="assets/css/style.css" />
	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
	<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function(){
					});
	</script>
		<script type="text/javascript">
	//<![CDATA[
		var conversionLogLength = 0;

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

		function updateConversionProgress(songFile)
		{
			var progress = document.getElementById('progress');
			document.getElementById('conversion-status').innerHTML = "Converting video. . .";
			$.ajax({
				type : "POST",
				url : "ffmpeg_progress.php",
				data : "uniqueId=1547800618_5c41902a638a83.42224857&logLength=" + conversionLogLength + "&mp3File=" + encodeURI(songFile),
				success : function(retVal, status, xhr) {
					var retVals = retVal.split('|');
					if (retVals[3] == 2)
					{
						progress.style.width = progress.innerHTML = parseInt(retVals[1]) + '%';
						if (parseInt(retVals[1]) < 100)
						{
							conversionLogLength = parseInt(retVals[0]);
							setTimeout(function(){updateConversionProgress(songFile);}, 10);
						}
						else
						{
							showConversionResult(songFile, retVals[2]);
						}
					}
					else
					{
						setTimeout(function(){updateConversionProgress(songFile);}, 1);
					}
				},
				error : function(xhr, status, ex) {
					setTimeout(function(){updateConversionProgress(songFile);}, 1);
				}
			});
		}

		function showConversionResult(songFile, success)
		{
			$("#preview").css("display", "none");
			var convertSuccessMsg = (success == 1) ? '<p class="alert alert-success">Success!</p><p><a class="btn btn-success" href="/index.php?mp3=' + encodeURI(songFile) + '"><i class="fa fa-download"></i> Download your MP3 file</a><br /> <br /><a class="btn btn-warning" href="/index.php"><i class="fa fa-reply"></i> Back to Homepage</a></p>' : '<p class="alert alert-danger">Error generating MP3 file!</p>';
			$("#conversionSuccess").html(convertSuccessMsg);
			//$("#conversionForm").css("display", "block");
		}

		$(document).ready(function(){
			if (!document.getElementById('preview'))
			{
				$("#conversionForm").css("display", "block");
			}

			$(function(){
			  $('[data-toggle="tooltip"]').tooltip();
			});
		});
	//]]>
	</script>	
	<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-9997026-66"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-9997026-66');
</script>
<!--cookie notice-->
<link rel="stylesheet" type="text/css" href="//cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.0.3/cookieconsent.min.css" />
<script src="//cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.0.3/cookieconsent.min.js"></script>
<script>
window.addEventListener("load", function(){
window.cookieconsent.initialise({
  "palette": {
    "popup": {
      "background": "#000"
    },
    "button": {
      "background": "transparent",
      "text": "#f1d600",
      "border": "#f1d600"
    }
  },
  "position": "top",
  "content": {
    "message": "To help personalise content, tailor your experience and help us improve our services, MP3Downloader.com (produced by LinkOrchard.com) uses cookies. By navigating our site, you agree to allow us to use these cookies.",
    "dismiss": "I get it!",
    "link": "Read our privacy policy",
    "href": "https://linkorchard.com/privacy_policy.php"
  }
})});
</script>
<!-- end cookie notice-->
	
</head>
<body>
	<nav class="navbar navbar-default navbar-aluminium">
	  <div class="container">
		<!-- Brand and toggle get grouped for better mobile display -->
		<div class="navbar-header">
		  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
			<span class="sr-only">Toggle navigation</span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
		  </button>
		  <a class="navbar-brand" href="index.php" style="color:white;">mp3downloader.com</a>
		</div>
		<!-- Collect the nav links, forms, and other content for toggling -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
		  <ul class="nav navbar-nav">
			<li class="active"><a href="index.php"><i class="fa fa-home"></i> Home</a></li>
			<!--<li><a href="about.php"><i class="fa fa-user"></i> About</a></li>-->
			<!--<li><a href="faq.php"><i class="fa fa-question"></i> FAQ</a></li>-->
			<!--<li><a href="contact.php"><i class="fa fa-envelope-o"></i> Contact</a></li>-->
		  </ul>
		</div><!-- /.navbar-collapse -->
	  </div><!-- /.container-fluid -->
	</nav>	<div class="container">
		<div class="row">
			<div class="col-lg-6 col-lg-offset-3 col-md-8 col-md-offset-2 col-sm-10 col-sm-offset-1">
				<div class="overlay">
				

				
					<div class="converter text-center" style="color:#f48024;">
						<h2><i class="fa fa-music"></i>MP3Downloader.com <i class="fa fa-music"></i></h2>
						<!--
						<p>Supported Sites: &nbsp;<span style="font-size:26px">
						-->
												
						</span></p>
						
												<form action="/index.php" method="post" id="conversionForm" style="display:none">
							<p><input type="text" class="form-control input-lg" name="videoURL" placeholder="Enter the video url (link) to convert..." /></p>
							<p><i>(i.e., "<span style="color:#337ab7">http:// or https://</span>")</i></p>
							<p style="margin-top:20px">Choose the audio file quality:</p>
							<p style="margin-bottom:25px"><input type="radio" value="64" name="quality" /> Low &nbsp; <input type="radio" value="128" name="quality" checked="checked" /> Medium &nbsp; <input type="radio" value="320" name="quality" /> High &nbsp; </p>
							<p><input type="hidden" name="formToken" value="1547800618_5c41902a638a83.42224857" /><button type="submit" name="submit" class="btn btn-primary" value="Create MP3 File" style="background:#82C013;;"><i class="fa fa-cogs"></i>Make my MP3!</button></p>
						</form>
					</div><!-- ./converter -->			
					

					
				</div><!-- ./overlay -->
				

				
			</div><!-- ./col-lg-6 -->
			

			
		</div><!-- ./row -->
	</div><!-- ./container -->
	
						<div class="banner">
						<!--
						AFFILIATE STUFF
						-->
						<!--
									
						-->
						<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- MP3Download -->
<ins class="adsbygoogle"
     style="display:block"
     data-ad-client="ca-pub-7073594926211364"
     data-ad-slot="5594325817"
     data-ad-format="auto"
     data-full-width-responsive="true"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
						
						
						</div>
	<footer class="footer">
		<div class="container-fluid">
			<div class="social-buttons">
				<div class="twitter"><a href="https://twitter.com/linkorchard"><i class="fa fa-twitter-square"></i></a></div>
				<!--<div class="facebook"><a href="#"><i class="fa fa-facebook-square"></i></a></div>
				<div class="google-plus"><a href="#"><i class="fa fa-google-plus-square"></i></a></div>-->
			</div><!-- /.social-buttons -->
			<div class="copyright">
				
				<div class="holder" style="background:#fff;"><a href="https://linkorchard.com" rel="nofollow" target="_blank">MP3Downloader.com is produced by LinkOrchard.com</a> | <a href="https://linkorchard.com/company_info.php" rel="nofollow" target="_blank">Company Info</a> | <a href="https://linkorchard.com/privacy_policy.php" rel="nofollow" target="_blank">GDPR Privacy Policy</a> | <a href="https://linkorchard.com/data_protection_policy.php" rel="nofollow" target="_blank">GDPR Data Protection Policy</a> | <a href="index.php">Home</a> |  <a href="https://linkorchard.com/support">Contact us</a> <br />
  2018 MP3Downloader.com - All rights reserved.</div>
				
				<p> 2019 mp3downloader.com</p>
			</div>
			<div class="clearfix"></div><!-- /.clearfix -->
		</div>
	</footer>
</body>
</html>