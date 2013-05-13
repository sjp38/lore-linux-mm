Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 049AA6B0002
	for <linux-mm@kvack.org>; Sun, 12 May 2013 23:03:57 -0400 (EDT)
References: <1310394396.24243.YahooMailNeo@web162006.mail.bf1.yahoo.com>
 <20110711145448.GI15285@suse.de>
 <1310462107.89450.YahooMailNeo@web162007.mail.bf1.yahoo.com>
 <20110712093510.GB7529@suse.de>
 <1310484381.60694.YahooMailNeo@web162011.mail.bf1.yahoo.com> <20110712154404.GD7529@suse.de> <1368414026.58026.YahooMailNeo@web160103.mail.bf1.yahoo.com>
Message-ID: <1368414236.21785.YahooMailNeo@web160106.mail.bf1.yahoo.com>
Date: Sun, 12 May 2013 20:03:56 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: [Query] Performance degradation with memory compaction (on QC chip-set)
In-Reply-To: <1368414026.58026.YahooMailNeo@web160103.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

* Sorry Re-sending as plain text.=0A=0A=0ADear Mr. Mel Gorman,=0A=0AI have =
one question about memory compaction.=0AKernel version: kernel-3.4 (ARM)=0A=
Chipset: Qual-Comm MSM8930 dual-core.=0A=0AWe wanted to enable CONFIG_COMPA=
CTION for our product with kernel-3.4.=0ABut QC commented that, enabling co=
mpaction on their chip-set is causing performance degradation for some stre=
aming scenarios (from the beginning).=0A=0AI wanted to know is this possibl=
e always?=0AWe used compaction with exynos processor and did not observe an=
y performance degradation.=0A=0A=0AAll,=0ADoes any one observed any perform=
ance problem (on any chipset) by enabling compaction?=0A=0A=0APlease let me=
 know your comments.=0AIt will be helpful to decide on enabling compaction =
or not.=0A=0A=0AThank You.=0AWith Regards,=0APintu=0A=0A=0A=0A=0A=0A>=0A>=
=0A>>________________________________=0A>> From: Mel Gorman <mgorman@suse.d=
e>=0A>>To: Pintu Agarwal <pintu_agarwal@yahoo.com> =0A>>Sent: Tuesday, 12 J=
uly 2011 8:44 AM=0A>>Subject: Re: How to verify memory compaction on Kernel=
2.6.36??=0A>> =0A>>=0A>>On Tue, Jul 12, 2011 at 08:26:21AM -0700, Pintu Aga=
rwal wrote:=0A>>> =A0=0A>>> Actually I enabled compaction without HUGETLB s=
upport. Hope this is fine.=0A>>> =A0=0A>>=0A>>In terms of compaction yes. I=
n terms of your target application, I don't=0A>>know.=0A>>=0A>>> Then I wro=
te a sample kernel module to allocate physical pages using kmalloc.=0A>>> (=
By passing the memory size from sample user space application and passing t=
o this kernel module via ioctl calls)=0A>>> =A0=0A>>=0A>>The allocations wi=
ll not be accessible to userspace without additional=0A>>driver support to =
map the pages in userspace.=0A>>=0A>>> Using these application, I request f=
or total number of physical pages of the desired order(from commandline of =
user app).=0A>>> And at the sametime verifying the buddyinfo before and aft=
er the allocation.=0A>>> A sample output of my application is as=0Afollows:=
-=0A>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A>>> /opt/pintu # ./app_pinchar.bi=
n=0A>>> Node 0, zone=A0=A0 Normal=A0=A0=A0=A0 34=A0=A0=A0=A0=A0 9=A0=A0=A0=
=A0 13=A0=A0=A0=A0=A0 7=A0=A0=A0=A0 11=A0=A0=A0=A0=A0 6=A0=A0=A0=A0=A0 2=A0=
=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 3=A0=A0=A0=A0=A0 1=A0=A0=A0=A0 36=0A>>> Node =
0, zone=A0 HighMem=A0=A0=A0=A0 53=A0=A0=A0 194=A0=A0=A0 110=A0=A0=A0=A0 36=
=A0=A0=A0=A0 21=A0=A0=A0=A0=A0 7=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 2=A0=A0=A0=
=A0=A0 3=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 6=0A>>> Page block order: 10=0A>>>=
 Pages per block:=A0 1024=0A>>> Free pages count per migrate type at=0Aorde=
