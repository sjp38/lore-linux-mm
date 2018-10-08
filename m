Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A09F6B000A
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 03:34:25 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id j90-v6so6895707wrj.20
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 00:34:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9-v6sor6919429wmc.1.2018.10.08.00.34.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 00:34:24 -0700 (PDT)
Date: Mon, 8 Oct 2018 09:34:22 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
Message-ID: <20181008073421.GA9703@techadventures.net>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On Fri, Oct 05, 2018 at 01:40:05PM +0530, Arun KS wrote:
> When free pages are done with higher order, time spend on
> coalescing pages by buddy allocator can be reduced. With
> section size of 256MB, hot add latency of a single section
> shows improvement from 50-60 ms to less than 1 ms, hence
> improving the hot add latency by 60%. Modify external
> providers of online callback to align with the change.
> 
> Signed-off-by: Arun KS <arunks@codeaurora.org>

Looks good to me.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Just one thing below:
  
> @@ -1331,7 +1331,7 @@ void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
>  {
>  	if (early_page_uninitialised(pfn))
>  		return;
> -	return __free_pages_boot_core(page, order);
> +	return __free_pages_core(page, order);

__free_pages_core is void, so I guess we do not need that return there.
Probably the code generated is the same though.
-- 
Oscar Salvador
SUSE L3
