Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A74658D0001
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 19:06:45 -0500 (EST)
Date: Mon, 8 Nov 2010 16:05:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v2][PATCH] [v2] Revalidate page->mapping in
 do_generic_file_read()
Message-Id: <20101108160555.2925ea57.akpm@linux-foundation.org>
In-Reply-To: <20101105211615.2D67A348@kernel.beaverton.ibm.com>
References: <20101105211615.2D67A348@kernel.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, arunabal@in.ibm.com, sbest@us.ibm.com, stable <stable@kernel.org>, Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, 05 Nov 2010 14:16:15 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> --- linux-2.6.git/mm/filemap.c~is_partially_uptodate-revalidate-page	2010-11-03 13:49:21.000000000 -0700
> +++ linux-2.6.git-dave/mm/filemap.c	2010-11-04 06:59:08.000000000 -0700
> @@ -1016,6 +1016,9 @@ find_page:
>  				goto page_not_up_to_date;
>  			if (!trylock_page(page))
>  				goto page_not_up_to_date;
> +			/* Did it get truncated before we got the lock? */
> +			if (!page->mapping)
> +				goto page_not_up_to_date_locked;
>  			if (!mapping->a_ops->is_partially_uptodate(page,
>  								desc, offset))
>  				goto page_not_up_to_date_locked;

whoops.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
