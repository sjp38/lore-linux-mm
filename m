Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id E53DC6B026A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 07:01:22 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id y6-v6so793669wmc.4
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 04:01:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 190-v6sor10090777wmb.20.2018.10.10.04.01.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 04:01:21 -0700 (PDT)
Date: Wed, 10 Oct 2018 13:01:19 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
Message-ID: <20181010110119.GA20952@techadventures.net>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
 <20181010080724.GA20338@techadventures.net>
 <f18b87a0762c4379b78e9b5e09ff4840@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f18b87a0762c4379b78e9b5e09ff4840@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On Wed, Oct 10, 2018 at 04:21:16PM +0530, Arun KS wrote:
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e379e85..2416136 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -690,9 +690,13 @@ static int online_pages_range(unsigned long start_pfn,
> unsigned long nr_pages,
>                         void *arg)
>  {
>         unsigned long onlined_pages = *(unsigned long *)arg;
> +       u64 t1, t2;
> 
> +       t1 = local_clock();
>         if (PageReserved(pfn_to_page(start_pfn)))
>                 onlined_pages = online_pages_blocks(start_pfn, nr_pages);
> +       t2 = local_clock();
> +       trace_printk("time spend = %llu us\n", (t2-t1)/(1000));
> 
>         online_mem_sections(start_pfn, start_pfn + nr_pages);

Thanks ;-)
 

-- 
Oscar Salvador
SUSE L3
