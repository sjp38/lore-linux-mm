Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 7D5F06B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 19:20:44 -0500 (EST)
Date: Wed, 9 Jan 2013 16:20:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: prevent to add a page to swap if may_writepage
 is unset
Message-Id: <20130109162042.79a9fedd.akpm@linux-foundation.org>
In-Reply-To: <1357712474-27595-2-git-send-email-minchan@kernel.org>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
	<1357712474-27595-2-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed,  9 Jan 2013 15:21:13 +0900
Minchan Kim <minchan@kernel.org> wrote:

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -780,6 +780,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (PageAnon(page) && !PageSwapCache(page)) {
>  			if (!(sc->gfp_mask & __GFP_IO))
>  				goto keep_locked;
> +			if (!sc->may_writepage)
> +				goto keep_locked;
>  			if (!add_to_swap(page))
>  				goto activate_locked;
>  			may_enter_fs = 1;

We should add a comment here explaining what's going on.  But I can't
suggest anything which sounds rational because this looks so wrong :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
