Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id CEDF06B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 06:01:13 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id q58so2506604wes.4
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 03:01:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t5si10136461wja.153.2014.07.31.03.01.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 03:01:08 -0700 (PDT)
Date: Thu, 31 Jul 2014 12:01:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] kexec-export-free_huge_page-to-vmcoreinfo-fix (was: Re:
 mmotm 2014-07-30-15-57 uploaded)
Message-ID: <20140731100100.GD13561@dhcp22.suse.cz>
References: <53d978aa.dtIIGjOqrXXmAm4e%akpm@linux-foundation.org>
 <20140731092452.GB13561@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140731092452.GB13561@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>

On Thu 31-07-14 11:24:52, Michal Hocko wrote:
> On Wed 30-07-14 15:58:50, Andrew Morton wrote:
> > * kexec-export-free_huge_page-to-vmcoreinfo.patch
> 
> This one seems to be missing ifdef for CONFIG_HUGETLBFS

Ohh, David has already posted the fix
http://marc.info/?l=linux-mm&m=140676663218869

> ---
> From bcccb6696b89c700712421858b05dd89ea0d1ec5 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 31 Jul 2014 11:18:57 +0200
> Subject: [PATCH] kexec-export-free_huge_page-to-vmcoreinfo-fix
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
> 
> free_huge_page is not defined for !CONFIG_HUGETLBFS. Fix the following
> compilation error:
> 
> kernel/kexec.c: In function a??crash_save_vmcoreinfo_inita??:
> kernel/kexec.c:1628:20: error: a??free_huge_pagea?? undeclared (first use in this function)
>   VMCOREINFO_SYMBOL(free_huge_page);
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  kernel/kexec.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/kernel/kexec.c b/kernel/kexec.c
> index a3ccf9d7174b..507614acf938 100644
> --- a/kernel/kexec.c
> +++ b/kernel/kexec.c
> @@ -1625,7 +1625,9 @@ static int __init crash_save_vmcoreinfo_init(void)
>  #endif
>  	VMCOREINFO_NUMBER(PG_head_mask);
>  	VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);
> +#ifdef CONFIG_HUGETLBFS
>  	VMCOREINFO_SYMBOL(free_huge_page);
> +#endif
>  
>  	arch_crash_save_vmcoreinfo();
>  	update_vmcoreinfo_note();
> -- 
> 2.0.1
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
