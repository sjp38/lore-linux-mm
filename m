Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DC02B6B00EE
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 04:58:04 -0400 (EDT)
References: <1309446135.48907.YahooMailNeo@web162020.mail.bf1.yahoo.com> <20110701065120.GA29530@suse.de>
Message-ID: <1311065882.85318.YahooMailNeo@web162013.mail.bf1.yahoo.com>
Date: Tue, 19 Jul 2011 01:58:02 -0700 (PDT)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Reply-To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: Re: JPEG image creation to display physical page state and memory fragmentation
In-Reply-To: <20110701065120.GA29530@suse.de>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="0-709411929-1311065882=:85318"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Mel Gorman <mgorman@suse.de>

--0-709411929-1311065882=:85318
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=0ADear All,=0A=A0=0AI wanted to represent the physical page state=
 of memory in the form of an image.=0AThe physical page state information s=
uch as free pages, movable pages, reclaimable pages are taken from /proc/pa=
getypeinfo.=0A(I know the buddyinfo and pagetypeinfo data may not be accura=
te/insufficient but that is ok for me)=0A=A0=0AThese data will be used to c=
reate a YUV image and then can be converted to a jpeg image.=0AThe image sh=
ould clearly display the following(for each zone):-=0A- total free pages av=
ailable --> in grey color=0A- total movable pages=A0=A0=A0=A0=A0=A0=A0 --> =
in Red color- total=A0reclaimable pages=A0=A0=A0 --> in=A0Blue color=0AHere=
 each page will be represented by a pixel dot of different color.=0AA separ=
ate image will be created for each zone.=0AI know how to create a raw YUV i=
mage, but I am confused how to prepare an image layout based on the page-or=
der and the total free page available.=0AIt could be as similar as the anti=
-fragmentation page distribution image from below article from Mel Gorman.=
=0Ahttp://lwn.net/Articles/224835/=0Ahttp://www.skynet.ie/~mel/anti-frag/20=
07-02-28/page_type_distribution.jpg=0ABut I am not able to understand how t=
his image is formed.=0AFrom these image I am not able to find how many orde=
r-n pages are free, movable and reclaimable.=0AIn the above image the block=
 size is 32x32 and the image layout is (32x32) x (32x32) =3D 1024x1024=0AAl=
so each pixel represent one page in memory.=0ABut I am not able to understa=
nd how this pixels are filled into the blocks.=0A=A0=0AI=A0wanted to create=
 an image to show memory fragmentation under each zone.=0AIf anybody has do=
ne similar kind of work please let me know.=0A=A0=0AI have already=A0develo=
ped a sample utility in linux to create=A0a dummy yuv420 image but could no=
t able to figure out how to fill the pixels into the image.=0AMy yuv progra=
m takes input as totalfreepages, totalmovablepages, totalreclaimablepages.=
=0A=A0=0AMy system details are as folows:=0A- linux mobile running on ARM C=
ortex-A9.=0A- total available RAM =3D 888MB=0A- Page size =3D 4K=0A- Page b=
lock size =3D 1024 (from pagetypeinfo)=0A- page-order (0 to 10)=A0=A0=A0 (f=
rom buddyinfo or pagetypeinfo)=0A=A0=0A=A0=0AThanks, Regards,=0APintu=0A=A0=
=0A=0AFrom: Mel Gorman <mgorman@suse.de>=0ATo: Pintu Agarwal <pintu_agarwal=
@yahoo.com>=0ASent: Friday, 1 July 2011 12:21 PM=0ASubject: Re: JPEG image =
creation for memory fragmentation=0A=0AOn Thu, Jun 30, 2011 at 08:02:15AM -=
0700, Pintu Agarwal wrote:=0A=0A> I need to create a sample jpeg image for =
displaying page states=0A> and fragmentation info across each zone by colle=
cting data from=0A> /proc/buddyinfo and /proc/pagetypeinfo a one instance o=
f time.=0A>=0A> I saw your article about anti-fragmentation and page type d=
istribution in the form of image from the following links:-=0A> http://lwn.=
net/Articles/224835/=0A> http://www.skynet.ie/~mel/anti-frag/2007-02-28/pag=
e_type_distribution.jpg=0A> =A0=0A> I wanted to understand, I to create the=
 similar image using my data=0A> from buddyinfo and pagetypeinfo in my case=
