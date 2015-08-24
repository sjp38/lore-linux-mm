Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id D69DE6B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 16:46:16 -0400 (EDT)
Received: by qkda128 with SMTP id a128so37953359qkd.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 13:46:16 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0080.outbound.protection.outlook.com. [207.46.100.80])
        by mx.google.com with ESMTPS id w203si11143455ywa.60.2015.08.24.13.46.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Aug 2015 13:46:15 -0700 (PDT)
From: James Hartshorn <jhartshorn@connexity.com>
Subject: Re: Can we disable transparent hugepages for lack of a legitimate use
 case please?
Date: Mon, 24 Aug 2015 20:46:11 +0000
Message-ID: <BLUPR02MB1698B29C7908833FA1364C8ACD620@BLUPR02MB1698.namprd02.prod.outlook.com>
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>,<20150824201952.5931089.66204.70511@amd.com>
In-Reply-To: <20150824201952.5931089.66204.70511@amd.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_BLUPR02MB1698B29C7908833FA1364C8ACD620BLUPR02MB1698namp_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Bridgman, John" <John.Bridgman@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_BLUPR02MB1698B29C7908833FA1364C8ACD620BLUPR02MB1698namp_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

As a general purpose sysadmin I've mostly struggled with its default being =
always, if it were never (or possibly madvise?) then I think all the very r=
eal performance problems would go away.  Those who know they need it could =
turn it on.  I have begun looking into asking the distros to change this (i=
s it a distro choice?) but am not getting that far.  Just to be clear the d=
efault of always causes noticeable pauses of operation on almost all databa=
ses, analogous to having a stop the world gc.


As for THP in APU type applications have you run into any JEMalloc defrag p=
erformance issues?  My research into THP issues indicates this is part of t=
he performance problem that manifests for databases.


Some more links to discussion about THP:

Postgresql  https://lwn.net/Articles/591723/

Postgresql http://www.postgresql.org/message-id/20120821131254.1415a545@jek=
yl.davidgould.org

Mysql (tokudb) https://dzone.com/articles/why-tokudb-hates-transparent

Redis http://redis.io/topics/latency http://antirez.com/news/84

Oracle https://blogs.oracle.com/linux/entry/performance_issues_with_transpa=
rent_huge
MongoDB http://docs.mongodb.org/master/tutorial/transparent-huge-pages/
Couchbase http://blog.couchbase.com/often-overlooked-linux-os-tweaks
Riak http://underthehood.meltwater.com/blog/2015/04/14/riak-elasticsearch-a=
nd-numad-walk-into-a-red-hat/




________________________________
From: Bridgman, John <John.Bridgman@amd.com>
Sent: Monday, August 24, 2015 1:20 PM
To: James Hartshorn; linux-mm@kvack.org
Subject: Re: Can we disable transparent hugepages for lack of a legitimate =
use case please?

We find it useful for GPU compute applications (APU I suppose, with GPU acc=
ess via IOMMUv2) working on large datasets.

I wouldn't have expected THP to find much use for databases -- those seem t=
o be more like graphics stacks where you have enough hints about future usa=
ge to justify explicit management of pages. I thought of THP as "the soluti=
on for everything else".

From: James Hartshorn
Sent: Monday, August 24, 2015 3:12 PM
To: linux-mm@kvack.org
Subject: Can we disable transparent hugepages for lack of a legitimate use =
case please?



Hi,


I've been struggling with transparent hugepage performance issues, and can'=
t seem to find anyone who actually uses it intentionally.  Virtually every =
database that runs on linux however recommends disabling it or setting it t=
o madvise.  I'm referring to:


/sys/kernel/mm/transparent_hugepage/enabled


I asked on the internet http://unix.stackexchange.com/questions/201906/does=
-anyone-actually-use-and-benefit-from-transparent-huge-pages and got no res=
ponses there.



Independently I noticed


"sysctl: The scan_unevictable_pages sysctl/node-interface has been disabled=
 for lack of a legitimate use case.  If you have one, please send an email =
to linux-mm@kvack.org."


And thought wow that's exactly what should be done to transparent hugepages=
.


Thoughts?

