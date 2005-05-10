Date: Tue, 10 May 2005 11:15:54 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [patch] mm: fix rss counter being incremented when unmapping
In-Reply-To: <20050509122916.GA30726@doener.homenet>
Message-ID: <Pine.LNX.4.58.0505101112540.19973@graphe.net>
References: <20050509122916.GA30726@doener.homenet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, =?iso-8859-1?Q?Bj=F6rn_Steinbrink?= <B.Steinbrink@gmx.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Correct. Thanks for catching that. My latest rss patch also has that.

On Mon, 9 May 2005, Bjorn Steinbrink wrote:

> This patch fixes a bug introduced by the "mm counter operations through
> macros" patch, which replaced a decrement operation in with an increment
> macro in try_to_unmap_one().
>
> Signed-off-by: Bjorn Steinbrink <B.Steinbrink@gmx.de>
>
> diff -NurpP --minimal linux-2.6.12-rc4/mm/rmap.c linux-2.6.12-rc4-fixed/mm/rmap.c
> --- linux-2.6.12-rc4/mm/rmap.c  2005-05-08 17:53:49.000000000 +0200
> +++ linux-2.6.12-rc4-fixed/mm/rmap.c    2005-05-09 13:38:03.000000000 +0200
> @@ -586,7 +586,7 @@ static int try_to_unmap_one(struct page
>                 dec_mm_counter(mm, anon_rss);
>         }
>
> -       inc_mm_counter(mm, rss);
> +       dec_mm_counter(mm, rss);
>         page_remove_rmap(page);
>         page_cache_release(page);
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
