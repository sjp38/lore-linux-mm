Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D7E316B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 23:24:31 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so1255397pac.39
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 20:24:31 -0700 (PDT)
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
        by mx.google.com with ESMTPS id bw4si34294207pbd.160.2014.07.03.20.24.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 20:24:30 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so1258439pad.38
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 20:24:29 -0700 (PDT)
Message-ID: <53B61E6B.1030406@vflare.org>
Date: Thu, 03 Jul 2014 20:24:27 -0700
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: zsmalloc failure issue in low memory conditions
References: <77956EDC1B917843AC9B7965A3BD78B06ACB34DB39@SC-VEXCH2.marvell.com>
In-Reply-To: <77956EDC1B917843AC9B7965A3BD78B06ACB34DB39@SC-VEXCH2.marvell.com>
Content-Type: multipart/alternative;
 boundary="------------020607080201030702030305"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yonghai Huang <huangyh@marvell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>

This is a multi-part message in MIME format.
--------------020607080201030702030305
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Yonghai,

CC'ing the current maintainer, Minchan Kim.

Thanks,
Nitin

On 7/3/14, 5:03 PM, Yonghai Huang wrote:
>
> Hi, nugpta and all:
>
> Sorry to distribute you, now I met zsmalloc failure issue in very low 
> memory conditions, and i found someone already have met such issue, 
> and have had discussions, but looks like no final patch for it, i 
> don't know whether there are patches to fix it. could you give some 
> advice on it?
>
> Below is discussion link for it:
>
>
>   http://linux-kernel.2935.n7.nabble.com/zram-zsmalloc-issues-in-very-low-memory-conditions-td742009.html
>
> *//*
>
> */With kind regards,/*
>
> */Yonghai/*
>


--------------020607080201030702030305
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">Hi Yonghai,<br>
      <br>
      CC'ing the current maintainer, Minchan Kim.<br>
      <br>
      Thanks,<br>
      Nitin<br>
      <br>
      On 7/3/14, 5:03 PM, Yonghai Huang wrote:<br>
    </div>
    <blockquote
cite="mid:77956EDC1B917843AC9B7965A3BD78B06ACB34DB39@SC-VEXCH2.marvell.com"
      type="cite">
      <meta http-equiv="Content-Type" content="text/html;
        charset=ISO-8859-1">
      <meta name="Generator" content="Microsoft Word 12 (filtered
        medium)">
      <style><!--
/* Font Definitions */
@font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
h1
	{mso-style-priority:9;
	mso-style-link:"Heading 1 Char";
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:24.0pt;
	font-family:"Times New Roman","serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:#1F497D;
	font-weight:normal;
	font-style:normal;
	text-decoration:none none;}
span.Heading1Char
	{mso-style-name:"Heading 1 Char";
	mso-style-priority:9;
	mso-style-link:"Heading 1";
	font-family:"Times New Roman","serif";
	font-weight:bold;}
.MsoChpDefault
	{mso-style-type:export-only;}
.MsoPapDefault
	{mso-style-type:export-only;
	mso-margin-top-alt:auto;
	mso-margin-bottom-alt:auto;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.25in 1.0in 1.25in;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext="edit" spidmax="1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext="edit">
<o:idmap v:ext="edit" data="1" />
</o:shapelayout></xml><![endif]-->
      <div class="WordSection1">
        <p class="MsoNormal"><span
style="font-size:10.5pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#222222;background:white">Hi,
            nugpta and all:</span><o:p></o:p></p>
        <p class="MsoNormal" style="text-indent:.5in;background:white"><span
style="font-size:10.5pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#222222">Sorry
            to distribute you, now I met zsmalloc failure issue in very
            low memory conditions, and i found someone already have met
            such issue, and have had discussions, but looks like no
            final patch for it, i don't know whether there are patches
            to fix it. could you give some advice on it?<o:p></o:p></span></p>
        <p class="MsoNormal" style="background:white"><span
style="font-size:10.5pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#222222">Below
            is discussion link for it:<o:p></o:p></span></p>
        <h1
style="mso-margin-top-alt:3.0pt;margin-right:0in;margin-bottom:9.6pt;margin-left:0in;background:white"><span
style="font-size:17.5pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#465FBC"><a
              moz-do-not-send="true"
href="http://linux-kernel.2935.n7.nabble.com/zram-zsmalloc-issues-in-very-low-memory-conditions-td742009.html"
              target="_blank"><span style="color:#1155CC">http://linux-kernel.2935.n7.nabble.com/zram-zsmalloc-issues-in-very-low-memory-conditions-td742009.html</span></a></span><span
style="font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:#222222"><o:p></o:p></span></h1>
        <p class="MsoNormal" style="margin:0in;margin-bottom:.0001pt"><b><i><span
                style="font-size:10.0pt;color:#1F497D"><o:p>&nbsp;</o:p></span></i></b></p>
        <p class="MsoNormal" style="margin:0in;margin-bottom:.0001pt"><b><i><span
                style="font-size:10.0pt;color:#1F497D">With kind
                regards,</span></i></b><span
            style="font-size:12.0pt;font-family:SimSun;color:#1F497D"><o:p></o:p></span></p>
        <p class="MsoNormal"><b><i><span
                style="font-size:10.0pt;color:#1F497D">Yonghai</span></i></b><o:p></o:p></p>
      </div>
    </blockquote>
    <br>
  </body>
</html>

--------------020607080201030702030305--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
