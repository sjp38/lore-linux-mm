Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BF2DF6B004F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 03:57:24 -0400 (EDT)
Subject: Re: [PATCH 13/25] Inline __rmqueue_smallest()
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1240266011-11140-14-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
	 <1240266011-11140-14-git-send-email-mel@csn.ul.ie>
Date: Tue, 21 Apr 2009 10:58:15 +0300
Message-Id: <1240300695.771.54.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-04-20 at 23:19 +0100, Mel Gorman wrote:
> Inline __rmqueue_smallest by altering flow very slightly so that there
> is only one call site. This allows the function to be inlined without
> additional text bloat.

Quite frankly, I think these patch changelogs could use some before and
after numbers for "size mm/page_alloc.o" because it's usually the case
that kernel text shrinks when you _remove_ inlines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
