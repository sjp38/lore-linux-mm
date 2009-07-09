Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D9B4E6B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 16:22:46 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <19030.22024.132029.196682@stoffel.org>
Date: Thu, 9 Jul 2009 16:41:44 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: OOM killer in 2.6.31-rc2
In-Reply-To: <200907091042.38022.gene.heskett@verizon.net>
References: <200907061056.00229.gene.heskett@verizon.net>
	<20090708051515.GA17156@localhost>
	<20090708075501.GA1122@localhost>
	<200907091042.38022.gene.heskett@verizon.net>
Sender: owner-linux-mm@kvack.org
To: Gene Heskett <gene.heskett@verizon.net>
Cc: Wu Fengguang <fengguang.wu@gmail.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, David Howells <dhowells@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

>>>>> "Gene" == Gene Heskett <gene.heskett@verizon.net> writes:

Gene> On Wednesday 08 July 2009, Wu Fengguang wrote:
>> On Wed, Jul 08, 2009 at 01:15:15PM +0800, Wu Fengguang wrote:
>>> On Tue, Jul 07, 2009 at 11:42:07PM -0400, Gene Heskett wrote:
Gene> [...]
>>> I guess your near 800MB slab cache is somehow under scanned.
>> 
>> Gene, can you run .31 with this patch? When OOM happens, it will tell
>> us whether the majority slab pages are reclaimable. Another way to
>> find things out is to run `slabtop` when your system is moderately loaded.

Gene> Its been running continuously, and after 24 hours is now showing:

Just wondering, is this your M2N-SLI Deluxe board?  I've got the same
board, with 4Gb of RAM and I haven't noticed any loss of RAM from my
looking (quickly) at top output.

But I also haven't bothered to upgrade the BIOS on this board at all
since I got it back in March of 2008.  No need in my book so far.  

> uname -a
Linux sail 2.6.31-rc1 #6 SMP PREEMPT Wed Jun 24 21:40:33 EDT 2009 x86_64 GNU/Linux


> cat /proc/meminfo 
MemTotal:        3987068 kB
MemFree:          170608 kB
Buffers:          355272 kB
Cached:          2034416 kB
SwapCached:            0 kB
Active:          1836284 kB
Inactive:        1482444 kB
Active(anon):     857076 kB
Inactive(anon):    86112 kB
Active(file):     979208 kB
Inactive(file):  1396332 kB
Unevictable:        3972 kB
Mlocked:            3972 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:                36 kB
Writeback:             0 kB
AnonPages:        933160 kB
Mapped:           141188 kB
Slab:             398124 kB
SReclaimable:     348212 kB
SUnreclaim:        49912 kB
PageTables:        30916 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     1993532 kB
Committed_AS:    1570980 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      116160 kB
VmallocChunk:   34359584603 kB
DirectMap4k:        4992 kB
DirectMap2M:     4188160 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
