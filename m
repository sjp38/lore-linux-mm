Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC34A6B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 05:29:10 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c6-v6so15241424qta.6
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 02:29:10 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 9-v6si3383519qkl.30.2018.08.14.02.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 02:29:09 -0700 (PDT)
Subject: Re: [PATCH v2 1/3] mm/memory-hotplug: Drop unused args from
 remove_memory_section
References: <20180813154639.19454-1-osalvador@techadventures.net>
 <20180813154639.19454-2-osalvador@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <322cf553-9d4e-4878-0d9e-6d5a50c900fb@redhat.com>
Date: Tue, 14 Aug 2018 11:29:05 +0200
MIME-Version: 1.0
In-Reply-To: <20180813154639.19454-2-osalvador@techadventures.net>
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
> unregister_memory_section() calls remove_memory_section()
> with three arguments:
> 
> * node_id
> * section
> * phys_device
> 
> Neither node_id nor phys_device are used.
> Let us drop them from the function.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  drivers/base/memory.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index c8a1cb0b6136..2c622a9a7490 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -752,8 +752,7 @@ unregister_memory(struct memory_block *memory)
>  	device_unregister(&memory->dev);
>  }
>  
> -static int remove_memory_section(unsigned long node_id,
> -			       struct mem_section *section, int phys_device)
> +static int remove_memory_section(struct mem_section *section)
>  {
>  	struct memory_block *mem;
>  
> @@ -785,7 +784,7 @@ int unregister_memory_section(struct mem_section *section)
>  	if (!present_section(section))
>  		return -EINVAL;
>  
> -	return remove_memory_section(0, section, 0);
> +	return remove_memory_section(section);
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
