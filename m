Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 09E696B6DA9
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:48:34 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id y88so13347216pfi.9
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:48:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q9si14855889pgh.92.2018.12.03.23.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:48:32 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB47iMWD098759
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 02:48:32 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p5k34x5yu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 02:48:32 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 4 Dec 2018 07:48:29 -0000
Date: Tue, 4 Dec 2018 09:48:24 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 2/3] mm: move two private functions to static linkage
References: <466ad4ebe5d788e7be6a14fbbcaaa9596bac7141.1543899764.git.dato@net.com.org.es>
 <75cae66d92a074dbd62590a966d7005b187f4fe5.1543899764.git.dato@net.com.org.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <75cae66d92a074dbd62590a966d7005b187f4fe5.1543899764.git.dato@net.com.org.es>
Message-Id: <20181204074823.GG26700@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adeodato =?iso-8859-1?Q?Sim=F3?= <dato@net.com.org.es>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Tue, Dec 04, 2018 at 02:14:23AM -0300, Adeodato Sim� wrote:
> follow_page_context() and __thp_get_unmapped_area() have no public
> declarations and are only used in the files that define them (mm/gup.c
> and mm/huge_memory.c, respectively).
> 
> This change also appeases GCC if run with -Wmissing-prototypes.
> 
> Signed-off-by: Adeodato Sim� <dato@net.com.org.es>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  mm/gup.c         | 6 +++---
>  mm/huge_memory.c | 5 +++--
>  2 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 6dd33e16a806..86a10a9b0344 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -399,9 +399,9 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
>   * an error pointer if there is a mapping to something not represented
>   * by a page descriptor (see also vm_normal_page()).
>   */
> -struct page *follow_page_mask(struct vm_area_struct *vma,
> -			      unsigned long address, unsigned int flags,
> -			      struct follow_page_context *ctx)
> +static struct page *follow_page_mask(struct vm_area_struct *vma,
> +				     unsigned long address, unsigned int flags,
> +				     struct follow_page_context *ctx)
>  {
>  	pgd_t *pgd;
>  	struct page *page;
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 2dba2c1c299a..45c1ff36baf1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -499,8 +499,9 @@ void prep_transhuge_page(struct page *page)
>  	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
>  }
> 
> -unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
> -		loff_t off, unsigned long flags, unsigned long size)
> +static unsigned long __thp_get_unmapped_area(struct file *filp,
> +		unsigned long len, loff_t off, unsigned long flags,
> +		unsigned long size)
>  {
>  	unsigned long addr;
>  	loff_t off_end = off + len;
> -- 
> 2.19.2
> 

-- 
Sincerely yours,
Mike.
