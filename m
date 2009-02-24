Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2FE0B6B00C1
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:33:07 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 765EB82C447
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:37:44 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dZgWE2ZU6Ks2 for <linux-mm@kvack.org>;
	Tue, 24 Feb 2009 12:37:39 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 371B682C444
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:37:33 -0500 (EST)
Date: Tue, 24 Feb 2009 12:24:28 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 06/19] Check only once if the zonelist is suitable for
 the allocation
In-Reply-To: <1235477835-14500-7-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0902241220300.32227@qirst.com>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235477835-14500-7-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Feb 2009, Mel Gorman wrote:

> It is possible with __GFP_THISNODE that no zones are suitable. This
> patch makes sure the check is only made once.

GFP_THISNODE is only a performance factor if SLAB is the slab allocator.
The restart logic in __alloc_pages_internal() is mainly used by OOM
processing.

But the patch looks okay regardless...

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
