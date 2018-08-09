Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC406B0007
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 03:50:58 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id k15-v6so4038171wrq.1
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 00:50:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b2-v6sor1530972wmh.82.2018.08.09.00.50.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Aug 2018 00:50:57 -0700 (PDT)
Date: Thu, 9 Aug 2018 09:50:55 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180809075055.GA14802@techadventures.net>
References: <a6e4e654-fc95-497f-16f3-8c1550cf03d6@redhat.com>
 <20180807204834.GA6844@techadventures.net>
 <20180807221345.GD3301@redhat.com>
 <20180808073835.GA9568@techadventures.net>
 <44f74b58-aae0-a44c-3b98-7b1aac186f8e@redhat.com>
 <20180808075614.GB9568@techadventures.net>
 <7a64e67d-1df9-04ab-cc49-99a39aa90798@redhat.com>
 <20180808134233.GA10946@techadventures.net>
 <20180808175558.GD3429@redhat.com>
 <20180808212908.GB12363@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180808212908.GB12363@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 08, 2018 at 11:29:08PM +0200, Oscar Salvador wrote:
> On Wed, Aug 08, 2018 at 01:55:59PM -0400, Jerome Glisse wrote:
> > Note that Dan did post patches that already go in that direction (unifying
> > code between devm and HMM). I think they are in Andrew queue, looks for
> > 
> > mm: Rework hmm to use devm_memremap_pages and other fixes
> 
> Thanks for pointing that out.
> I will take a look at that work.

Ok, I checked the patchset [1] and I think it is nice that those two (devm and HMM)
get unified.
I think it will make things easier when we have to change things for the memory-hotplug.
Actually, I think that after [2], all hot-adding memory will be handled in 
devm_memremap_pages.

What I do not see is why the patch did not make it to further RCs.

Thanks
-- 
Oscar Salvador
SUSE L3
