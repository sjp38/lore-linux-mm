Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6BEF86B0055
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 22:08:14 -0500 (EST)
Date: Tue, 29 Nov 2011 11:08:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] readahead: basic support for backwards prefetching
Message-ID: <20111129030809.GB19506@localhost>
References: <20111121091819.394895091@intel.com>
 <20111121093846.887841399@intel.com>
 <20111121153309.d2a410fb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121153309.d2a410fb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Li Shaohua <shaohua.li@intel.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 21, 2011 at 03:33:09PM -0800, Andrew Morton wrote:
> On Mon, 21 Nov 2011 17:18:26 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Add the backwards prefetching feature. It's pretty simple if we don't
> > support async prefetching and interleaved reads.
> 
> Well OK, but I wonder how many applications out there read files in
> reverse order.  Is it common enough to bother special-casing in the
> kernel like this?

Maybe not so many applications, but sure there are some real cases
somewhere. I remember an IBM paper (that's many years ago, so cannot
recall the exact title) on database shows a graph containing backwards
reading curves among the other ones.

Recently Shaohua even run into a performance regression caused by glibc
optimizing memcpy to access page in reverse order (15, 14, 13, ... 0).

Well this patch may not be the most pertinent fix to that particular
issue. But you see the opportunity such access patterns arise from
surprised areas. 

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
