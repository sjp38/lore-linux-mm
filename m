Received: by fg-out-1718.google.com with SMTP id 19so555986fgg.4
        for <linux-mm@kvack.org>; Tue, 06 May 2008 11:18:49 -0700 (PDT)
Message-ID: <6101e8c40805061118u440cb332vf128085bb7df98c@mail.gmail.com>
Date: Tue, 6 May 2008 20:18:28 +0200
From: "Oliver Pinter" <oliver.pntr@gmail.com>
Subject: Re: [PATCH] mm/page_alloc.c: fix a typo
In-Reply-To: <4820272C.4060009@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4820272C.4060009@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, stable@kernel.org, stable@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/6/08, Li Zefan <lizf@cn.fujitsu.com> wrote:
>
> ---
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bdd5c43..d0ba10d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -303,7 +303,7 @@ static void destroy_compound_page(struct page *page,
> unsigned long order)
>  	for (i = 1; i < nr_pages; i++) {
>  		struct page *p = page + i;
>
> -		if (unlikely(!PageTail(p) |
> +		if (unlikely(!PageTail(p) ||
>  				(p->first_page != page)))
>  			bad_page(page);
>  		__ClearPageTail(p);
> -- 1.5.4.rc3
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


-- 
Thanks,
Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
