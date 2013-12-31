Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f42.google.com (mail-qe0-f42.google.com [209.85.128.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2C36B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 20:52:21 -0500 (EST)
Received: by mail-qe0-f42.google.com with SMTP id b4so12175415qen.15
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 17:52:21 -0800 (PST)
Received: from nm50.bullet.mail.bf1.yahoo.com (nm50.bullet.mail.bf1.yahoo.com. [216.109.114.67])
        by mx.google.com with ESMTPS id m3si19441293qcg.80.2013.12.30.17.52.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 30 Dec 2013 17:52:20 -0800 (PST)
References: <1388341026.52582.YahooMailNeo@web160105.mail.bf1.yahoo.com> <52C0854D.2090802@googlemail.com>
Message-ID: <1388454739.81970.YahooMailNeo@web160105.mail.bf1.yahoo.com>
Date: Mon, 30 Dec 2013 17:52:19 -0800 (PST)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: Help about calculating total memory consumption during booting
In-Reply-To: <52C0854D.2090802@googlemail.com>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="-1322375793-851798681-1388454739=:81970"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Beller <stefanbeller@googlemail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>

---1322375793-851798681-1388454739=:81970
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,=0A=0AThanks for the reply, I know about top, but top does not help much=
 in arriving at the total memory consumption.=0A=0AI need the physical memo=
ry usage breakup of each process during bootup, with a segregate of user an=
d kernel allocation.=0A=0A1) If I add up all "Pss" field in "proc/<PID>/sma=
ps, do I get the total Used memory?=0A2) Is the Pss value includes the kern=
el side allocation as well?=0A3) What fields I should choose from /proc/mem=
info" to correctly arrive at the "Used" memory in the system?=0A4) What abo=
ut the memory allocation for kernel threads during booting? Why does its Ps=
s/Rss value shows 0 always=0A=0AI already tried adding up all "PSS" values =
in every PIDs, but still it does not match any where near to the total used=
 memory in the system.=0A=0APlease help.=0A=0A=0AThanks,=0APintu=0A=0A=0A=
=0A>________________________________=0A> From: Stefan Beller <stefanbeller@=
googlemail.com>=0A>To: PINTU KUMAR <pintu_agarwal@yahoo.com>; "linux-mm@kva=
ck.org" <linux-mm@kvack.org>; "linux-kernel@vger.kernel.org" <linux-kernel@=
vger.kernel.org>; "mgorman@suse.de" <mgorman@suse.de> =0A>Sent: Monday, 30 =
December 2013 1:55 AM=0A>Subject: Re: Help about calculating total memory c=
onsumption during booting=0A> =0A>=0A>On 29.12.2013 19:17, PINTU KUMAR wrot=
e:=0A>> Hi,=0A>> =0A>> I need help in roughly calculating the total memory =
consumption in an embedded Linux system just after booting is finished.=0A>=
> I know, I can see the memory stats using "free" and "/proc/meminfo"=0A>> =
=0A>> But, I need the breakup of "Used" memory during bootup, for both kern=
el space and user application.=0A>> =0A>> Example, on my ARM machine with 1=
28MB RAM, the free memory reported is roughly:=0A>> Total: 90MB=0A>> Used: =
88MB=0A>> Free: 2MB=0A>> Buffer+Cached: (5+19)MB=0A>> =0A>> Now, my questio=
n is, how to find the breakup of this "Used" memory of "88MB".=0A>> This sh=
ould include both kernel space allocation and user application allocation(i=
ncluding daemons).=0A>> =0A>=0A>http://www.linuxatemyram.com/ dont panic ;)=
=0A>=0A>How about htop, top or=0A>"valgrind --tool massif"=0A>=0A>=0A>=0A>=
=0A>=0A>--=0A>To unsubscribe, send a message with 'unsubscribe linux-mm' in=
=0A>the body to majordomo@kvack.org.=A0 For more info on Linux MM,=0A>see: =
http://www.linux-mm.org/ .=0A>Don't email: <a href=3Dmailto:"dont@kvack.org=
"> email@kvack.org </a>=0A>=0A>=0A>
---1322375793-851798681-1388454739=:81970
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<html><body><div style=3D"color:#000; background-color:#fff; font-family:Co=
urier New, courier, monaco, monospace, sans-serif;font-size:12pt"><div>Hi,<=
/div><div><br></div><div>Thanks for the reply, I know about top, but top do=
es not help much in arriving at the total memory consumption.</div><div><br=
></div><div>I need the physical memory usage breakup of each process during=
 bootup, with a segregate of user and kernel allocation.</div><div><br></di=
v><div>1) If I add up all "Pss" field in "proc/&lt;PID&gt;/smaps, do I get =
the total Used memory?</div><div>2) Is the Pss value includes the kernel si=
de allocation as well?</div><div>3) What fields I should choose from /proc/=
meminfo" to correctly arrive at the "Used" memory in the system?</div><div>=
4) What about the memory allocation for kernel threads during booting? Why =
does its Pss/Rss value shows 0 always</div><div><br></div><div style=3D"col=
or: rgb(0, 0, 0); font-size: 16px; font-family: 'Courier New', courier,
 monaco, monospace, sans-serif; background-color: transparent; font-style: =
