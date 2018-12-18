Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 989188E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 11:34:55 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id e68so12298050plb.3
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 08:34:55 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id r18si13979782pgb.491.2018.12.18.08.34.54
        for <linux-mm@kvack.org>;
        Tue, 18 Dec 2018 08:34:54 -0800 (PST)
Date: Tue, 18 Dec 2018 17:34:51 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH] memory_hotplug: add missing newlines to debugging output
Message-ID: <20181218163446.ua6svkohowov35to@d104.suse.de>
References: <20181218162307.10518-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218162307.10518-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Dec 18, 2018 at 05:23:07PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>

> Fixes: b77eab7079d9 ("mm/memory_hotplug: optimize probe routine")
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  drivers/base/memory.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 0e5985682642..b5ff45ab7967 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -207,15 +207,15 @@ static bool pages_correctly_probed(unsigned long start_pfn)
>  			return false;
>  
>  		if (!present_section_nr(section_nr)) {
> -			pr_warn("section %ld pfn[%lx, %lx) not present",
> +			pr_warn("section %ld pfn[%lx, %lx) not present\n",
>  				section_nr, pfn, pfn + PAGES_PER_SECTION);
>  			return false;
>  		} else if (!valid_section_nr(section_nr)) {
> -			pr_warn("section %ld pfn[%lx, %lx) no valid memmap",
> +			pr_warn("section %ld pfn[%lx, %lx) no valid memmap\n",
>  				section_nr, pfn, pfn + PAGES_PER_SECTION);
>  			return false;
>  		} else if (online_section_nr(section_nr)) {
> -			pr_warn("section %ld pfn[%lx, %lx) is already online",
> +			pr_warn("section %ld pfn[%lx, %lx) is already online\n",
>  				section_nr, pfn, pfn + PAGES_PER_SECTION);
>  			return false;
>  		}
> -- 
> 2.19.2
> 

-- 
Oscar Salvador
SUSE L3
