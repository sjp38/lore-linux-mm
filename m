Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 169E66B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 18:34:31 -0400 (EDT)
Date: Tue, 18 Aug 2009 15:57:00 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH 1/3] page-allocator: Split per-cpu list into
 one-list-per-migrate-type
In-Reply-To: <1250594162-17322-2-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.0908181550450.31547@mail.selltech.ca>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie> <1250594162-17322-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Aug 2009, Mel Gorman wrote:

> +	/*
> +	 * We only track unreclaimable, reclaimable and movable on pcp lists.
			 ^^^^^^^^^^^^^  
Is it unmovable? I don't see unreclaimable migrate type on pcp lists. 
Just ask to make sure I undsterstand the comment right.

> +	 * Free ISOLATE pages back to the allocator because they are being
> +	 * offlined but treat RESERVE as movable pages so we can get those
> +	 * areas back if necessary. Otherwise, we may have to free
> +	 * excessively into the page allocator
> +	 */
> +	if (migratetype >= MIGRATE_PCPTYPES) {
> +		if (unlikely(migratetype == MIGRATE_ISOLATE)) {
> +			free_one_page(zone, page, 0, migratetype);
> +			goto out;
> +		}
> +		migratetype = MIGRATE_MOVABLE;
> +	}
> +

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
