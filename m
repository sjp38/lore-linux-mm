Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 00FB56B0037
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 15:28:32 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id el20so4281246lab.21
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 12:28:32 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id bm6si76537988lbb.30.2014.07.08.12.28.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jul 2014 12:28:31 -0700 (PDT)
Message-ID: <53BC465D.7030205@parallels.com>
Date: Tue, 8 Jul 2014 23:28:29 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Don't forget to set softdirty on file mapped fault
References: <20140708192151.GD17860@moon.sw.swsoft.com>
In-Reply-To: <20140708192151.GD17860@moon.sw.swsoft.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

On 07/08/2014 11:21 PM, Cyrill Gorcunov wrote:
> Otherwise we may not notice that pte was softdirty because pte_mksoft_dirty
> helper _returns_ new pte but not modifies argument.
> 
> CC: Pavel Emelyanov <xemul@parallels.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

> ---
>  mm/memory.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.git/mm/memory.c
> ===================================================================
> --- linux-2.6.git.orig/mm/memory.c
> +++ linux-2.6.git/mm/memory.c
> @@ -2744,7 +2744,7 @@ void do_set_pte(struct vm_area_struct *v
>  	if (write)
>  		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>  	else if (pte_file(*pte) && pte_file_soft_dirty(*pte))
> -		pte_mksoft_dirty(entry);
> +		entry = pte_mksoft_dirty(entry);
>  	if (anon) {
>  		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
>  		page_add_new_anon_rmap(page, vma, address);
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