r=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 3=A0=
=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 5=A0=A0=A0=A0=A0 6=A0=A0=A0=A0=A0 7=A0=A0=A0=
=A0=A0 8=A0=A0=A0=A0=A0 9=A0=A0=A0=A0 10=0A>>> Node=A0=A0=A0 0, zone=A0=A0 =
Normal, type=A0=A0=A0 Unmovable=A0=A0=A0=A0 32=A0=A0=A0=A0=A0 5=A0=A0=A0=A0=
=A0 8=A0=A0=A0=A0=A0 5=A0=A0=A0=A0 11=A0=A0=A0=A0=A0 5=A0=A0=A0=A0=A0 2=A0=
=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A>>> Nod=
e=A0=A0=A0 0, zone=A0=A0 Normal, type=A0 Reclaimable=A0=A0=A0=A0=A0 1=A0=A0=
=A0=A0=A0=0A2=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 0=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 =
1=A0=A0=A0=A0=A0 0=0A>>> Node=A0=A0=A0 0, zone=A0=A0 Normal, type=A0=A0=A0=
=A0=A0 Movable=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 1=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 =
1=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0 35=0A>>> Node=A0=A0=A0 0, z=
one=A0=A0 Normal, type=A0=A0=A0=A0=A0 Reserve=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=
=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=0A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=
=A0=A0=A0 1=0A>>> Node=A0=A0=A0 0, zone=A0=A0 Normal, type=A0=A0=A0=A0=A0 I=
solate=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=
=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=
=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A>>> Node=A0=A0=A0 0, zone=
=A0 HighMem, type=A0=A0=A0 Unmovable=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 0=A0=
=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 3=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0=0A0=A0=A0=
=A0=A0=A0 0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 2=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=
=A0 1=0A>>> Node=A0=A0=A0 0, zone=A0 HighMem, type=A0 Reclaimable=A0=A0=A0=
=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 =
0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=
=A0=A0=A0 0=A0=A0=A0=A0=A0 0=0A>>> Node=A0=A0=A0 0, zone=A0 HighMem, type=
=A0=A0=A0=A0=A0 Movable=A0=A0=A0=A0 21=A0=A0=A0 194=A0=A0=A0 108=A0=A0=A0=
=A0 33=A0=A0=A0=A0 20=A0=A0=A0=A0=A0 7=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 1=A0=
=A0=A0=A0=A0=0A1=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 4=0A>>> Node=A0=A0=A0 0, z=
one=A0 HighMem, type=A0=A0=A0=A0=A0 Reserve=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=
 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=
=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=
=A0=A0 1=0A>>> Node=A0=A0=A0 0, zone=A0 HighMem, type=A0=A0=A0=A0=A0 Isolat=
e=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=
=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=
=A0 0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=0A0=0A>>> Number of blocks type=A0=A0=
=A0=A0 Unmovable=A0 Reclaimable=A0=A0=A0=A0=A0 Movable=A0=A0=A0=A0=A0 Reser=
ve=A0=A0=A0=A0=A0 Isolate=0A>>> Node 0, zone=A0=A0 Normal=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 82=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 73=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 0=0A>>> Node 0, zone=A0 HighMem=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 14=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 81=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0=0A>>>=0A--------=
---------------------------------------------------------------------------=
--------=0A>>> =A0=0A>>> Enter the page order(in power of 2) : 512=0A>>=0A>=
>Page order 512? That's a good trick. I assume you means order 9 for 512=0A=
>>pages.=0A>>=0A>>> Enter the number of such block : 200=0A>>> ERROR : ioct=
l - PINCHAR_ALLOC - Failed, after block num =3D 72 !!!=0A>>> DONE.....=0A>>=
> =0A>>=0A>>72 corresponds almost exactly to the number of order-9 pages th=
at were=0A>>free when the application started.=0A>>=0A>>> =3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A>>> Node 0, zone=A0=A0 Normal=A0=A0=A0 100=
=A0=A0=A0=A0 84=A0=A0=A0=A0 53=A0=A0=A0=A0 36=A0=A0=A0=A0 33=A0=A0=A0=A0 21=
=A0=A0=A0=A0=A0 8=A0=A0=A0=A0=A0 0=A0=A0=A0=A0=A0 3=A0=A0=A0=A0=A0=0A2=A0=
=A0=A0=A0=A0 0=0A>>> Node 0, zone=A0 HighMem=A0=A0=A0 844=A0=A0=A0 744=A0=
=A0=A0 612=A0=A0=A0 357=A0=A0=A0 200=A0=A0=A0=A0 91=A0=A0=A0=A0=A0 8=A0=A0=
=A0=A0=A0 3=A0=A0=A0=A0=A0 4=A0=A0=A0=A0=A0 1=A0=A0=A0=A0=A0 6=0A>>> =0A>>=
=0A>>There is almost no free memory in the Normal zone at this stage of=0A>=
>the test implying that even perfect compaction of all pages would=0A>>stil=
l not result in a new order-9 page while obeying watermarks.=0A>>=0A>>> =3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A>>> =A0=0A>>> Then I want to verify whether c=
ompaction is working for the all allocation request or not.=0A>>=0A>>Read /=
proc/vmstat but I doubt it was used much. Memory was mostly=0A>>unfragmente=
d when the application started. It is likely that after=0A>>72 order-9 page=
s there was not enough free=0Amemory to compact further=0A>>and that is why=
 the allocation failed.=0A>>=0A>>> OR, at least how far compaction is helpf=
ul in these scenarios.=0A>>> =A0=0A>>=0A>>Compaction would have been helpfu=
l in the event the system has been=0A>>running for some time and was fragme=
nted. This test looks like it=0A>>happened very close to boot so compaction=
 would not have been requried.=0A>>=0A>>> Please let me know how compaction=
 can be effective in such cases where order 8,9,10 pages are requested.=0A>=
>> =A0=0A>>=0A>>Compaction reduces allocation latencies when memory is frag=
mented for=0A>>high-order allocations like this. I'm not what else you are =
expecting=0A>>to hear.=0A>>=0A>>-- =0A>>Mel Gorman=0A>>SUSE Labs=0A>>=0A>>=
=0A>>=0A>=0A>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
