Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id F13EF6B073B
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 04:18:56 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id f13-v6so5177117wru.5
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 01:18:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p8-v6sor572679wrw.13.2018.08.17.01.18.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Aug 2018 01:18:55 -0700 (PDT)
Date: Fri, 17 Aug 2018 10:18:53 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v1 5/5] mm/memory_hotplug: print only with DEBUG_VM in
 online/offline_pages()
Message-ID: <20180817081853.GB17638@techadventures.net>
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-6-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180816100628.26428-6-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

>  failed_addition:
> +#ifdef CONFIG_DEBUG_VM
>  	pr_debug("online_pages [mem %#010llx-%#010llx] failed\n",
>  		 (unsigned long long) pfn << PAGE_SHIFT,
>  		 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
> +#endif

I have never been sure about this.
IMO, if I fail to online pages, I want to know I failed.
I think that pr_err would be better than pr_debug and without CONFIG_DEBUG_VM.

But at least, if not, envolve it with a CONFIG_DEBUG_VM, but change pr_debug to pr_info.

> +#ifdef CONFIG_DEBUG_VM
>  	pr_debug("memory offlining [mem %#010llx-%#010llx] failed\n",
>  		 (unsigned long long) start_pfn << PAGE_SHIFT,
>  		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
> +#endif

Same goes here.

Thanks
-- 
Oscar Salvador
SUSE L3
