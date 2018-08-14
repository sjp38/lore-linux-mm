Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C31866B0007
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 05:30:55 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d14-v6so15086324qtn.12
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 02:30:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y46-v6si1055469qtc.394.2018.08.14.02.30.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 02:30:55 -0700 (PDT)
Subject: Re: [PATCH v2 2/3] mm/memory_hotplug: Drop mem_blk check from
 unregister_mem_sect_under_nodes
References: <20180813154639.19454-1-osalvador@techadventures.net>
 <20180813154639.19454-3-osalvador@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <82148bc6-672d-6610-757f-d910a17d23c6@redhat.com>
Date: Tue, 14 Aug 2018 11:30:51 +0200
MIME-Version: 1.0
In-Reply-To: <20180813154639.19454-3-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, rafael@kernel.org, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On 13.08.2018 17:46, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> Before calling to unregister_mem_sect_under_nodes(),
> remove_memory_section() already checks if we got a valid
> memory_block.
> 
> No need to check that again in unregister_mem_sect_under_nodes().
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
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

While it is correct in current code, I wonder if this sanity check
should stay. I would completely agree if it would be a static function.

-- 

Thanks,

David / dhildenb
