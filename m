Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EDB196B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 18:23:28 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id yy13so104862730pab.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:23:28 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id we2si4873799pac.127.2016.01.26.15.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 15:23:28 -0800 (PST)
Received: by mail-pa0-x235.google.com with SMTP id yy13so104862615pab.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:23:28 -0800 (PST)
Date: Tue, 26 Jan 2016 15:23:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH/RFC 1/3] mm: provide debug_pagealloc_enabled() without
 CONFIG_DEBUG_PAGEALLOC
In-Reply-To: <1453799905-10941-2-git-send-email-borntraeger@de.ibm.com>
Message-ID: <alpine.DEB.2.10.1601261521560.25141@chino.kir.corp.google.com>
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com> <1453799905-10941-2-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org

On Tue, 26 Jan 2016, Christian Borntraeger wrote:

> We can provide debug_pagealloc_enabled() also if CONFIG_DEBUG_PAGEALLOC
> is not set. It will return false in that case.
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> ---
>  include/linux/mm.h | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7783073..fbc5354 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2148,6 +2148,10 @@ kernel_map_pages(struct page *page, int numpages, int enable)
>  extern bool kernel_page_present(struct page *page);
>  #endif /* CONFIG_HIBERNATION */
>  #else
> +static inline bool debug_pagealloc_enabled(void)
> +{
> +	return false;
> +}
>  static inline void
>  kernel_map_pages(struct page *page, int numpages, int enable) {}
>  #ifdef CONFIG_HIBERNATION

Since the patchset needs to be refreshed based on Heiko and Thomas's 
comments, please add some /* CONFIG_DEBUG_PAGEALLOC */ annotation to the 
#else and #endif lines so this block is easier to read.  After that, feel 
free to add

	Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
