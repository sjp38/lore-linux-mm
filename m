Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 575056B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 23:21:40 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p4J3Lajc000887
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:21:36 -0700
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by wpaz9.hot.corp.google.com with ESMTP id p4J3LYMr015252
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:21:34 -0700
Received: by pzk35 with SMTP id 35so1392576pzk.39
        for <linux-mm@kvack.org>; Wed, 18 May 2011 20:21:34 -0700 (PDT)
Date: Wed, 18 May 2011 20:21:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V3 1/2] mm: Add SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN()
 macro
In-Reply-To: <20110517213750.GB30232@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1105182019170.20651@chino.kir.corp.google.com>
References: <20110517213750.GB30232@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, Dave Hansen <dave@linux.vnet.ibm.com>, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 17 May 2011, Daniel Kiper wrote:

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d715200..217bcf6 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -956,6 +956,9 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
>  #define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
>  #define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
>  
> +#define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
> +#define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
> +
>  struct page;
>  struct page_cgroup;
>  struct mem_section {

These seem useful.  Could you convert the code in drivers/base/node.c, 
mm/page_cgroup.c, mm/page_alloc.c, and mm/sparse.c that already do this to 
use the new macros?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
