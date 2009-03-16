Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E36E66B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:35:55 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 34CE382D376
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:42:37 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id SGmuKGfn26pO for <linux-mm@kvack.org>;
	Mon, 16 Mar 2009 12:42:31 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B189182D2C7
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:40:05 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:31:44 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 30/35] Skip the PCP list search by counting the order
 and type of pages on list
In-Reply-To: <1237196790-7268-31-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903161231040.32577@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-31-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009, Mel Gorman wrote:

>
>  struct per_cpu_pages {
> -	int count;		/* number of pages in the list */
> +	/* The total number of pages on the PCP lists */
> +	int count;
> +
> +	/* Count of each migratetype and order */
> +	u8 mocount[MIGRATE_PCPTYPES][PAGE_ALLOC_COSTLY_ORDER+1];

What about overflow? You could have more than 255 pages of a given type in
a pcp.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
