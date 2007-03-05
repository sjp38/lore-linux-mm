Date: Mon, 5 Mar 2007 17:12:24 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
Message-ID: <20070305171224.GB2909@infradead.org>
References: <20070305161746.GD8128@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070305161746.GD8128@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <clameter@engr.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 05, 2007 at 05:17:46PM +0100, Nick Piggin wrote:
> +#include "internal.h"
> +
> +#define page_mlock_count(page)		(*(unsigned long *)&(page)->lru.next)
> +#define set_page_mlock_count(page, v)	(page_mlock_count(page) = (v))
> +#define inc_page_mlock_count(page)	(page_mlock_count(page)++)
> +#define dec_page_mlock_count(page)	(page_mlock_count(page)--)

Now that we've dropped support for old gccs this would be a lot using
anonymous unions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
