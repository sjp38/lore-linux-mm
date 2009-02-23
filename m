Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C38556B00A5
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 09:00:38 -0500 (EST)
Subject: Re: [PATCH] mm: gfp_to_alloc_flags()
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1235390103.4645.80.camel@laptop>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	 <1235390103.4645.80.camel@laptop>
Date: Mon, 23 Feb 2009 16:00:35 +0200
Message-Id: <1235397635.6216.62.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-02-23 at 12:55 +0100, Peter Zijlstra wrote:
> Subject: mm: gfp_to_alloc_flags()
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Mon Feb 23 12:46:36 CET 2009
> 
> Clean up the code by factoring out the gfp to alloc_flags mapping.
> 
> [neilb@suse.de says]
> As the test:
> 
> -       if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
> -                       && !in_interrupt()) {
> -               if (!(gfp_mask & __GFP_NOMEMALLOC)) {
> 
> has been replaced with a slightly weaker one:
> 
> +       if (alloc_flags & ALLOC_NO_WATERMARKS) {
> 
> we need to ensure we don't recurse when PF_MEMALLOC is set
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
