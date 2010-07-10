Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5876B024D
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 06:57:09 -0400 (EDT)
Date: Sat, 10 Jul 2010 12:57:00 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] slob: remove unused funtion
Message-ID: <20100710105700.GD25806@cmpxchg.org>
References: <1278756353-6884-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278756353-6884-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Sat, Jul 10, 2010 at 06:05:53PM +0800, Bob Liu wrote:
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

It is not unused!  Try `make mm/slob.o' with the following patch
applied:

diff --git a/mm/slob.c b/mm/slob.c
index 23631e2..d50ff8e 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -106,6 +106,7 @@ struct slob_page {
 		};
 		struct page page;
 	};
+	unsigned long foo;
 };
 static inline void struct_slob_page_wrong_size(void)
 { BUILD_BUG_ON(sizeof(struct slob_page) != sizeof(struct page)); }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
