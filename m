Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 320496B0031
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 18:28:02 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so8619182pdi.35
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 15:28:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id h3si9608821paw.455.2014.04.14.15.28.00
        for <linux-mm@kvack.org>;
        Mon, 14 Apr 2014 15:28:01 -0700 (PDT)
Date: Mon, 14 Apr 2014 15:27:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/4] mm: Dont forget to set softdirty on file mapped
 fault
Message-Id: <20140414152758.a9a80782dbb94c74a27f683a@linux-foundation.org>
In-Reply-To: <20140324125926.013008345@openvz.org>
References: <20140324122838.490106581@openvz.org>
	<20140324125926.013008345@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, xemul@parallels.com

On Mon, 24 Mar 2014 16:28:40 +0400 Cyrill Gorcunov <gorcunov@openvz.org> wrote:

> Otherwise we may not notice that pte was softdirty.
> 
> --- linux-2.6.git.orig/mm/memory.c
> +++ linux-2.6.git/mm/memory.c
> @@ -3422,7 +3422,7 @@ static int __do_fault(struct mm_struct *
>  		if (flags & FAULT_FLAG_WRITE)
>  			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>  		else if (pte_file(orig_pte) && pte_file_soft_dirty(orig_pte))
> -			pte_mksoft_dirty(entry);
> +			entry = pte_mksoft_dirty(entry);
>  		if (anon) {
>  			inc_mm_counter_fast(mm, MM_ANONPAGES);
>  			page_add_new_anon_rmap(page, vma, address);

This will need to be redone for current kernels, please.  New patch, new
title, new changelog, retest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