.=0A=0AThere is insufficient data from buddyinfo and pagetypeinfo to genera=
te=0Athe image linked above.=0A=0A> What logic you used for creating these =
images?=0A=0AI used a perl script reading information via a kernel module a=
nd=0Acreating the image with libgd. If I was doing it again, I would=0Aread=
 the necessary information from /proc/kpageflags. If I needed=0Aa greater d=
egree of accuracy, I would patch the kernel to expand on=0Athe information =
available in /proc/kpageflags.=0A=0A> How did you use the buddyinfo data to=
 form this image?=0A=0AI didn't use buddyinfo.=0A=0A> Can you give some det=
ails about it?=0A> =A0=0A> Like your aticle I am also defining the followin=
g:-=0A> - Each block size is 1024=0A> - Each page is one pixel=0A> - Free p=
age will be gray color=0A> - Movable page will be green color=0A> - Reclaim=
able page will be blue color=0A> - And (I dont want zoneboundary, percpu, p=
inned pages etc in the image)=0A> =A0=0A> Now suppose my system page state =
at some point of time looks like this:-=0A> -------------------------------=
----------------------------------------------------------=0A> Node:1, Zone=
:DMA=0A> Order=A0=A0=A0 FreePages=A0=A0=A0=A0=A0=A0 MovablePages=A0=A0=A0 R=
eclaimablePages=A0=A0=A0=A0=A0=A0=A0 Fragmentation[%]=0A> =A0 0=A0=A0=A0=A0=
=A0=A0=A0=A0 38=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 36=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0%=0A> =A0 1=A0=A0=A0=A0=A0=A0=A0=A0 59=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 55=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 0%=0A> =A0 2=A0=A0=A0=A0=A0=A0=A0=A0 40=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 32=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 2%=0A> =A0 3=A0=A0=A0=A0=A0=A0=A0=A0 19=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 16=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 4%=0A> =A0 =
4=A0=A0=A0=A0=A0=A0=A0=A0 12=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 10=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 6%=0A> =A0 5=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 2=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 9%=0A> =A0 6=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 6=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 11%=0A> =A0 7=A0=A0=A0=A0=A0=A0=A0=A0=A0 7=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 16%=0A> =A0 8=A0=A0=A0=A0=A0=A0=A0=A0=A0 7=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 29%=0A> =A0 9=A0=A0=A0=A0=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 55%=0A> =
=A010=A0=A0=A0=A0=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 2=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 70%=0A> TotalFreePag=
es: 6932=0A> TotalMovablePages: 3954=0A> TotalReclaimablePages: 377=0A> Ove=
rall Fragmentation: 18%=0A> -----------------------------------------------=
------------------------------------------=0A> How to represent this in the=
 form of a jpeg image?=0A=0AThere is insufficient data there to generate th=
e same jpeg but I doubt=0Ait'd be very helpful anyway. Generating the image=
s was a handy way of=0Avalidating anti-fragmentation was working as expecte=
d and convincing=0Apeople that it was behaving in the right way but I never=
 used it to=0Aformally evaluate how well fragmentation was being handled. F=
or that=0AI used unusable free space index, a fragmentation index, allocati=
on=0Alatencies and success rates for allocating huge pages.=0A=0A-- =0AMel =
Gorman=0ASUSE Labs
--0-709411929-1311065882=:85318
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<html><body><div style=3D"color:#000; background-color:#fff; font-family:Co=
urier New, courier, monaco, monospace, sans-serif;font-size:12pt"><div styl=
e=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"><SPAN class=3Dtab><SPAN class=
=3Dtab><SPAN class=3Dtab><SPAN class=3Dtab><SPAN class=3Dtab><SPAN class=3D=
tab><SPAN class=3Dtab>&nbsp;&nbsp;&nbsp;&nbsp;</SPAN>&nbsp;&nbsp;&nbsp;&nbs=
p;</SPAN>&nbsp;&nbsp;&nbsp;&nbsp;</SPAN>&nbsp;&nbsp;&nbsp;&nbsp;</SPAN>&nbs=
p;&nbsp;&nbsp;&nbsp;</SPAN>&nbsp;&nbsp;&nbsp;&nbsp;</SPAN>&nbsp;&nbsp;&nbsp=
;&nbsp;</SPAN></SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">Dear All,<VAR id=3Dy=
ui-ie-cursor></VAR></SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">I wanted to represen=
t the physical page state of memory in the form of an image.</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">The physical page st=
ate information such as free pages, movable pages, reclaimable pages are ta=
ken from /proc/pagetypeinfo.</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">(I know the buddyinf=
o and pagetypeinfo data may not be accurate/insufficient but that is ok for=
 me)</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">These data will be u=
