Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 2806A6B0002
	for <linux-mm@kvack.org>; Sun, 12 May 2013 23:00:27 -0400 (EDT)
References: <1310394396.24243.YahooMailNeo@web162006.mail.bf1.yahoo.com>
 <20110711145448.GI15285@suse.de>
 <1310462107.89450.YahooMailNeo@web162007.mail.bf1.yahoo.com>
 <20110712093510.GB7529@suse.de>
 <1310484381.60694.YahooMailNeo@web162011.mail.bf1.yahoo.com> <20110712154404.GD7529@suse.de>
Message-ID: <1368414026.58026.YahooMailNeo@web160103.mail.bf1.yahoo.com>
Date: Sun, 12 May 2013 20:00:26 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: [Query] Performance degradation with memory compaction (on QC chip-set)
In-Reply-To: <20110712154404.GD7529@suse.de>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="1520606428-1686909767-1368414026=:58026"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--1520606428-1686909767-1368414026=:58026
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Dear Mel Gorman,=0A=0AI have one question about memory compaction.=0AKernel=
 version: kernel-3.4 (ARM)=0AChipset: Qual-Comm MSM8930 dual-core.=0A=0AWe =
wanted to enable CONFIG_COMPACTION for our product with kernel-3.4.=0ABut Q=
C commented that, enabling compaction on their chip-set is causing performa=
nce degradation for some streaming scenarios (from the beginning).=0A=0AI w=
anted to know is this possible always?=0AWe used compaction with exynos pro=
cessor and did not observe any performance degradation.=0A=0A=0AAll,=0ADoes=
 any one observed any performance problem (on any chipset) by enabling comp=
action?=0A=0A=0APlease let me know your comments.=0AIt will be helpful to d=
ecide on enabling compaction or not.=0A=0A=0AThank You.=0AWith Regards,=0AP=
intu=0A=0A=0A=0A>________________________________=0A> From: Mel Gorman <mgo=
rman@suse.de>=0A>To: Pintu Agarwal <pintu_agarwal@yahoo.com> =0A>Sent: Tues=
day, 12 July 2011 8:44 AM=0A>Subject: Re: How to verify memory compaction o=
n Kernel2.6.36??=0A> =0A>=0A>On Tue, Jul 12, 2011 at 08:26:21AM -0700, Pint=
u Agarwal wrote:=0A>> =A0=0A>> Actually I enabled compaction without HUGETL=
B support. Hope this is fine.=0A>> =A0=0A>=0A>In terms of compaction yes. I=
n terms of your target application, I don't=0A>know.=0A>=0A>> Then I wrote =
a sample kernel module to allocate physical pages using kmalloc.=0A>> (By p=
assing the memory size from sample user space application and passing to th=
is kernel module via ioctl calls)=0A>> =A0=0A>=0A>The allocations will not =
be accessible to userspace without additional=0A>driver support to map the =
pages in userspace.=0A>=0A>> Using these application, I request for total n=
umber of physical pages of the desired order(from commandline of user app).=
=0A>> And at the sametime verifying the buddyinfo before and after the allo=
cation.=0A>> A sample output of my application is as follows:-=0A>> =3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=0A>> /opt/pintu # ./app_pinchar.bin=0A>> Node 0, z=
one=A0=A0 Normal=A0=A0=A0=A0 34=A0=A0=A0=A0=A0 9=A0=A0=A0=A0 13=A0=A0=A0=A0=
=A0 7=A0=A0=A0=A0 11=A0=A0=A0=A0=A0 6=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 2=A0=
=A0=A0=A0=A0 3=A0=A0=A0=A0=A0 1=A0=A0=A0=A0 36=0A>> Node 0, zone=A0 HighMem=
=A0=A0=A0=A0 53=A0=A0=A0 194=A0=A0=A0 110=A0=A0=A0=A0 36=A0=A0=A0=A0 21=A0=
=A0=A0=A0=A0 7=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 3=A0=A0=A0=
=A0=A0 2=A0=A0=A0=A0=A0 6=0A>> Page block order: 10=0A>> Pages per block:=
=A0 1024=0A>> Free pages count per migrate type at order=A0=A0=A0=A0=A0=A0 =
0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 3=A0=A0=A0=A0=A0 4=A0=A0=
=A0=A0=A0 5=A0=A0=A0=A0=A0 6=A0=A0=A0=A0=A0 7=A0=A0=A0=A0=A0 8=A0=A0=A0=A0=
=A0 9=A0=A0=A0=A0 10=0A>> Node=A0=A0=A0 0, zone=A0=A0 Normal, type=A0=A0=A0=
 Unmovable=A0=A0=A0=A0 32=A0=A0=A0=A0=A0 5=A0=A0=A0=A0=A0 8=A0=A0=A0=A0=A0 =
