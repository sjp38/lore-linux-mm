Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 67C9B4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 03:32:20 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l66so15081162wml.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 00:32:20 -0800 (PST)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id q127si18933037wmd.3.2016.02.04.00.32.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 00:32:19 -0800 (PST)
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 4 Feb 2016 08:32:18 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 938771B08072
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 08:32:26 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u148WFS066322432
	for <linux-mm@kvack.org>; Thu, 4 Feb 2016 08:32:15 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u148WEWS008878
	for <linux-mm@kvack.org>; Thu, 4 Feb 2016 03:32:15 -0500
Subject: Re: [PATCH 1/5] mm/vmalloc: query dynamic DEBUG_PAGEALLOC setting
References: <1454565386-10489-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1454565386-10489-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56B30C8E.200@de.ibm.com>
Date: Thu, 4 Feb 2016 09:32:14 +0100
MIME-Version: 1.0
In-Reply-To: <1454565386-10489-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Chris Metcalf <cmetcalf@ezchip.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/04/2016 06:56 AM, Joonsoo Kim wrote:
> We can disable debug_pagealloc processing even if the code is complied
> with CONFIG_DEBUG_PAGEALLOC. This patch changes the code to query
> whether it is enabled or not in runtime.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Christian Borntraeger <borntraeger@de.ibm.com>


> ---
>  mm/vmalloc.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index fb42a5b..e0e51bd 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -543,10 +543,10 @@ static void vmap_debug_free_range(unsigned long start, unsigned long end)
>  	 * debugging doesn't do a broadcast TLB flush so it is a lot
>  	 * faster).
>  	 */
> -#ifdef CONFIG_DEBUG_PAGEALLOC
> -	vunmap_page_range(start, end);
> -	flush_tlb_kernel_range(start, end);
> -#endif
> +	if (debug_pagealloc_enabled()) {
> +		vunmap_page_range(start, end);
> +		flush_tlb_kernel_range(start, end);
> +	}
>  }
> 
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
