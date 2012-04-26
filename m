Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 91FFD6B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 18:54:25 -0400 (EDT)
Date: Thu, 26 Apr 2012 18:54:21 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.4-rc4 oom killer out of control.
Message-ID: <20120426225421.GB13598@redhat.com>
References: <20120426193551.GA24968@redhat.com>
 <alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com>
 <20120426215257.GA12908@redhat.com>
 <alpine.DEB.2.00.1204261517100.28376@chino.kir.corp.google.com>
 <20120426224419.GA13598@redhat.com>
 <alpine.DEB.2.00.1204261547250.15785@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204261547250.15785@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, Apr 26, 2012 at 03:49:06PM -0700, David Rientjes wrote:
 > On Thu, 26 Apr 2012, Dave Jones wrote:
 > 
 > > Disabling it stops it hogging the cpu obviously, but there's still 8G of RAM
 > > and 1G of used swap sitting around doing something.
 > > 
 > 
 > Right, I eluded to this in another email because the rss sizes from your 
 > oom log weren't necessarily impressive.  Could you post the output of 
 > /proc/meminfo?

MemTotal:        8149440 kB
MemFree:          142560 kB
Buffers:            1408 kB
Cached:            11504 kB
SwapCached:         9336 kB
Active:          6124932 kB
Inactive:        1232176 kB
Active(anon):    6119160 kB
Inactive(anon):  1225228 kB
Active(file):       5772 kB
Inactive(file):     6948 kB
Unevictable:        5656 kB
Mlocked:            5656 kB
SwapTotal:       1423736 kB
SwapFree:         343596 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:       7341364 kB
Mapped:             5720 kB
Shmem:               192 kB
Slab:             267408 kB
SReclaimable:      40808 kB
SUnreclaim:       226600 kB
KernelStack:        3280 kB
PageTables:       183104 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     5498456 kB
Committed_AS:   111294188 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      346720 kB
VmallocChunk:   34359384056 kB
HardwareCorrupted:     0 kB
AnonHugePages:         0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:       98344 kB
DirectMap2M:     8288256 kB


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