5=A0=A0=A0=A0 11=A0=A0=A0=A0=A0 5=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 0=A0=A0=
=A0=A0=A0 2=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A>> Node=A0=A0=A0 0, zone=A0=
=A0 Normal, type=A0 Reclaimable=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 2=A0=A0=A0=
=A0=A0 4=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 =
0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 0=0A>> =
Node=A0=A0=A0 0, zone=A0=A0 Normal, type=A0=A0=A0=A0=A0 Movable=A0=A0=A0=A0=
=A0 1=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=
=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 0=A0=A0=
=A0=A0=A0 0=A0=A0=A0=A0 35=0A>> Node=A0=A0=A0 0, zone=A0=A0 Normal, type=A0=
=A0=A0=A0=A0 Reserve=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=
=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 1=0A>> Node=A0=A0=
=A0 0, zone=A0=A0 Normal, type=A0=A0=A0=A0=A0 Isolate=A0=A0=A0=A0=A0 0=A0=
=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 =
0=A0=A0=A0=A0=A0 0=0A>> Node=A0=A0=A0 0, zone=A0 HighMem, type=A0=A0=A0 Unm=
ovable=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 3=
=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 1=A0=A0=
=A0=A0=A0 2=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 1=0A>> Node=A0=A0=A0 0, zone=A0=
 HighMem, type=A0 Reclaimable=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=
=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A>> N=
ode=A0=A0=A0 0, zone=A0 HighMem, type=A0=A0=A0=A0=A0 Movable=A0=A0=A0=A0 21=
=A0=A0=A0 194=A0=A0=A0 108=A0=A0=A0=A0 33=A0=A0=A0=A0 20=A0=A0=A0=A0=A0 7=
=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 1=A0=A0=
=A0=A0=A0 4=0A>> Node=A0=A0=A0 0, zone=A0 HighMem, type=A0=A0=A0=A0=A0 Rese=
rve=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=
=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 1=0A>> Node=A0=A0=A0 0, zone=A0 Hi=
ghMem, type=A0=A0=A0=A0=A0 Isolate=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=
=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=
=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=
=0A>> Number of blocks type=A0=A0=A0=A0 Unmovable=A0 Reclaimable=A0=A0=A0=
=A0=A0 Movable=A0=A0=A0=A0=A0 Reserve=A0=A0=A0=A0=A0 Isolate=0A>> Node 0, z=
one=A0=A0 Normal=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 82=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 4=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 73=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=0A>> Node 0, zone=A0 HighMem=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0 14=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 81=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 0=0A>> ----------------------------------------------------=
---------------------------------------=0A>> =A0=0A>> Enter the page order(=
in power of 2) : 512=0A>=0A>Page order 512? That's a good trick. I assume y=
ou means order 9 for 512=0A>pages.=0A>=0A>> Enter the number of such block =
: 200=0A>> ERROR : ioctl - PINCHAR_ALLOC - Failed, after block num =3D 72 !=
!!=0A>> DONE.....=0A>> =0A>=0A>72 corresponds almost exactly to the number =
of order-9 pages that were=0A>free when the application started.=0A>=0A>> =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A>> Node 0, zone=A0=A0 Norma=
l=A0=A0=A0 100=A0=A0=A0=A0 84=A0=A0=A0=A0 53=A0=A0=A0=A0 36=A0=A0=A0=A0 33=
=A0=A0=A0=A0 21=A0=A0=A0=A0=A0 8=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 3=A0=A0=A0=
=A0=A0 2=A0=A0=A0=A0=A0 0=0A>> Node 0, zone=A0 HighMem=A0=A0=A0 844=A0=A0=
=A0 744=A0=A0=A0 612=A0=A0=A0 357=A0=A0=A0 200=A0=A0=A0=A0 91=A0=A0=A0=A0=
=A0 8=A0=A0=A0=A0=A0 3=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 6=
=0A>> =0A>=0A>There is almost no free memory in the Normal zone at this sta=
ge of=0A>the test implying that even perfect compaction of all pages would=
=0A>still not result in a new order-9 page while obeying watermarks.=0A>=0A=
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A>> =A0=0A>> Then I want to verify wheth=
er compaction is working for the all allocation request or not.=0A>=0A>Read=
 /proc/vmstat but I doubt it was used much. Memory was mostly=0A>unfragment=