normal;">I already tried adding up all "PSS" values in every PIDs, but stil=
l it does not match any where near to the total used memory in the system.<=
/div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: 'Cour=
ier New', courier, monaco, monospace, sans-serif; background-color: transpa=
rent; font-style: normal;"><br></div><div style=3D"color: rgb(0, 0, 0); fon=
t-size: 16px; font-family: 'Courier New', courier, monaco, monospace, sans-=
serif; background-color: transparent; font-style: normal;">Please help.</di=
v><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: 'Courier=
 New', courier, monaco, monospace, sans-serif; background-color: transparen=
t; font-style: normal;"><br></div><div style=3D"color: rgb(0, 0, 0); font-s=
ize: 16px; font-family: 'Courier New', courier, monaco, monospace, sans-ser=
if; background-color: transparent; font-style: normal;"><br></div><div
 style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: 'Courier New',=
 courier, monaco, monospace, sans-serif; background-color: transparent; fon=
t-style: normal;">Thanks,</div><div style=3D"color: rgb(0, 0, 0); font-size=
: 16px; font-family: 'Courier New', courier, monaco, monospace, sans-serif;=
 background-color: transparent; font-style: normal;">Pintu</div><div style=
=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: 'Courier New', couri=
er, monaco, monospace, sans-serif; background-color: transparent; font-styl=
e: normal;"><br></div><div><br></div><blockquote style=3D"border-left: 2px =
solid rgb(16, 16, 255); margin-left: 5px; margin-top: 5px; padding-left: 5p=
x;">  <div style=3D"font-family: 'Courier New', courier, monaco, monospace,=
 sans-serif; font-size: 12pt;"> <div style=3D"font-family: 'times new roman=
', 'new york', times, serif; font-size: 12pt;"> <div dir=3D"ltr"> <hr size=
=3D"1">  <font size=3D"2" face=3D"Arial"> <b><span
 style=3D"font-weight:bold;">From:</span></b> Stefan Beller &lt;stefanbelle=
r@googlemail.com&gt;<br> <b><span style=3D"font-weight: bold;">To:</span></=
b> PINTU KUMAR &lt;pintu_agarwal@yahoo.com&gt;; "linux-mm@kvack.org" &lt;li=
nux-mm@kvack.org&gt;; "linux-kernel@vger.kernel.org" &lt;linux-kernel@vger.=
kernel.org&gt;; "mgorman@suse.de" &lt;mgorman@suse.de&gt; <br> <b><span sty=
le=3D"font-weight: bold;">Sent:</span></b> Monday, 30 December 2013 1:55 AM=
<br> <b><span style=3D"font-weight: bold;">Subject:</span></b> Re: Help abo=
ut calculating total memory consumption during booting<br> </font> </div> <=
div class=3D"y_msg_container"><br>On 29.12.2013 19:17, PINTU KUMAR wrote:<b=
r clear=3D"none">&gt; Hi,<br clear=3D"none">&gt; <br clear=3D"none">&gt; I =
need help in roughly calculating the total memory consumption in an embedde=
d Linux system just after booting is finished.<br clear=3D"none">&gt; I kno=
w, I can see the memory stats using "free" and "/proc/meminfo"<br clear=3D"=
none">&gt;
 <br clear=3D"none">&gt; But, I need the breakup of "Used" memory during bo=
otup, for both kernel space and user application.<br clear=3D"none">&gt; <b=
r clear=3D"none">&gt; Example, on my ARM machine with 128MB RAM, the free m=
emory reported is roughly:<br clear=3D"none">&gt; Total: 90MB<br clear=3D"n=
one">&gt; Used: 88MB<br clear=3D"none">&gt; Free: 2MB<br clear=3D"none">&gt=
; Buffer+Cached: (5+19)MB<br clear=3D"none">&gt; <br clear=3D"none">&gt; No=
w, my question is, how to find the breakup of this "Used" memory of "88MB".=
<br clear=3D"none">&gt; This should include both kernel space allocation an=
d user application allocation(including daemons).<br clear=3D"none">&gt; <b=
r clear=3D"none"><br clear=3D"none"><a shape=3D"rect" href=3D"http://www.li=
nuxatemyram.com/" target=3D"_blank">http://www.linuxatemyram.com/ </a>dont =
panic ;)<br clear=3D"none"><br clear=3D"none">How about htop, top or<br cle=
ar=3D"none">"valgrind --tool massif"<div class=3D"yqt7588509124" id=3D"yqtf=
d34938"><br clear=3D"none"><br
 clear=3D"none"><br clear=3D"none"><br clear=3D"none"><br clear=3D"none">--=
<br clear=3D"none">To unsubscribe, send a message with 'unsubscribe linux-m=
m' in<br clear=3D"none">the body to <a shape=3D"rect" ymailto=3D"mailto:maj=
ordomo@kvack.org." href=3D"mailto:majordomo@kvack.org.">majordomo@kvack.org=
.</a>&nbsp; For more info on Linux MM,<br clear=3D"none">see: <a shape=3D"r=
ect" href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linux-m=
m.org/ </a>.<br clear=3D"none">Don't email: &lt;a href=3Dmailto:"<a shape=
=3D"rect" ymailto=3D"mailto:dont@kvack.org" href=3D"mailto:dont@kvack.org">=
dont@kvack.org</a>"&gt; <a shape=3D"rect" ymailto=3D"mailto:email@kvack.org=
" href=3D"mailto:email@kvack.org">email@kvack.org</a> &lt;/a&gt;<br clear=
=3D"none"></div><br><br></div> </div> </div> </blockquote><div></div>   </d=
iv></body></html>
---1322375793-851798681-1388454739=:81970--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
