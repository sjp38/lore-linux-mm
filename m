Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5A26B004D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 13:56:04 -0400 (EDT)
Date: Fri, 24 Apr 2009 10:51:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/22] Calculate the alloc_flags for allocation only
 once
Message-Id: <20090424105115.18fec653.akpm@linux-foundation.org>
In-Reply-To: <20090424104716.GE14283@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	<1240408407-21848-10-git-send-email-mel@csn.ul.ie>
	<20090423155216.07ef773e.akpm@linux-foundation.org>
	<20090424104716.GE14283@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com, peterz@infradead.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Fri, 24 Apr 2009 11:47:17 +0100 Mel Gorman <mel@csn.ul.ie> wrote:

> Uninline gfp_to_alloc_flags() in the page allocator slow path

Well, there are <boggle> 37 inlines in page_alloc.c, so uninlining a
single function (and leaving its layout mucked up ;)) is a bit random.

Perhaps sometime you could take a look at "[patch] page allocator:
rationalise inlining"?

I'm kind of in two minds about it.  Do we really know that all approved
versions of gcc will do the most desirable thing in all circumstances
on all architectures?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
