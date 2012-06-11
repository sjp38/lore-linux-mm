Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 125D66B00BA
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 02:16:10 -0400 (EDT)
Message-ID: <4FD58D28.2030808@kernel.org>
Date: Mon, 11 Jun 2012 15:16:08 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 09/10] mm: frontswap: split out function to clear a
 page out
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com> <1339325468-30614-10-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-10-git-send-email-levinsasha928@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/10/2012 07:51 PM, Sasha Levin wrote:

> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  mm/frontswap.c |   15 +++++++++------
>  1 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 7da55a3..c056f6e 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -120,6 +120,12 @@ void __frontswap_init(unsigned type)
>  }
>  EXPORT_SYMBOL(__frontswap_init);
>  
> +static inline void __frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
> +{
> +	frontswap_clear(sis, offset);
> +	atomic_dec(&sis->frontswap_pages);
> +}


Nipick:
Strange, Normally, NOT underscore function calls underscore function.
But this is opposite. :(

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
