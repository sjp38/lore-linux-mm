Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9876E6B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 16:49:28 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id x64so55931132qkb.5
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 13:49:28 -0800 (PST)
Received: from esa1.dell-outbound.iphmx.com (esa1.dell-outbound.iphmx.com. [68.232.153.90])
        by mx.google.com with ESMTPS id u124si9286153qkf.212.2017.01.13.13.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 13:49:27 -0800 (PST)
From: "Michaud, Adrian" <Adrian.Michaud@dell.com>
Subject: [LSF/MM TOPIC][LSF/MM ATTEND] Multiple Page Caches, Memory Tiering,
 Better LRU evictions,
Date: Fri, 13 Jan 2017 21:49:14 +0000
Message-ID: <61F9233AFAF8C541AAEC03A42CB0D8C7025D002B@MX203CL01.corp.emc.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_61F9233AFAF8C541AAEC03A42CB0D8C7025D002BMX203CL01corpem_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_61F9233AFAF8C541AAEC03A42CB0D8C7025D002BMX203CL01corpem_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I'd like to attend and propose one or all of the following topics at this y=
ear's summit.

Multiple Page Caches (Software Enhancements)
--------------------------
Support for multiple page caches can provide many benefits to the kernel.
Different memory types can be put into different page caches. One page cach=
e for native DDR system memory, another page cache for slower NV-DIMMs, etc=
.
General memory can be partitioned into several page caches of different siz=
es and could also be dedicated to high priority processes or used with cont=
ainers to better isolate memory by dedicating a page cache to a cgroup proc=
ess.
Each VMA, or process, could have a page cache identifier, or page alloc/fre=
e callbacks that allow individual VMAs or processes to specify which page c=
ache they want to use.
Some VMAs might want anonymous memory backed by vast amounts of slower serv=
er class memory like NV-DIMMS.
Some processes or individual VMAs might want their own private page cache.
Each page cache can have its own eviction policy and low-water markers
Individual page caches could also have their own swap device.

Memory Tiering (Software Enhancements)
--------------------
Using multiple page caches, evictions from one page cache could be moved an=
d remapped to another page cache instead of unmapped and written to swap.
If a system has 16GB of high speed DDR memory, and 64GB of slower memory, o=
ne could create a page cache with high speed DDR memory, another page cache=
 with slower 64GB memory, and evict/copy/remap from the DDR page cache to t=
he slow memory page cache. Evictions from the slow memory page cache would =
then get unmapped and written to swap.

Better LRU evictions (Software and Hardware Enhancements)
-------------------------
Add a page fault counter to the page struct to help colorize page demand.
We could suggest to Intel/AMD and other architecture leaders that TLB entri=
es also have a translation counter (8-10 bits is sufficient) instead of jus=
t an "accessed" bit.  Scanning/clearing access bits is obviously inefficien=
t; however, if TLBs had a translation counter instead of a single accessed =
bit then scanning and recording the amount of activity each TLB has would b=
e significantly better and allow us to bettern calculate LRU pages for evic=
tions.

TLB Shootdown (Hardware Enhancements)
--------------------------
We should stomp our feet and demand that TLB shootdowns should be hardware =
assisted in future architectures. Current TLB shootdown on x86 is horribly =
inefficient and obviously doesn't scale. The QPI/UPI local bus protocol sho=
uld provide TLB range invalidation broadcast so that a single CPU can concu=
rrently notify other CPU/cores (with a selection mask) that a shared TLB en=
try has changed. Sending an IPI to each core is horribly inefficient; espec=
ially with the core counts increasing and the frequency of TLB unmapping/re=
mapping also possibly increasing shortly with new server class memory exten=
sion technology.

Page Tables, Interrupt Descriptor Table, Global Descriptor table, etc (Soft=
ware and Hardware Enhancements)
---------------------------------------------------------------------------=
--------
As small amounts of ultra-high speed memory on severs becomes available (Fo=
r example: On-Package Memory from Intel), it would be good to utilize this =
memory initially for things like interrupt descriptor tables which we would=
 like to always have the lowest latency, and possibly some or all of the pa=
ge tables to allow faster TLB fetch/evictions as the frequency and latency =
of these directly affect overall load/store performance. Also, think about =
putting some of the highest frequently accessed kernel data into this ultra=
-high speed memory as well like current PID, etc.

Over the last few years I've implemented all of these in a private kernel w=
ith the exception of the hardware enhancements mentioned above. With suppor=
t for multiple page caches, multiple swap devices, individual page coloring=
, better LRU evictions, I've realized up to 30% overall performance improve=
ments when testing large memory exhausting applications like MongoDB with M=
MAPV1. I've also implemented transparent memory tiering using an Intel 3DXP=
 DIMM simulator as a 2nd tier of slower memory. I'd love to discuss everyth=
ing I've done in this space and see if there is interest in moving some of =
this into the mainline kernel or if I could offer help with similar efforts=
 that might already be active.

Thanks,

Adrian Michaud