--_000_BLUPR02MB1698B29C7908833FA1364C8ACD620BLUPR02MB1698namp_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<style type=3D"text/css" style=3D"display:none;"><!-- P {margin-top:0;margi=
n-bottom:0;} --></style>
</head>
<body dir=3D"ltr">
<div id=3D"divtagdefaultwrapper" style=3D"font-size:12pt;color:#000000;back=
ground-color:#FFFFFF;font-family:Calibri,Arial,Helvetica,sans-serif;">
<p>As a general purpose sysadmin I've mostly struggled with its default bei=
ng always, if it were never (or possibly madvise?) then I think all the ver=
y real performance problems would go away. &nbsp;Those who know they need i=
t could turn it on. &nbsp;I have begun looking
 into asking the distros to change this (is it a distro choice?) but&nbsp;a=
m not getting that far. &nbsp;Just to be clear the default of always causes=
 noticeable pauses of operation on almost all databases, analogous to&nbsp;=
having a stop the world gc.</p>
<p><br>
</p>
<p>As for THP in APU type applications have you run into any JEMalloc defra=
g performance issues? &nbsp;My research into THP issues indicates this is p=
art of the performance problem that manifests for databases.</p>
<p><br>
</p>
<p>Some more links to discussion about THP:</p>
<p>Postgresql &nbsp;<a href=3D"https://lwn.net/Articles/591723/" id=3D"LPln=
k473075">https://lwn.net/Articles/591723/</a></p>
<p>Postgresql&nbsp;<a href=3D"http://www.postgresql.org/message-id/20120821=
131254.1415a545@jekyl.davidgould.org" id=3D"LPlnk650709" title=3D"http://ww=
w.postgresql.org/message-id/20120821131254.1415a545@jekyl.davidgould.org=0A=
Ctrl&#43;Click or tap to follow the link">http://www.postgresql.org/message=
-id/20120821131254.1415a545@jekyl.davidgould.org</a></p>
<p>Mysql (tokudb)&nbsp;<a href=3D"https://dzone.com/articles/why-tokudb-hat=
es-transparent" id=3D"LPlnk187292">https://dzone.com/articles/why-tokudb-ha=
tes-transparent</a></p>
<p>Redis&nbsp;<a href=3D"http://redis.io/topics/latency" id=3D"LPlnk175432"=
>http://redis.io/topics/latency</a>&nbsp;<a href=3D"http://antirez.com/news=
/84" id=3D"LPlnk754827">http://antirez.com/news/84</a></p>
<div>Oracle&nbsp;<a href=3D"https://blogs.oracle.com/linux/entry/performanc=
e_issues_with_transparent_huge" id=3D"LPlnk529848">https://blogs.oracle.com=
/linux/entry/performance_issues_with_transparent_huge</a></div>
MongoDB&nbsp;<a href=3D"http://docs.mongodb.org/master/tutorial/transparent=
-huge-pages/" id=3D"LPlnk315416">http://docs.mongodb.org/master/tutorial/tr=
ansparent-huge-pages/</a><br>
<div>Couchbase&nbsp;<a href=3D"http://blog.couchbase.com/often-overlooked-l=
inux-os-tweaks" id=3D"LPlnk637621">http://blog.couchbase.com/often-overlook=
ed-linux-os-tweaks</a></div>
<div>Riak&nbsp;<a href=3D"http://underthehood.meltwater.com/blog/2015/04/14=
/riak-elasticsearch-and-numad-walk-into-a-red-hat/" id=3D"LPlnk478562" titl=
e=3D"http://underthehood.meltwater.com/blog/2015/04/14/riak-elasticsearch-a=
nd-numad-walk-into-a-red-hat/=0A=
Ctrl&#43;Click or tap to follow the link" style=3D"font-size: 12pt;">http:/=
/underthehood.meltwater.com/blog/2015/04/14/riak-elasticsearch-and-numad-wa=
lk-into-a-red-hat/</a>
<div><br>
<br>
</div>
<div><br>
</div>
<br>
<div style=3D"color: rgb(0, 0, 0);">
<hr tabindex=3D"-1" style=3D"display:inline-block; width:98%">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" co=
lor=3D"#000000" style=3D"font-size:11pt"><b>From:</b> Bridgman, John &lt;Jo=
hn.Bridgman@amd.com&gt;<br>
<b>Sent:</b> Monday, August 24, 2015 1:20 PM<br>
<b>To:</b> James Hartshorn; linux-mm@kvack.org<br>
<b>Subject:</b> Re: Can we disable transparent hugepages for lack of a legi=
timate use case please?</font>
<div>&nbsp;</div>
</div>
<div>
<div style=3D"width:100%; font-size:initial; font-family:Calibri,'Slate Pro=
',sans-serif,sans-serif; color:rgb(31,73,125); text-align:initial; backgrou=
nd-color:rgb(255,255,255)">
We find it useful for GPU compute applications (APU I suppose, with GPU acc=
ess via IOMMUv2) working on large datasets.&nbsp;</div>
<div style=3D"width:100%; font-size:initial; font-family:Calibri,'Slate Pro=
',sans-serif,sans-serif; color:rgb(31,73,125); text-align:initial; backgrou=
nd-color:rgb(255,255,255)">
<br>
</div>
<div style=3D"width:100%; font-size:initial; font-family:Calibri,'Slate Pro=
',sans-serif,sans-serif; color:rgb(31,73,125); text-align:initial; backgrou=
nd-color:rgb(255,255,255)">
I wouldn't have expected THP to find much use for databases -- those seem t=
o be more like graphics stacks where you have enough hints about future usa=
ge to justify explicit management of pages. I thought of THP as &quot;the s=
olution for everything else&quot;.</div>
<div style=3D"width:100%; font-size:initial; font-family:Calibri,'Slate Pro=
',sans-serif,sans-serif; color:rgb(31,73,125); text-align:initial; backgrou=
nd-color:rgb(255,255,255)">
<br>
</div>
<div style=3D"font-size:initial; font-family:Calibri,'Slate Pro',sans-serif=
,sans-serif; color:rgb(31,73,125); text-align:initial; background-color:rgb=
(255,255,255)">
</div>
<table width=3D"100%" style=3D"background-color:white; border-spacing:0px">
<tbody>
<tr>
<td colspan=3D"2" style=3D"font-size:initial; text-align:initial; backgroun=
d-color:rgb(255,255,255)">
<div style=3D"border-style:solid none none; border-top-color:rgb(181,196,22=
3); border-top-width:1pt; padding:3pt 0in 0in; font-family:Tahoma,'BB Alpha=
 Sans','Slate Pro'; font-size:10pt">
