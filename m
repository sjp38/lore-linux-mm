Date: Sat, 26 Nov 2005 02:37:20 -0800 (PST)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: [PATCH] temporarily disable swap token on memory pressure
In-Reply-To: <Pine.LNX.4.63.0511251733490.32217@cuia.boston.redhat.com>
Message-ID: <Pine.LNX.4.61.0511260234550.1592@montezuma.fsmlabs.com>
References: <Pine.LNX.4.63.0511251733490.32217@cuia.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Nov 2005, Rik van Riel wrote:

> Some users (hi Zwane) have seen a problem when running a workload
> that eats nearly all of physical memory - th system does an OOM
> kill, even when there is still a lot of swap free.
> 
> I suspect the problem is that that big task is holding the swap
> token, and the VM has a very hard time finding any other page in
> the system that is swappable.  
> 
> Instead of ignoring the swap token when sc->priority reaches 0,
> we could simply take the swap token away from the memory hog and
> make sure we don't give it back to the memory hog for a few seconds.
> 
> This patch is untested, since I have not reproduced Zwane's problem
> on my system.  I would like to see test results from anybody who is
> running into this problem.
> 
> This patch is against today's git head.

Very nice! With this patch my job actually completed.

MemTotal:      2049180 kB
MemFree:         15592 kB
Buffers:          1516 kB
Cached:          62972 kB
SwapCached:     190512 kB
Active:        1626228 kB
Inactive:       361288 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:      2049180 kB
LowFree:         15592 kB
SwapTotal:     3228760 kB
SwapFree:      2555688 kB
Dirty:               0 kB
Writeback:           0 kB
Mapped:        1824108 kB
Slab:            27392 kB
CommitLimit:   4253348 kB
Committed_AS:  2472188 kB
PageTables:       6688 kB
VmallocTotal: 34359738367 kB
VmallocUsed:    263796 kB
VmallocChunk: 34359474119 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
