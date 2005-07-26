Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6QLjDhn493868
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 17:45:13 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6QLjFuN191782
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 15:45:15 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6QLjCUm025980
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 15:45:12 -0600
Subject: Re: Memory pressure handling with iSCSI
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20050726142410.4ff2e56a.akpm@osdl.org>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726111110.6b9db241.akpm@osdl.org>
	 <1122403152.6433.39.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726114824.136d3dad.akpm@osdl.org>
	 <20050726121250.0ba7d744.akpm@osdl.org>
	 <1122412301.6433.54.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726142410.4ff2e56a.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 26 Jul 2005 14:45:00 -0700
Message-Id: <1122414300.6433.57.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-07-26 at 14:24 -0700, Andrew Morton wrote:
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >
> > ext2 is incredibly better. Machine is very responsive. 
> > 
> 
> OK.  Please, always monitor and send /proc/meminfo.  I assume that the
> dirty-memory clamping is working OK with ext2 and that perhaps it'll work
> OK with ext3/data=writeback.

Nope. Dirty is still very high..

# cat /proc/meminfo
MemTotal:      7143628 kB
MemFree:         33248 kB
Buffers:          8368 kB
Cached:        6789932 kB
SwapCached:          0 kB
Active:          51316 kB
Inactive:      6769144 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:      7143628 kB
LowFree:         33248 kB
SwapTotal:     1048784 kB
SwapFree:      1048780 kB
Dirty:         6605704 kB
Writeback:      168452 kB
Mapped:          49724 kB
Slab:           252200 kB
CommitLimit:   4620596 kB
Committed_AS:   163524 kB
PageTables:       2284 kB
VmallocTotal: 34359738367 kB
VmallocUsed:      9888 kB
VmallocChunk: 34359728447 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:     2048 kB

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