sed to create a YUV image and then can be converted to a jpeg image.</SPAN>=
</div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">The image should cle=
arly display the following(for each zone):-</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">- total free pages a=
vailable --&gt; in grey color</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">- total movable page=
s&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; --&gt; in Red color</SPAN></div=
><SPAN style=3D"RIGHT: auto">
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">- total&nbsp;reclaim=
able pages&nbsp;&nbsp;&nbsp; --&gt; in&nbsp;Blue color</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">Here each page will =
be represented by a pixel dot of different color.</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">A separate image wil=
l be created for each zone.</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">I know how to create=
 a raw YUV image, but I am confused how to prepare an image layout based on=
 the page-order and the total free page available.</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">It could be as simil=
ar as the anti-fragmentation page distribution image from below article fro=
m Mel Gorman.</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"><A style=3D"RIGHT: a=
uto" href=3D"http://lwn.net/Articles/224835/" target=3D_blank>http://lwn.ne=
t/Articles/224835/</A><BR><A style=3D"RIGHT: auto" href=3D"http://www.skyne=
t.ie/~mel/anti-frag/2007-02-28/page_type_distribution.jpg" target=3D_blank>=
http://www.skynet.ie/~mel/anti-frag/2007-02-28/page_type_distribution.jpg</=
A><BR>But I am not able to understand how this image is formed.</SPAN></div=
>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">From these image I a=
m not able to find how many order-n pages are free, movable and reclaimable=
.</SPAN></div></SPAN>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">In the above image t=
he block size is 32x32 and the image layout is (32x32) x (32x32) =3D 1024x1=
024</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">Also each pixel repr=
esent one page in memory.</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">But I am not able to=
 understand how this pixels are filled into the blocks.</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">I&nbsp;wanted to cre=
ate an image to show memory fragmentation under each zone.</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">If anybody has done =
similar kind of work please let me know.</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">I have already&nbsp;=
developed a sample utility in linux to create&nbsp;a dummy yuv420 image but=
 could not able to figure out how to fill the pixels into the image.</SPAN>=
</div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">My yuv program takes=
 input as totalfreepages, totalmovablepages, totalreclaimablepages.</SPAN><=
/div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">My system details ar=
e as folows:</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN><SPAN style=
=3D"RIGHT: auto">- linux mobile running on ARM Cortex-A9.</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">- total available RA=
M =3D 888MB</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">- Page size =3D 4K</=
SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">- Page block size =
=3D 1024 (from pagetypeinfo)</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">- page-order (0 to 1=
0)&nbsp;&nbsp;&nbsp; (from buddyinfo or pagetypeinfo)</div></SPAN>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">Thanks, Regards,</SP=
AN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">Pintu</SPAN></div>
<div style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</div>
<div><BR></div>
<DIV style=3D"FONT-FAMILY: Courier New, courier, monaco, monospace, sans-se=
rif; FONT-SIZE: 12pt">
<DIV style=3D"FONT-FAMILY: times new roman, new york, times, serif; FONT-SI=
ZE: 12pt"><FONT size=3D2 face=3DArial>
<DIV style=3D"BORDER-BOTTOM: #ccc 1px solid; BORDER-LEFT: #ccc 1px solid; P=
ADDING-BOTTOM: 0px; LINE-HEIGHT: 0; MARGIN: 5px 0px; PADDING-LEFT: 0px; PAD=
DING-RIGHT: 0px; HEIGHT: 0px; FONT-SIZE: 0px; BORDER-TOP: #ccc 1px solid; B=
ORDER-RIGHT: #ccc 1px solid; PADDING-TOP: 0px" class=3Dhr contentEditable=
=3Dfalse readonly=3D"true"></DIV><B><SPAN style=3D"FONT-WEIGHT: bold">From:=
</SPAN></B> Mel Gorman &lt;mgorman@suse.de&gt;<BR><B><SPAN style=3D"FONT-WE=
IGHT: bold">To:</SPAN></B> Pintu Agarwal &lt;pintu_agarwal@yahoo.com&gt;<BR=
><B><SPAN style=3D"FONT-WEIGHT: bold">Sent:</SPAN></B> Friday, 1 July 2011 =
12:21 PM<BR><B><SPAN style=3D"FONT-WEIGHT: bold">Subject:</SPAN></B> Re: JP=
EG image creation for memory fragmentation<BR></FONT><BR>On Thu, Jun 30, 20=
11 at 08:02:15AM -0700, Pintu Agarwal wrote:<BR><BR>&gt; I need to create a=
 sample jpeg image for displaying page states<BR>&gt; and fragmentation inf=
