Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0B23C900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:51:21 -0400 (EDT)
Date: Fri, 15 Apr 2011 09:51:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: make read-only accessors take const parameters
In-Reply-To: <1302861377-8048-2-git-send-email-ext-phil.2.carmody@nokia.com>
Message-ID: <alpine.DEB.2.00.1104150949210.5863@router.home>
References: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com> <1302861377-8048-2-git-send-email-ext-phil.2.carmody@nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 15 Apr 2011, Phil Carmody wrote:

> +++ b/include/linux/mm.h
> @@ -353,9 +353,16 @@ static inline struct page *compound_head(struct page *page)
>  	return page;
>  }
>
> -static inline int page_count(struct page *page)
> +static inline const struct page *compound_head_ro(const struct page *page)
>  {
> -	return atomic_read(&compound_head(page)->_count);
> +	if (unlikely(PageTail(page)))
> +		return page->first_page;
> +	return page;
> +}

Can you make compound_head take a const pointer too to avoid this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
