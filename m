Date: Thu, 24 Oct 2002 00:51:18 +0200
From: Arador <diegocg@teleline.es>
Subject: Re: 2.5.44-mm3: X doesn't work
Message-Id: <20021024005118.0fb9d427.diegocg@teleline.es>
In-Reply-To: <447940000.1035403802@flay>
References: <20021023205808.0449836a.diegocg@teleline.es>
	<447940000.1035403802@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Oct 2002 13:10:02 -0700
"Martin J. Bligh" <mbligh@aracnet.com> wrote:

> CONFIG_SHAREPTE=y
> CONFIG_PREEMPT=y
> 
> Want to try it again with the following?
> 1. CONFIG_SHPTE set, CONFIG_PREEMPT not set
> 2. CONFIG_SHPTE unset, CONFIG_PREEMPT set

only tested the 2 case. It works. I've not tested 1, perhaps
i won't test, recompile a kernel takes a loong time and i assume that
the bug cames from CONFIG_SHAREPTE.

A strange thing: While testing the 2 case i've found the following situation
I started Xwindows, while i started recompiling a kernel (233 mhz 32 Mb ram).
Then, disk became mad as it'd be swapping. Looking with top, i found kswapd
working ~20% of the cpu. The one only strange thing i did appart from starting
Xwindows was set to 100 /proc/sys/vm/swapiness, then 0, then the default 60.
(I've tried booting and changing it again and i doesn't happen anything).

While i was lookink at kswapd i set swapiness again to 100 and went up to ~40% of the cpu.
Then i tried to kill all processes. When idle, kswapd was eating around 5% of the cpu.
(swapiness at 60). Every ls, cat...everything made kswapd to eat a lot of cpu (and
swapping things it seems, there was a lot of disk activity)
I wish to have vmstat info but i don't have a proper procps. I'll collect more
data and try to reproduce again if needed.



Diego Calleja
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
