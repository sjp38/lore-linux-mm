Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E1C216B005A
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 01:58:30 -0400 (EDT)
Message-ID: <49ED5FC6.4010007@cs.helsinki.fi>
Date: Tue, 21 Apr 2009 08:55:18 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 01/25] Replace __alloc_pages_internal() with __alloc_pages_nodemask()
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1240266011-11140-2-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> __alloc_pages_internal is the core page allocator function but
> essentially it is an alias of __alloc_pages_nodemask. Naming a publicly
> available and exported function "internal" is also a big ugly. This
> patch renames __alloc_pages_internal() to __alloc_pages_nodemask() and
> deletes the old nodemask function.
> 
> Warning - This patch renames an exported symbol. No kernel driver is
> affected by external drivers calling __alloc_pages_internal() should
> change the call to __alloc_pages_nodemask() without any alteration of
> parameters.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
