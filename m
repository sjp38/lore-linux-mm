Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 31B266B0902
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 06:56:47 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id j18so15543575oth.11
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:56:47 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w72si2271455oiw.1.2018.11.16.03.56.46
        for <linux-mm@kvack.org>;
        Fri, 16 Nov 2018 03:56:46 -0800 (PST)
Subject: Re: [PATCH 3/5] mm, memory_hotplug: drop pointless block alignment
 checks from __offline_pages
References: <20181116083020.20260-1-mhocko@kernel.org>
 <20181116083020.20260-4-mhocko@kernel.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <50a2cbeb-9d1b-d629-6390-c0b3d26f2d72@arm.com>
Date: Fri, 16 Nov 2018 17:26:41 +0530
MIME-Version: 1.0
In-Reply-To: <20181116083020.20260-4-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On 11/16/2018 02:00 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> This function is never called from a context which would provide
> misaligned pfn range so drop the pointless check.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory_hotplug.c | 6 ------
>  1 file changed, 6 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 2b2b3ccbbfb5..a92b1b8f6218 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1554,12 +1554,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	struct zone *zone;
>  	struct memory_notify arg;
>  
> -	/* at least, alignment against pageblock is necessary */
> -	if (!IS_ALIGNED(start_pfn, pageblock_nr_pages))
> -		return -EINVAL;
> -	if (!IS_ALIGNED(end_pfn, pageblock_nr_pages))
> -		return -EINVAL;
> -
>  	mem_hotplug_begin();
>  
>  	/* This makes hotplug much easier...and readable.
> 

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
