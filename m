Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 25DDE6B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 03:48:24 -0500 (EST)
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
From: Lin Ming <ming.m.lin@intel.com>
In-Reply-To: <20090226112232.GE32756@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
	 <1235639427.11390.11.camel@minggr> <20090226110336.GC32756@csn.ul.ie>
	 <1235647139.16552.34.camel@penberg-laptop>
	 <20090226112232.GE32756@csn.ul.ie>
Content-Type: text/plain
Date: Fri, 27 Feb 2009 16:44:43 +0800
Message-Id: <1235724283.11610.212.camel@minggr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-26 at 19:22 +0800, Mel Gorman wrote: 
> In that case, Lin, could I also get the profiles for UDP-U-4K please so I
> can see how time is being spent and why it might have gotten worse?

I have done the profiling (oltp and UDP-U-4K) with and without your v2
patches applied to 2.6.29-rc6.
I also enabled CONFIG_DEBUG_INFO so you can translate address to source
line with addr2line.

You can download the oprofile data and vmlinux from below link,
http://www.filefactory.com/file/af2330b/

Lin Ming



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
