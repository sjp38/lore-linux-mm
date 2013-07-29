Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 41C546B003D
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 14:43:59 -0400 (EDT)
Received: by mail-vb0-f44.google.com with SMTP id e13so1422382vbg.17
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 11:43:58 -0700 (PDT)
Message-ID: <51F6B80A.3040805@gmail.com>
Date: Mon, 29 Jul 2013 14:44:26 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: page_alloc: Add unlikely for MAX_ORDER check
References: <1375022906-1164-1-git-send-email-waydi1@gmail.com>
In-Reply-To: <1375022906-1164-1-git-send-email-waydi1@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeungHun Lee <waydi1@gmail.com>
Cc: linux-mm@kvack.org, kosaki.motohiro@gmail.com

(7/28/13 10:48 AM), SeungHun Lee wrote:
> "order >= MAX_ORDER" case is occur rarely.
> 
> So I add unlikely for this check.
> ---
>   mm/page_alloc.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b8475ed..e644cf5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2408,7 +2408,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>   	 * be using allocators in order of preference for an area that is
>   	 * too large.
>   	 */
> -	if (order >= MAX_ORDER) {
> +	if (unlikely(order >= MAX_ORDER)) {
>   		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
>   		return NULL;

I don't think this improve any performance because here is a slowpath. However
I also don't find any issue to have this hint.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
