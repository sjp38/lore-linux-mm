Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 0176D6B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 14:55:51 -0400 (EDT)
Message-ID: <52092FB5.3060300@intel.com>
Date: Mon, 12 Aug 2013 11:55:49 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscan: decrease cma pages from nr_reclaimed
References: <1376322661-20917-1-git-send-email-haojian.zhuang@gmail.com>
In-Reply-To: <1376322661-20917-1-git-send-email-haojian.zhuang@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: m.szyprowski@samsung.com, linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de

On 08/12/2013 08:51 AM, Haojian Zhuang wrote:
> @@ -987,6 +991,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  					 * leave it off the LRU).
>  					 */
>  					nr_reclaimed++;
> +#ifdef CONFIG_CMA
> +					if (get_pageblock_migratetype(page) ==
> +						MIGRATE_CMA)
> +						nr_reclaimed_cma++;
> +#endif
>  					continue;
>  				}
>  			}

Throwing four #ifdefs like that in to any is pretty mean.  Doing it to
shrink_page_list() is just cruel. :)

Can you think of a way to do this without so many explicit #ifdefs in a
.c file?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
