Date: Mon, 6 Sep 2004 15:48:30 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
Message-ID: <20040906224830.GI3106@holomorphy.com>
References: <413CB661.6030303@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <413CB661.6030303@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <piggin@cyberone.com.au>, Con Kolivas <kernel@kolivas.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 06, 2004 at 02:11:29PM -0500, Ray Bryant wrote:
> What is unexpected is that the amount of swap space used at a particular
> swappiness setting varies dramatically with the kernel version being 
> tested, in spite of the fact that the basic swap_tendency calculation in 
> refile_ianctive_zone() is unchanged.  (Other, subtle changes in the vm as a 
> whole and this routine in particular clearly effect the impact of that 
> computation.)
> For example, at a swappiness value of 0, Kernel 2.6.5 swapped out 0 bytes,
> whereas Kernel 2.6.9-rc1-mm3 swapped out 10 GB.  Similarly, most kernels
> have a significant change in behavior for swappiness values near 100, but
> for SLES9 the change point occurs at swappness=60.
> A scan of the change logs for swappiness related changes shows nothing that 
> might explain these changes.  My question is:  "Is this change in behavior
> deliberate, or just a side effect of other changes that were made in the 
> vm?" and "What kind of swappiness behavior might I expect to find in future 
> kernels?".

IIRC no deliberate /proc/sys/vm/swappiness semantic changes were merged.
The policy tweakers have something to answer for here unless some stats
they rely upon have since been flubbed. Logging periodic snapshots of
/proc/vmstat for these benchmarks may be helpful to implicate specific
statistics' bungling or rule out statistic miscalculation as causes.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
