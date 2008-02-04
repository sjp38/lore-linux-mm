Date: Mon, 4 Feb 2008 09:33:51 +0000
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH] modify incorrected word in comment of clear_active_flags
Message-ID: <20080204093351.GD14362@shadowen.org>
References: <28c262360802012236w3a1b4253h2a6ad96570d4a634@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28c262360802012236w3a1b4253h2a6ad96570d4a634@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: minchan kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 02, 2008 at 03:36:54PM +0900, minchan kim wrote:
> I think is was a mistake.
> clear_active_flags is just called by shrink_inactive_list.
> 
> --- mm/vmscan.c.orig  2008-02-02 15:21:52.000000000 +0900
> +++ mm/vmscan.c 2008-02-02 15:20:46.000000000 +0900
> @@ -761,7 +761,7 @@ static unsigned long isolate_lru_pages(u
>  }
> 
>  /*
> - * clear_active_flags() is a helper for shrink_active_list(), clearing
> + * clear_active_flags() is a helper for shrink_inactive_list(), clearing
>   * any active bits from the pages in the list.
>   */
>  static unsigned long clear_active_flags(struct list_head *page_list)

Yeah that is a silly typo.

Acked-by: Andy Whitcroft <apw@shadowen.org>

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
