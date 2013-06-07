Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 5A22F6B0031
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 16:51:35 -0400 (EDT)
Message-ID: <1370638293.2209.134.camel@joe-AO722>
Subject: Re: [PATCH] non-swapcache pages in end_swap_bio_read()
From: Joe Perches <joe@perches.com>
Date: Fri, 07 Jun 2013 13:51:33 -0700
In-Reply-To: <20130607134303.a9bcff78691c38b03a8b3dde@linux-foundation.org>
References: <20130607152653.GA3586@blaptop>
	 <1370636598-5405-1-git-send-email-artem.savkov@gmail.com>
	 <20130607134303.a9bcff78691c38b03a8b3dde@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Artem Savkov <artem.savkov@gmail.com>, minchan.kernel.2@gmail.com, dan.magenheimer@oracle.com, rjw@sisk.pl, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 2013-06-07 at 13:43 -0700, Andrew Morton wrote:
> On Sat,  8 Jun 2013 00:23:18 +0400 Artem Savkov <artem.savkov@gmail.com> wrote:
[]
> +++ a/mm/page_io.c
[]
> +	/*
> +	 * There is no guarantee that the page is in swap cache - the software
> +	 * suspend code (at least) uses end_swap_bio_read() against a non-
> +	 * swapcache page.  So we must check PG_swapcache before proceeding with
> +	 * this optimization.
> +	 */
> +	if (likely(PageSwapCache(page))) {

or

	if (unlikely(!PageSwapCache(page)))
		goto out;

to save an indent level

> +out:
>  	unlock_page(page);
>  	bio_put(bio);
>  }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
