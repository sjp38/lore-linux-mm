Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 212D26B0253
	for <linux-mm@kvack.org>; Sun, 25 Oct 2015 19:22:08 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so176248589pac.3
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 16:22:07 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id ph4si48602591pbb.177.2015.10.25.16.22.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Oct 2015 16:22:07 -0700 (PDT)
Received: by pabuq3 with SMTP id uq3so3592852pab.0
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 16:22:07 -0700 (PDT)
Date: Sun, 25 Oct 2015 16:22:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 4/6] ksm: use the helper method to do the hlist_empty
 check
In-Reply-To: <1444925065-4841-5-git-send-email-aarcange@redhat.com>
Message-ID: <alpine.LSU.2.11.1510251621360.1923@eggly.anvils>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com> <1444925065-4841-5-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 15 Oct 2015, Andrea Arcangeli wrote:

> This just uses the helper function to cleanup the assumption on the
> hlist_node internals.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  mm/ksm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 929b5c2..241588e 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -661,7 +661,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
>  		unlock_page(page);
>  		put_page(page);
>  
> -		if (stable_node->hlist.first)
> +		if (!hlist_empty(&stable_node->hlist))
>  			ksm_pages_sharing--;
>  		else
>  			ksm_pages_shared--;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
