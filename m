Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADA96B000A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 17:29:11 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id t5-v6so2801125wrq.14
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 14:29:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y16-v6sor1492444wme.59.2018.08.08.14.29.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 14:29:10 -0700 (PDT)
Date: Wed, 8 Aug 2018 23:29:08 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180808212908.GB12363@techadventures.net>
References: <20180807135221.GA3301@redhat.com>
 <a6e4e654-fc95-497f-16f3-8c1550cf03d6@redhat.com>
 <20180807204834.GA6844@techadventures.net>
 <20180807221345.GD3301@redhat.com>
 <20180808073835.GA9568@techadventures.net>
 <44f74b58-aae0-a44c-3b98-7b1aac186f8e@redhat.com>
 <20180808075614.GB9568@techadventures.net>
 <7a64e67d-1df9-04ab-cc49-99a39aa90798@redhat.com>
 <20180808134233.GA10946@techadventures.net>
 <20180808175558.GD3429@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180808175558.GD3429@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 08, 2018 at 01:55:59PM -0400, Jerome Glisse wrote:
> Note that Dan did post patches that already go in that direction (unifying
> code between devm and HMM). I think they are in Andrew queue, looks for
> 
> mm: Rework hmm to use devm_memremap_pages and other fixes

Thanks for pointing that out.
I will take a look at that work.

-- 
Oscar Salvador
SUSE L3
