Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A95926B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 09:37:55 -0500 (EST)
Date: Tue, 7 Dec 2010 15:37:38 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v4 1/7] Fix checkpatch's report in swap.c
Message-ID: <20101207143738.GA2356@cmpxchg.org>
References: <cover.1291568905.git.minchan.kim@gmail.com>
 <f4bc70172f1e6c7357480af503b7a01cd96ccadd.1291568905.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f4bc70172f1e6c7357480af503b7a01cd96ccadd.1291568905.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 06, 2010 at 02:29:09AM +0900, Minchan Kim wrote:
> checkpatch reports following problems.
> It's a very annoying. This patch fixes it.
>
> barrios@barrios-desktop:~/linux-2.6$ ./scripts/checkpatch.pl -f mm/swap.c
> WARNING: line over 80 characters
> +		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
> 
> WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> +EXPORT_SYMBOL(mark_page_accessed);
> 
> ERROR: code indent should use tabs where possible
> +  ^I^I}$
> 
> WARNING: please, no space before tabs
> +  ^I^I}$
> 
> WARNING: please, no spaces at the start of a line
> +  ^I^I}$
> 
> WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> +EXPORT_SYMBOL(__pagevec_release);
> 
> WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> +EXPORT_SYMBOL(____pagevec_lru_add);
> 
> WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> +EXPORT_SYMBOL(pagevec_lookup);
> 
> WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> +EXPORT_SYMBOL(pagevec_lookup_tag);
> 
> total: 1 errors, 8 warnings, 517 lines checked
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
