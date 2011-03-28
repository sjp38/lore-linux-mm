Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0376A8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:46:35 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p2SMkWDG002311
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 15:46:32 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by hpaq13.eem.corp.google.com with ESMTP id p2SMkUOr017420
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 15:46:31 -0700
Received: by pwi5 with SMTP id 5so914656pwi.17
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 15:46:29 -0700 (PDT)
Date: Mon, 28 Mar 2011 15:46:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm: Add SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN()
 macro
In-Reply-To: <20110328092412.GC13826@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1103281545220.7148@chino.kir.corp.google.com>
References: <20110328092412.GC13826@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 28 Mar 2011, Daniel Kiper wrote:

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 02ecb01..d342820 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -931,6 +931,9 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
>  #define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
>  #define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
>  
> +#define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
> +#define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
> +
>  #ifdef CONFIG_SPARSEMEM
>  
>  /*

These are only valid for CONFIG_SPARSEMEM, so they need to be defined 
conditionally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
