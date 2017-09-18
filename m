Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB7C6B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:37:10 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b9so8343998wra.3
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 23:37:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si5919187edi.226.2017.09.17.23.37.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 23:37:09 -0700 (PDT)
Date: Mon, 18 Sep 2017 08:37:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm/memory_hotplug: define
 find_{smallest|biggest}_section_pfn as unsigned long
Message-ID: <20170918063703.lippdq3ovrqmpun6@dhcp22.suse.cz>
References: <e643a387-e573-6bbf-d418-c60c8ee3d15e@gmail.com>
 <d9d5593a-d0a4-c4be-ab08-493df59a85c6@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9d5593a-d0a4-c4be-ab08-493df59a85c6@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: linux-mm@kvack.org, qiuxishi@huawei.com, arbab@linux.vnet.ibm.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

On Fri 15-09-17 22:53:49, YASUAKI ISHIMATSU wrote:
> find_{smallest|biggest}_section_pfn()s find the smallest/biggest section
> and return the pfn of the section. But the functions are defined as int.
> So the functions always return 0x00000000 - 0xffffffff. It means
> if memory address is over 16TB, the functions does not work correctly.
> 
> To handle 64 bit value, the patch defines find_{smallest|biggest}_section_pfn()
> as unsigned long.
> 

Fixes: 815121d2b5cd ("memory_hotplug: clear zone when removing the memory")
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 38c3c37..120e45b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -582,7 +582,7 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
> 
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
> -static int find_smallest_section_pfn(int nid, struct zone *zone,
> +static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
>  				     unsigned long start_pfn,
>  				     unsigned long end_pfn)
>  {
> @@ -607,7 +607,7 @@ static int find_smallest_section_pfn(int nid, struct zone *zone,
>  }
> 
>  /* find the biggest valid pfn in the range [start_pfn, end_pfn). */
> -static int find_biggest_section_pfn(int nid, struct zone *zone,
> +static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
>  				    unsigned long start_pfn,
>  				    unsigned long end_pfn)
>  {
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