ed when the application started. It is likely that after=0A>72 order-9 page=
s there was not enough free memory to compact further=0A>and that is why th=
e allocation failed.=0A>=0A>> OR, at least how far compaction is helpful in=
 these scenarios.=0A>> =A0=0A>=0A>Compaction would have been helpful in the=
 event the system has been=0A>running for some time and was fragmented. Thi=
s test looks like it=0A>happened very close to boot so compaction would not=
 have been requried.=0A>=0A>> Please let me know how compaction can be effe=
ctive in such cases where order 8,9,10 pages are requested.=0A>> =A0=0A>=0A=
>Compaction reduces allocation latencies when memory is fragmented for=0A>h=
igh-order allocations like this. I'm not what else you are expecting=0A>to =
hear.=0A>=0A>-- =0A>Mel Gorman=0A>SUSE Labs=0A>=0A>=0A>
--1520606428-1686909767-1368414026=:58026
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<html><body><div style=3D"color:#000; background-color:#fff; font-family:lu=
cida console, sans-serif;font-size:12pt"><div><span><div>Dear Mel Gorman,</=
div><div><br></div><div>I have one question about memory compaction.</div><=
div>Kernel version: kernel-3.4 (ARM)</div><div>Chipset: Qual-Comm MSM8930 d=
ual-core.</div><div><br></div><div>We wanted to enable CONFIG_COMPACTION fo=
r our product with kernel-3.4.</div><div>But QC commented that, enabling co=
mpaction on their chip-set is causing performance degradation for some stre=
aming scenarios (from the beginning).</div><div><br></div><div>I wanted to =
know is this possible always?</div><div>We used compaction with exynos proc=
essor and did not observe any performance degradation.</div><div><br></div>=
<div><br></div><div>All,</div><div>Does any one observed any performance pr=
oblem (on any chipset) by enabling compaction?</div><div><br></div><div><br=
></div><div>Please let me know your comments.</div><div>It will be
 helpful to decide on enabling compaction or not.</div><div><br></div><div>=
<br></div><div>Thank You.</div><div>With Regards,</div><div>Pintu</div></sp=
an></div><div style=3D"font-family: 'lucida console', sans-serif; font-size=
: 12pt;"><br><blockquote style=3D"border-left: 2px solid rgb(16, 16, 255); =
margin-left: 5px; margin-top: 5px; padding-left: 5px;">  <div style=3D"font=
-family: 'lucida console', sans-serif; font-size: 12pt;"> <div style=3D"fon=
t-family: 'times new roman', 'new york', times, serif; font-size: 12pt;"> <=
div dir=3D"ltr"> <hr size=3D"1">  <font size=3D"2" face=3D"Arial"> <b><span=
 style=3D"font-weight:bold;">From:</span></b> Mel Gorman &lt;mgorman@suse.d=
