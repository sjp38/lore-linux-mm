Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5706B0B93
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 16:39:29 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id w19-v6so18174485plq.1
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 13:39:29 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f126-v6si30156976pfa.1.2018.11.16.13.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 13:39:27 -0800 (PST)
Subject: Re: [RFC PATCH 2/4] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
References: <20181116101222.16581-1-osalvador@suse.com>
 <20181116101222.16581-3-osalvador@suse.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4063e22f-bc33-076d-5300-7bd6e61e3170@intel.com>
Date: Fri, 16 Nov 2018 13:39:26 -0800
MIME-Version: 1.0
In-Reply-To: <20181116101222.16581-3-osalvador@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.com>, linux-mm@kvack.org
Cc: mhocko@suse.com, david@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On 11/16/18 2:12 AM, Oscar Salvador wrote:
> +/*
> + * Do we want sysfs memblock files created. This will allow userspace to online
> + * and offline memory explicitly. Lack of this bit means that the caller has to
> + * call move_pfn_range_to_zone to finish the initialization.
> + */
> +
> +#define MHP_MEMBLOCK_API               1<<0
> +
> +/* Restrictions for the memory hotplug */
> +struct mhp_restrictions {
> +	unsigned long flags;    /* MHP_ flags */
> +	struct vmem_altmap *altmap; /* use this alternative allocatro for memmaps */

"allocatro" -> "allocator"
