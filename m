Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 854E98E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 04:09:43 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id s1-v6so1867287pfm.22
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 01:09:43 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id u12-v6si1506997pfi.175.2018.09.27.01.09.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 01:09:42 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 27 Sep 2018 13:39:41 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v3] memory_hotplug: Free pages as higher order
In-Reply-To: <20180927070957.GA19369@techadventures.net>
References: <1538031530-25489-1-git-send-email-arunks@codeaurora.org>
 <20180927070957.GA19369@techadventures.net>
Message-ID: <f56a750a54eadf76c45d3065622d4cbf@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On 2018-09-27 12:39, Oscar Salvador wrote:
> On Thu, Sep 27, 2018 at 12:28:50PM +0530, Arun KS wrote:
>> +	__free_pages_boot_core(page, order);
> 
Hi,

> I am not sure, but if we are going to use that function from the
> memory-hotplug code,
> we might want to rename that function to something more generic?
> The word "boot" suggests that this is only called from the boot stage.
I ll rename it to __free_pages_core()

> 
> And what about the prefetch operations?
> I saw that you removed them in your previous patch and that had some
> benefits [1].
> 
> Should we remove them here as well?
Sure. Will update this as well.

Thanks,
Arun
> 
> [1] https://patchwork.kernel.org/patch/10613359/
> 
> Thanks
