Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 27C326B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 04:33:10 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so1546533eek.38
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 01:33:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si7259924eep.227.2014.04.24.01.33.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 01:33:08 -0700 (PDT)
Date: Thu, 24 Apr 2014 09:33:04 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/6] x86: mm: clean up tlb flushing code
Message-ID: <20140424083304.GP23991@suse.de>
References: <20140421182418.81CF7519@viggo.jf.intel.com>
 <20140421182420.307A0C57@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140421182420.307A0C57@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On Mon, Apr 21, 2014 at 11:24:20AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> The
> 
> 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
> 
> line of code is not exactly the easiest to audit, especially when
> it ends up at two different indentation levels.  This eliminates
> one of the the copy-n-paste versions.  It also gives us a unified
> exit point for each path through this function.  We need this in
> a minute for our tracepoint.
> 
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  b/arch/x86/mm/tlb.c |   23 +++++++++++------------
>  1 file changed, 11 insertions(+), 12 deletions(-)
> 
> diff -puN arch/x86/mm/tlb.c~simplify-tlb-code arch/x86/mm/tlb.c
> --- a/arch/x86/mm/tlb.c~simplify-tlb-code	2014-04-21 11:10:34.431818610 -0700
> +++ b/arch/x86/mm/tlb.c	2014-04-21 11:10:34.435818791 -0700
> @@ -161,23 +161,24 @@ void flush_tlb_current_task(void)
>  void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>  				unsigned long end, unsigned long vmflag)
>  {
> +	int need_flush_others_all = 1;
>  	unsigned long addr;
>  	unsigned act_entries, tlb_entries = 0;
>  	unsigned long nr_base_pages;
>  

Could make that bool but otherwise

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
