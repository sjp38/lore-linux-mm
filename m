Message-ID: <A91A08D00A4FD2119BD500104B55BDF6021A6660@pdbh936a.pdb.siemens.de>
From: "Wichert, Gerhard" <Gerhard.Wichert@pdb.siemens.de>
Subject: AW: [bigmem-patch] 4GB with Linux on IA32
Date: Tue, 17 Aug 1999 16:58:32 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <Matthew.Wilcox@genedata.com>, "Wichert, Gerhard" <Gerhard.Wichert@pdb.siemens.de>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> -----Ursprungliche Nachricht-----
> Von: Matthew Wilcox [mailto:Matthew.Wilcox@genedata.com]
> Gesendet am: Dienstag, 17. August 1999 16:32
> An: Wichert, Gerhard
> Cc: linux-kernel@vger.rutgers.edu; linux-mm@kvack.org
> Betreff: Re: [bigmem-patch] 4GB with Linux on IA32
> 
> On Mon, Aug 16, 1999 at 06:29:30PM +0200, Andrea Arcangeli wrote:
> > Performance degradation:
> > 
> > 	Close to zero.
Here are some numbers I got when compiling the kernel on a 4-way 400MHz
Dechutes machine with 4GB memory.

Linux-2.3.13
time make -j 4 bzImage >/dev/null 2>&1

run 1
real	1m36.442s
user	4m49.060s
sys	0m22.300s

run 2
real	1m36.788s
user	4m48.920s
sys	0m22.290s

run 3
real	1m37.016s
user	4m48.670s
sys	0m22.910s

run 4
real	1m36.897s
user	4m48.800s
sys	0m22.390s

run 5
real	1m37.584s
user	4m48.680s
sys	0m22.180s



Linux-2.3.13 with bigmem support
time make -j 4 bzImage >/dev/null 2>&1

run 1
real	1m36.647s
user	4m50.340s
sys	0m21.870s

run 2
real	1m36.890s
user	4m49.780s
sys	0m22.410s

run 3
real	1m36.825s
user	4m49.360s
sys	0m22.930s

run 4
real	1m36.793s
user	4m50.180s
sys	0m22.270s

run 5
real	1m36.821s
user	4m50.500s
sys	0m22.030s

> 
> Have you got some lmbench results to back this up?
> 
What do you expect from lmbench. As far as I know it measures cache, memory
and tlb miss latencies. For this bench there is no difference if the mapping
goes to low or big memory.

Gerhard.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
