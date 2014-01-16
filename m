Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f42.google.com (mail-qe0-f42.google.com [209.85.128.42])
	by kanga.kvack.org (Postfix) with ESMTP id D10A26B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:32:36 -0500 (EST)
Received: by mail-qe0-f42.google.com with SMTP id b4so2975851qen.29
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 10:32:36 -0800 (PST)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id u9si10760815qap.58.2014.01.16.10.32.33
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 10:32:34 -0800 (PST)
Date: Thu, 16 Jan 2014 12:32:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 4/9] mm: slabs: reset page at free
In-Reply-To: <20140114180054.20A1B660@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.10.1401161232010.30036@nuc>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180054.20A1B660@viggo.jf.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On Tue, 14 Jan 2014, Dave Hansen wrote:

> diff -puN include/linux/mm.h~slub-reset-page-at-free include/linux/mm.h
> --- a/include/linux/mm.h~slub-reset-page-at-free	2014-01-14 09:57:57.099666808 -0800
> +++ b/include/linux/mm.h	2014-01-14 09:57:57.110667301 -0800
> @@ -2076,5 +2076,16 @@ static inline void set_page_pfmemalloc(s
>  	page->index = pfmemalloc;
>  }
>
> +/*
> + * Custom allocators (like the slabs) use 'struct page' fields
> + * for all kinds of things.  This resets the page's state so that
> + * the buddy allocator will be happy with it.
> + */
> +static inline void allocator_reset_page(struct page *page)
> +{
> +	page->mapping = NULL;
> +	page_mapcount_reset(page);
> +}
> +
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_MM_H */

This belongs into mm/slab.h

Otherwise Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
