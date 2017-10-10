Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29D576B026A
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 05:34:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l188so58140095pfc.7
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 02:34:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p14si7883062pgq.601.2017.10.10.02.34.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 02:34:47 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm: reducing page_owner structure size
References: <CGME20171010082637epcas5p4b5d588057b336b4056b7bd2f84d52b32@epcas5p4.samsung.com>
 <1507623917-37991-1-git-send-email-ayush.m@samsung.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <31948332-8f98-00c7-4da0-a8d20dacb3ba@suse.cz>
Date: Tue, 10 Oct 2017 11:34:44 +0200
MIME-Version: 1.0
In-Reply-To: <1507623917-37991-1-git-send-email-ayush.m@samsung.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ayush Mittal <ayush.m@samsung.com>, akpm@linux-foundation.org, vinmenon@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: a.sahrawat@samsung.com, pankaj.m@samsung.com, v.narang@samsung.com

On 10/10/2017 10:25 AM, Ayush Mittal wrote:
> Maximum page order can be at max 10 which can be accomodated
> in short data type(2 bytes).
> last_migrate_reason is defined as enum type whose values can
> be accomodated in short data type (2 bytes).
> 
> Total structure size is currently 16 bytes but after changing structure
> size it goes to 12 bytes.
> 
> Signed-off-by: Ayush Mittal <ayush.m@samsung.com>

Looks like it works, so why not.
Before:
[    0.001000] allocated 50331648 bytes of page_ext
After:
[    0.001000] allocated 41943040 bytes of page_ext

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_owner.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 0fd9dcf..4ab438a 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -19,9 +19,9 @@
>  #define PAGE_OWNER_STACK_DEPTH (16)
>  
>  struct page_owner {
> -	unsigned int order;
> +	unsigned short order;
> +	short last_migrate_reason;
>  	gfp_t gfp_mask;
> -	int last_migrate_reason;
>  	depot_stack_handle_t handle;
>  };
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