--_000_61F9233AFAF8C541AAEC03A42CB0D8C7025D002BMX203CL01corpem_
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
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
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
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"EN-US" link=3D"#0563C1" vlink=3D"#954F72">
<div class=3D"WordSection1">
<p class=3D"MsoNormal">I&#8217;d like to attend and propose one or all of t=
he following topics at this year&#8217;s summit.
<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Multiple Page Caches (Software Enhancements)<o:p></o=
:p></p>
<p class=3D"MsoNormal">--------------------------<o:p></o:p></p>
<p class=3D"MsoNormal">Support for multiple page caches can provide many be=
nefits to the kernel.<o:p></o:p></p>
<p class=3D"MsoNormal">Different memory types can be put into different pag=
e caches. One page cache for native DDR system memory, another page cache f=
or slower NV-DIMMs, etc.<o:p></o:p></p>
<p class=3D"MsoNormal">General memory can be partitioned into several page =
caches of different sizes and could also be dedicated to high priority proc=
esses or used with containers to better isolate memory by dedicating a page=
 cache to a cgroup process.
<o:p></o:p></p>
<p class=3D"MsoNormal">Each VMA, or process, could have a page cache identi=
fier, or page alloc/free callbacks that allow individual VMAs or processes =
to specify which page cache they want to use.<o:p></o:p></p>
<p class=3D"MsoNormal">Some VMAs might want anonymous memory backed by vast=
 amounts of slower server class memory like NV-DIMMS.
<o:p></o:p></p>
<p class=3D"MsoNormal">Some processes or individual VMAs might want their o=
wn private page cache.<o:p></o:p></p>
<p class=3D"MsoNormal">Each page cache can have its own eviction policy and=
 low-water markers<o:p></o:p></p>
<p class=3D"MsoNormal">Individual page caches could also have their own swa=
p device.
<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Memory Tiering (Software Enhancements)<o:p></o:p></p=
>
<p class=3D"MsoNormal">--------------------<o:p></o:p></p>
<p class=3D"MsoNormal">Using multiple page caches, evictions from one page =
cache could be moved and remapped to another page cache instead of unmapped=
 and written to swap.
<o:p></o:p></p>
<p class=3D"MsoNormal">If a system has 16GB of high speed DDR memory, and 6=
4GB of slower memory, one could create a page cache with high speed DDR mem=
ory, another page cache with slower 64GB memory, and evict/copy/remap from =
the DDR page cache to the slow memory
 page cache. Evictions from the slow memory page cache would then get unmap=
ped and written to swap.
<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Better LRU evictions (Software and Hardware Enhancem=
ents)<o:p></o:p></p>
<p class=3D"MsoNormal">-------------------------<o:p></o:p></p>
<p class=3D"MsoNormal">Add a page fault counter to the page struct to help =
colorize page demand.
<o:p></o:p></p>
<p class=3D"MsoNormal">We could suggest to Intel/AMD and other architecture=
 leaders that TLB entries also have a translation counter (8-10 bits is suf=
ficient) instead of just an &#8220;accessed&#8221; bit.&nbsp; Scanning/clea=
ring access bits is obviously inefficient; however,
 if TLBs had a translation counter instead of a single accessed bit then sc=
anning and recording the amount of activity each TLB has would be significa=
ntly better and allow us to bettern calculate LRU pages for evictions.<o:p>=
</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">TLB Shootdown (Hardware Enhancements)<o:p></o:p></p>
<p class=3D"MsoNormal">--------------------------<o:p></o:p></p>
<p class=3D"MsoNormal">We should stomp our feet and demand that TLB shootdo=
wns should be hardware assisted in future architectures. Current TLB shootd=
own on x86 is horribly inefficient and obviously doesn&#8217;t scale. The Q=
PI/UPI local bus protocol should provide
 TLB range invalidation broadcast so that a single CPU can concurrently not=
ify other CPU/cores (with a selection mask) that a shared TLB entry has cha=
nged. Sending an IPI to each core is horribly inefficient; especially with =
the core counts increasing and the
 frequency of TLB unmapping/remapping also possibly increasing shortly with=
 new server class memory extension technology.
<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Page Tables, Interrupt Descriptor Table, Global Desc=
riptor table, etc (Software and Hardware Enhancements)<o:p></o:p></p>
<p class=3D"MsoNormal">----------------------------------------------------=
-------------------------------<o:p></o:p></p>
<p class=3D"MsoNormal">As small amounts of ultra-high speed memory on sever=
s becomes available (For example: On-Package Memory from Intel), it would b=
e good to utilize this memory initially for things like interrupt descripto=
r tables which we would like to always
 have the lowest latency, and possibly some or all of the page tables to al=
low faster TLB fetch/evictions as the frequency and latency of these direct=
ly affect overall load/store performance. Also, think about putting some of=
 the highest frequently accessed
 kernel data into this ultra-high speed memory as well like current PID, et=
c. <o:p>
</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Over the last few years I&#8217;ve implemented all o=
f these in a private kernel with the exception of the hardware enhancements=
 mentioned above. With support for multiple page caches, multiple swap devi=
ces, individual page coloring, better LRU
 evictions, I&#8217;ve realized up to 30% overall performance improvements =
when testing large memory exhausting applications like MongoDB with MMAPV1.=
 I&#8217;ve also implemented transparent memory tiering using an Intel 3DXP=
 DIMM simulator as a 2<sup>nd</sup> tier of
 slower memory. I&#8217;d love to discuss everything I&#8217;ve done in thi=
s space and see if there is interest in moving some of this into the mainli=
ne kernel or if I could offer help with similar efforts that might already =
be active.
<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Thanks,<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Adrian Michaud<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
</div>
</body>
</html>

--_000_61F9233AFAF8C541AAEC03A42CB0D8C7025D002BMX203CL01corpem_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
