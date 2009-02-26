Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0362E6B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 07:27:49 -0500 (EST)
Received: by wf-out-1314.google.com with SMTP id 28so573460wfa.11
        for <linux-mm@kvack.org>; Thu, 26 Feb 2009 04:27:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090226112232.GE32756@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
	 <1235639427.11390.11.camel@minggr> <20090226110336.GC32756@csn.ul.ie>
	 <1235647139.16552.34.camel@penberg-laptop>
	 <20090226112232.GE32756@csn.ul.ie>
Date: Thu, 26 Feb 2009 20:27:48 +0800
Message-ID: <d3f22a0902260427s286bff7bkdb7eb1ef4bb685ed@mail.gmail.com>
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
From: Lin Ming <lin@minggr.cn>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Lin Ming <ming.m.lin@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 26, 2009 at 7:22 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> In that case, Lin, could I also get the profiles for UDP-U-4K please so I
> can see how time is being spent and why it might have gotten worse?

OK.
I'll do profiling tomorrow when I get back to work.

Lin Ming

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