<div><b>From: </b>James Hartshorn</div>
<div><b>Sent: </b>Monday, August 24, 2015 3:12 PM</div>
<div><b>To: </b>linux-mm@kvack.org</div>
<div><b>Subject: </b>Can we disable transparent hugepages for lack of a leg=
itimate use case please?</div>
</div>
</td>
</tr>
</tbody>
</table>
<div style=3D"border-style:solid none none; border-top-color:rgb(186,188,20=
9); border-top-width:1pt; font-size:initial; text-align:initial; background=
-color:rgb(255,255,255)">
</div>
<br>
<div>
<div id=3D"divtagdefaultwrapper" style=3D"font-size:12pt; color:#000000; ba=
ckground-color:#FFFFFF; font-family:Calibri,Arial,Helvetica,sans-serif">
<p>Hi,</p>
<p><br>
</p>
<p>I've been struggling with transparent hugepage performance issues, and c=
an't seem to find anyone who actually uses it intentionally. &nbsp;Virtuall=
y every database that runs on linux however recommends disabling it or sett=
ing it to madvise. &nbsp;I'm referring to:</p>
<p><br>
</p>
<p>/sys/kernel/mm/transparent_hugepage/enabled<br>
</p>
<p><br>
</p>
<p>I asked on the internet&nbsp;<a href=3D"http://unix.stackexchange.com/qu=
estions/201906/does-anyone-actually-use-and-benefit-from-transparent-huge-p=
ages" id=3D"LPlnk636904" title=3D"http://unix.stackexchange.com/questions/2=
01906/does-anyone-actually-use-and-benefit-from-transparent-huge-pages=0A=
Ctrl&#43;Click or tap to follow the link">http://unix.stackexchange.com/que=
stions/201906/does-anyone-actually-use-and-benefit-from-transparent-huge-pa=
ges</a>&nbsp;and
 got no responses there. &nbsp;</p>
<br>
<p><br>
</p>
<p>Independently I noticed&nbsp;</p>
<p><br>
</p>
<p>&quot;sysctl: The scan_unevictable_pages sysctl/node-interface has been =
disabled for lack of a legitimate use case. &nbsp;If you have one, please s=
end an email to linux-mm@kvack.org.&quot;</p>
<p><br>
</p>
<p>And thought wow that's exactly what should be done to transparent hugepa=
ges. &nbsp;</p>
<p><br>
</p>
<p>Thoughts? &nbsp;<span style=3D"font-size:12pt"></span></p>
</div>
</div>
</div>
</div>
</div>
</div>
</body>
</html>

--_000_BLUPR02MB1698B29C7908833FA1364C8ACD620BLUPR02MB1698namp_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
