Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4EDDD6B0030
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 05:19:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q65so10891733pga.15
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 02:19:09 -0700 (PDT)
Received: from baidu.com ([220.181.50.185])
        by mx.google.com with ESMTP id r6-v6si900062pls.51.2018.03.27.02.19.08
        for <linux-mm@kvack.org>;
        Tue, 27 Mar 2018 02:19:08 -0700 (PDT)
From: "Li,Rongqing" <lirongqing@baidu.com>
Subject: Too easy OOM
Date: Tue, 27 Mar 2018 09:19:02 +0000
Message-ID: <2AD939572F25A448A3AE3CAEA61328C23750D4E0@BC-MAIL-M28.internal.baidu.com>
Content-Language: zh-CN
Content-Type: multipart/alternative;
	boundary="_000_2AD939572F25A448A3AE3CAEA61328C23750D4E0BCMAILM28intern_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--_000_2AD939572F25A448A3AE3CAEA61328C23750D4E0BCMAILM28intern_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Current kernel version is too easy to trigger OOM, is it normal?

# echo $$ > /cgroup/test/tasks
# echo 200000000 >/cgroup/test/memory.limit_in_bytes
# dd if=3Daaa  of=3Dbbb  bs=3D1k count=3D3886080
Killed

--_000_2AD939572F25A448A3AE3CAEA61328C23750D4E0BCMAILM28intern_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
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
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-justify:inter-ideograph;
	font-size:10.5pt;
	font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri",sans-serif;}
/* Page Definitions */
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"ZH-CN" link=3D"#0563C1" vlink=3D"#954F72" style=3D"text-justi=
fy-trim:punctuation">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US">Current kernel version is too e=
asy to trigger OOM, is it normal?<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"># echo $$ &gt; /cgroup/test/tas=
ks<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"># echo 200000000 &gt;/cgroup/te=
st/memory.limit_in_bytes<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"># dd if=3Daaa&nbsp; of=3Dbbb&nb=
sp; bs=3D1k count=3D3886080<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Killed<o:p></o:p></span></p>
</div>
</body>
</html>

--_000_2AD939572F25A448A3AE3CAEA61328C23750D4E0BCMAILM28intern_--
