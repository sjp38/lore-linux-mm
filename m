Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E78C26B0047
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 09:31:25 -0500 (EST)
Message-ID: <4B83E6AC.8030306@redhat.com>
Date: Tue, 23 Feb 2010 09:31:08 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/3] vmscan: factor out page reference checks
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org> <1266868150-25984-2-git-send-email-hannes@cmpxchg.org> <1266932303.2723.13.camel@barrios-desktop> <20100223142158.GA29762@cmpxchg.org>
In-Reply-To: <20100223142158.GA29762@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 02/23/2010 09:21 AM, Johannes Weiner wrote:

> From: Johannes Weiner<hannes@cmpxchg.org>
> Subject: vmscan: improve comment on mlocked page in reclaim
>
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>
> ---
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 674a78b..819fff7 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -578,7 +578,10 @@ static enum page_references page_check_references(struct page *page,
>   	if (sc->order>  PAGE_ALLOC_COSTLY_ORDER)
>   		return PAGEREF_RECLAIM;
>
> -	/* Mlock lost isolation race - let try_to_unmap() handle it */
> +	/*
> +	 * Mlock lost the isolation race with us.  Let try_to_unmap()
> +	 * move the page to the unevictable list.
> +	 */
>   	if (vm_flags&  VM_LOCKED)
>   		return PAGEREF_RECLAIM;

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
