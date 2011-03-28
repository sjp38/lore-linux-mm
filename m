Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 45FCB8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:41:45 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2SFHFia029961
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:17:24 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 185D96E8043
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:41:40 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2SFfdZS342894
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:41:39 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2SFfXYX014852
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 12:41:38 -0300
Subject: Re: [PATCH 2/3] mm: Add SECTION_ALIGN_UP() and
 SECTION_ALIGN_DOWN() macro
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110328092412.GC13826@router-fw-old.local.net-space.pl>
References: <20110328092412.GC13826@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 28 Mar 2011 08:41:24 -0700
Message-ID: <1301326884.31700.8321.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-03-28 at 11:24 +0200, Daniel Kiper wrote:
> Add SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN() macro which aligns
> given pfn to upper section and lower section boundary accordingly.
> 
> Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
> ---
>  include/linux/mmzone.h |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
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

There are certainly a lot of different ways to do this, including using
the existing ALIGN() macro, but you won't be the first to open-code
it. :)

Acked-by: Dave Hansen <dave@linux.vnet.ibm.com>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
