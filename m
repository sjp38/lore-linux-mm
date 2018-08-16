Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0758D6B0312
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 14:43:39 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d1-v6so4171564qth.21
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 11:43:39 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h48-v6si26146qta.340.2018.08.16.11.43.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 11:43:38 -0700 (PDT)
Subject: Re: [PATCH v3 4/4] mm/memory_hotplug: Drop node_online check in
 unregister_mem_sect_under_nodes
References: <20180815144219.6014-1-osalvador@techadventures.net>
 <20180815144219.6014-5-osalvador@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <f0c61403-b7a1-d1af-f52c-7be307365ee9@redhat.com>
Date: Thu, 16 Aug 2018 20:43:34 +0200
MIME-Version: 1.0
In-Reply-To: <20180815144219.6014-5-osalvador@techadventures.net>
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
> We are getting the nid from the pages that are not yet removed,
> but a node can only be offline when its memory/cpu's have been removed.
> Therefore, we know that the node is still online.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  drivers/base/node.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 81b27b5b1f15..b23769e4fcbb 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -465,8 +465,6 @@ void unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  
>  		if (nid < 0)
>  			continue;
> -		if (!node_online(nid))
> -			continue;
>  		/*
>  		 * It is possible that NODEMASK_ALLOC fails due to memory
>  		 * pressure.
> 

Sounds reasonable to me

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