e&gt;<br> <b><span style=3D"font-weight: bold;">To:</span></b> Pintu Agarwa=
l &lt;pintu_agarwal@yahoo.com&gt; <br> <b><span style=3D"font-weight: bold;=
">Sent:</span></b> Tuesday, 12 July 2011 8:44 AM<br> <b><span style=3D"font=
-weight: bold;">Subject:</span></b> Re: How to verify memory compaction on
 Kernel2.6.36??<br> </font> </div> <div class=3D"y_msg_container"><br>On Tu=
e, Jul 12, 2011 at 08:26:21AM -0700, Pintu Agarwal wrote:<br>&gt; &nbsp;<br=
>&gt; Actually I enabled compaction without HUGETLB support. Hope this is f=
ine.<br>&gt; &nbsp;<br><br>In terms of compaction yes. In terms of your tar=
get application, I don't<br>know.<br><br>&gt; Then I wrote a sample kernel =
module to allocate physical pages using kmalloc.<br>&gt; (By passing the me=
mory size from sample user space application and passing to this kernel mod=
ule via ioctl calls)<br>&gt; &nbsp;<br><br>The allocations will not be acce=
ssible to userspace without additional<br>driver support to map the pages i=
n userspace.<br><br>&gt; Using these application, I request for total numbe=
r of physical pages of the desired order(from commandline of user app).<br>=
&gt; And at the sametime verifying the buddyinfo before and after the alloc=
ation.<br>&gt; A sample output of my application is as
 follows:-<br>&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>&gt; /opt/pintu # ./=
app_pinchar.bin<br>&gt; Node 0, zone&nbsp;&nbsp; Normal&nbsp;&nbsp;&nbsp;&n=
bsp; 34&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 9&nbsp;&nbsp;&nbsp;&nbsp; 13&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; 7&nbsp;&nbsp;&nbsp;&nbsp; 11&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; 6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nb=
sp;&nbsp; 36<br>&gt; Node 0, zone&nbsp; HighMem&nbsp;&nbsp;&nbsp;&nbsp; 53&=
nbsp;&nbsp;&nbsp; 194&nbsp;&nbsp;&nbsp; 110&nbsp;&nbsp;&nbsp;&nbsp; 36&nbsp=
;&nbsp;&nbsp;&nbsp; 21&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 7&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 6<br>&gt; Pa=
ge block order: 10<br>&gt; Pages per block:&nbsp; 1024<br>&gt; Free pages c=
ount per migrate type at
 order&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 5&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; 6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 7&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 8=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 9&nbsp;&nbsp;&nbsp;&nbsp; 10<br>&gt; Node&nb=
sp;&nbsp;&nbsp; 0, zone&nbsp;&nbsp; Normal, type&nbsp;&nbsp;&nbsp; Unmovabl=
e&nbsp;&nbsp;&nbsp;&nbsp; 32&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 5&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; 8&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 5&nbsp;&nbsp;&nbsp;&nbsp; 1=
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>&gt; Node&nbsp;&nbsp;&nbsp; =
0, zone&nbsp;&nbsp; Normal, type&nbsp; Reclaimable&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>&gt; N=
ode&nbsp;&nbsp;&nbsp; 0, zone&nbsp;&nbsp; Normal, type&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; Movable&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp; 35<br>&gt; No=
de&nbsp;&nbsp;&nbsp; 0, zone&nbsp;&nbsp; Normal, type&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp; Reserve&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
1<br>&gt; Node&nbsp;&nbsp;&nbsp; 0, zone&nbsp;&nbsp; Normal, type&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; Isolate&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; 0<br>&gt; Node&nbsp;&nbsp;&nbsp; 0, zone&nbsp; HighMem, type&nbsp;&nbsp=
;&nbsp; Unmovable&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; 1<br>&gt; Node&nbsp;&nbsp;&nbsp; 0, zone&nbsp; HighMem, type&nbs=
p; Reclaimable&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>&gt; =
Node&nbsp;&nbsp;&nbsp; 0, zone&nbsp; HighMem, type&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; Movable&nbsp;&nbsp;&nbsp;&nbsp; 21&nbsp;&nbsp;&nbsp; 194&nbsp;&nbsp;&=
nbsp; 108&nbsp;&nbsp;&nbsp;&nbsp; 33&nbsp;&nbsp;&nbsp;&nbsp; 20&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; 7&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4<br>&gt; =
Node&nbsp;&nbsp;&nbsp; 0, zone&nbsp; HighMem, type&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; Reserve&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1<br>&gt; N=
ode&nbsp;&nbsp;&nbsp; 0, zone&nbsp; HighMem, type&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp; Isolate&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 0<br>&gt; Number of blocks type&nbsp;&nbsp;&nbsp;&nbsp; Unmovable&nbsp; Re=
claimable&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Movable&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; Reserve&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Isolate<br>&gt; Node 0, zone&nbsp;=
&nbsp; Normal&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 8=
2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 73&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>&gt; Node 0, zone&nbsp; High=
Mem&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 14&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 81&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>&gt;
 --------------------------------------------------------------------------=