o across each zone by collecting data from<BR>&gt; /proc/buddyinfo and
 /proc/pagetypeinfo a one instance of time.<BR>&gt;<BR>&gt; I saw your arti=
cle about anti-fragmentation and page type distribution in the form of imag=
e from the following links:-<BR>&gt; <A style=3D"RIGHT: auto" href=3D"http:=
//lwn.net/Articles/224835/" target=3D_blank>http://lwn.net/Articles/224835/=
</A><BR>&gt; <A style=3D"RIGHT: auto" href=3D"http://www.skynet.ie/~mel/ant=
i-frag/2007-02-28/page_type_distribution.jpg" target=3D_blank>http://www.sk=
ynet.ie/~mel/anti-frag/2007-02-28/page_type_distribution.jpg</A><BR>&gt; &n=
bsp;<BR>&gt; I wanted to understand, I to create the similar image using my=
 data<BR>&gt; from buddyinfo and pagetypeinfo in my case.<BR><BR>There is i=
nsufficient data from buddyinfo and pagetypeinfo to generate<BR>the image l=
inked above.<BR><BR>&gt; What logic you used for creating these images?<BR>=
<BR>I used a perl script reading information via a kernel module and<BR>cre=
ating the image with libgd. If I was doing it again, I would<BR>read the
 necessary information from /proc/kpageflags. If I needed<BR>a greater degr=
ee of accuracy, I would patch the kernel to expand on<BR>the information av=
ailable in /proc/kpageflags.<BR><BR>&gt; How did you use the buddyinfo data=
 to form this image?<BR><BR>I didn't use buddyinfo.<BR><BR>&gt; Can you giv=
e some details about it?<BR>&gt; &nbsp;<BR>&gt; Like your aticle I am also =
defining the following:-<BR>&gt; - Each block size is 1024<BR>&gt; - Each p=
age is one pixel<BR>&gt; - Free page will be gray color<BR>&gt; - Movable p=
age will be green color<BR>&gt; - Reclaimable page will be blue color<BR>&g=
t; - And (I dont want zoneboundary, percpu, pinned pages etc in the image)<=
BR>&gt; &nbsp;<BR>&gt; Now suppose my system page state at some point of ti=
me looks like this:-<BR>&gt; ----------------------------------------------=
-------------------------------------------<BR>&gt; Node:1, Zone:DMA<BR>&gt=
; Order&nbsp;&nbsp;&nbsp;
 FreePages&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; MovablePages&nbsp;&nbsp;&nbs=
p; ReclaimablePages&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Fragmentation=
[%]<BR>&gt; &nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 38&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; 36&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; 0%<BR>&gt; &nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; 59&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 55&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0%<BR>&gt; &nbsp;
 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 40&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 32&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; 2%<BR>&gt; &nbsp; 3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 19&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; 16&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4%<BR>&gt; &nbsp; 4&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; 12&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 10&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; 6%<BR>&gt; &nbsp; 5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 9%<BR>&gt; &nbsp; 6=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 6&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;
 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 11%<BR>&g=
t; &nbsp; 7&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 7&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; 4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; 16%<BR>&gt; &nbsp; 8&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; 7&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 29%<BR>&gt;
 &nbsp; 9&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; 55%<BR>&gt; &nbsp;10&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 70%<BR>&gt; TotalFreePages=
: 6932<BR>&gt; TotalMovablePages: 3954<BR>&gt; TotalReclaimablePages: 377<B=
R>&gt; Overall Fragmentation: 18%<BR>&gt;
 --------------------------------------------------------------------------=
---------------<BR>&gt; How to represent this in the form of a jpeg image?<=
BR><BR>There is insufficient data there to generate the same jpeg but I dou=
bt<BR>it'd be very helpful anyway. Generating the images was a handy way of=
<BR>validating anti-fragmentation was working as expected and convincing<BR=
>people that it was behaving in the right way but I never used it to<BR>for=
mally evaluate how well fragmentation was being handled. For that<BR>I used=
 unusable free space index, a fragmentation index, allocation<BR>latencies =
and success rates for allocating huge pages.<BR><BR>-- <BR>Mel Gorman<BR>SU=
SE Labs<BR><BR><BR></DIV></DIV></div></body></html>
--0-709411929-1311065882=:85318--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
