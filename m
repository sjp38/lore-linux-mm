Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 268726B030C
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 14:43:06 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g7-v6so4211336qtp.19
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 11:43:06 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q12-v6si17512qtn.388.2018.08.16.11.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 11:43:05 -0700 (PDT)
Subject: Re: [PATCH v3 2/4] mm/memory_hotplug: Drop mem_blk check from
 unregister_mem_sect_under_nodes
References: <20180815144219.6014-1-osalvador@techadventures.net>
 <20180815144219.6014-3-osalvador@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <29a2c884-836c-d659-ee39-2c865943a3f5@redhat.com>
Date: Thu, 16 Aug 2018 20:43:00 +0200
MIME-Version: 1.0
In-Reply-To: <20180815144219.6014-3-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On 15.08.2018 16:42, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> Before calling to unregister_mem_sect_under_nodes(),
> remove_memory_section() already checks if we got a valid memory_block.
> 
> No need to check that again in unregister_mem_sect_under_nodes().
> 
> If more functions start using unregister_mem_sect_under_nodes() in the
> future, we can always place a WARN_ON to catch null mem_blk's so we can
> safely back off.
> 
> For now, let us keep the check in remove_memory_section() since it is the
> only function that uses it.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>  drivers/base/node.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 1ac4c36e13bb..dd3bdab230b2 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -455,10 +455,6 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
>  
> -	if (!mem_blk) {
> -		NODEMASK_FREE(unlinked_nodes);
> -		return -EFAULT;
> -	}
>  	if (!unlinked_nodes)
>  		return -ENOMEM;
>  	nodes_clear(*unlinked_nodes);
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
