Date: Sat, 2 Feb 2008 12:30:45 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't works on memoryless node.
Message-ID: <20080202113045.GA29441@one.firstfloor.org>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080202090914.GA27723@one.firstfloor.org> <20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

> I have 1 simple question. 
> Why do libnuma generate bitpattern of all bit on instead
> check /sys/devices/system/node/has_high_memory nor 
> check /sys/devices/system/node/online?
> 
> Do you know it?

It's far simpler and cheaper (sysfs is expensive) to do this in the kernel 
and besides the kernel can do more easily keep up with dynamic topology
changes.

> 
> and I made simple patch that has_high_memory exposed however CONFIG_HIGHMEM disabled.
> if CONFIG_HIGHMEM disabled, the has_high_memory file show 
> the same as the has_normal_memory.
> 
> may be, userland process should check has_high_memory file.

To be honest I've never tried seriously to make 32bit NUMA policy
(with highmem) work well; just kept it at a "should not break"
level. That is because with highmem the kernel's choices at 
placing memory are seriously limited anyways so I doubt 32bit
NUMA will ever work very well.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