-----------------<br>&gt; &nbsp;<br>&gt; Enter the page order(in power of 2=
) : 512<br><br>Page order 512? That's a good trick. I assume you means orde=
r 9 for 512<br>pages.<br><br>&gt; Enter the number of such block : 200<br>&=
gt; ERROR : ioctl - PINCHAR_ALLOC - Failed, after block num =3D 72 !!!<br>&=
gt; DONE.....<br>&gt; <br><br>72 corresponds almost exactly to the number o=
f order-9 pages that were<br>free when the application started.<br><br>&gt;=
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>&gt; Node 0, zone&nbsp;=
&nbsp; Normal&nbsp;&nbsp;&nbsp; 100&nbsp;&nbsp;&nbsp;&nbsp; 84&nbsp;&nbsp;&=
nbsp;&nbsp; 53&nbsp;&nbsp;&nbsp;&nbsp; 36&nbsp;&nbsp;&nbsp;&nbsp; 33&nbsp;&=
nbsp;&nbsp;&nbsp; 21&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 8&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>&gt; Node 0, zone&nbsp; HighMem&nbsp;=
&nbsp;&nbsp; 844&nbsp;&nbsp;&nbsp; 744&nbsp;&nbsp;&nbsp; 612&nbsp;&nbsp;&nb=
sp; 357&nbsp;&nbsp;&nbsp; 200&nbsp;&nbsp;&nbsp;&nbsp; 91&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; 8&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 6<br>&gt; =
<br><br>There is almost no free memory in the Normal zone at this stage of<=
br>the test implying that even perfect compaction of all pages would<br>sti=
ll not result in a new order-9 page while obeying watermarks.<br><br>&gt; =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>&gt; &nbsp;<br>&gt; Then I want to verify=
 whether compaction is working for the all allocation request or not.<br><b=
r>Read /proc/vmstat but I doubt it was used much. Memory was mostly<br>unfr=
agmented when the application started. It is likely that after<br>72 order-=
9 pages there was not enough free
 memory to compact further<br>and that is why the allocation failed.<br><br=
>&gt; OR, at least how far compaction is helpful in these scenarios.<br>&gt=
; &nbsp;<br><br>Compaction would have been helpful in the event the system =
has been<br>running for some time and was fragmented. This test looks like =
it<br>happened very close to boot so compaction would not have been requrie=
d.<br><br>&gt; Please let me know how compaction can be effective in such c=
ases where order 8,9,10 pages are requested.<br>&gt; &nbsp;<br><br>Compacti=
on reduces allocation latencies when memory is fragmented for<br>high-order=
 allocations like this. I'm not what else you are expecting<br>to hear.<br>=
<br>-- <br>Mel Gorman<br>SUSE Labs<br><br><br></div> </div> </div> </blockq=
uote></div>   </div></body></html>
--1520606428-1686909767-1368414026=:58026--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
