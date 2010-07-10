Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 48D696B024D
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 10:57:38 -0400 (EDT)
Subject: Re: [PATCH] slob: remove unused funtion
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1278756353-6884-1-git-send-email-lliubbo@gmail.com>
References: <1278756353-6884-1-git-send-email-lliubbo@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 10 Jul 2010 09:57:33 -0500
Message-ID: <1278773853.936.1.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

On Sat, 2010-07-10 at 18:05 +0800, Bob Liu wrote:
> funtion struct_slob_page_wrong_size() is not used anymore, remove it
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/slob.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/slob.c b/mm/slob.c
> index d582171..832d2b5 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -109,8 +109,6 @@ struct slob_page {
>  		struct page page;
>  	};
>  };
> -static inline void struct_slob_page_wrong_size(void)
> -{ BUILD_BUG_ON(sizeof(struct slob_page) != sizeof(struct page)); }

This function exists to raise a compile error if the structure sizes
mismatch, and doesn't actually get included in the compiled output.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
