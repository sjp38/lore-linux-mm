Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6B2B6B000A
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 03:52:07 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id o4-v6so4019074wrn.19
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 00:52:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4-v6sor2468166wrv.17.2018.08.09.00.52.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Aug 2018 00:52:06 -0700 (PDT)
Date: Thu, 9 Aug 2018 09:52:05 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180809075205.GB14802@techadventures.net>
References: <20180807204834.GA6844@techadventures.net>
 <20180807221345.GD3301@redhat.com>
 <20180808073835.GA9568@techadventures.net>
 <44f74b58-aae0-a44c-3b98-7b1aac186f8e@redhat.com>
 <20180808075614.GB9568@techadventures.net>
 <7a64e67d-1df9-04ab-cc49-99a39aa90798@redhat.com>
 <20180808134233.GA10946@techadventures.net>
 <20180808175558.GD3429@redhat.com>
 <20180808212908.GB12363@techadventures.net>
 <20180809075055.GA14802@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180809075055.GA14802@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Thu, Aug 09, 2018 at 09:50:55AM +0200, Oscar Salvador wrote:
> On Wed, Aug 08, 2018 at 11:29:08PM +0200, Oscar Salvador wrote:
> > On Wed, Aug 08, 2018 at 01:55:59PM -0400, Jerome Glisse wrote:
> > > Note that Dan did post patches that already go in that direction (unifying
> > > code between devm and HMM). I think they are in Andrew queue, looks for
> > > 
> > > mm: Rework hmm to use devm_memremap_pages and other fixes
> > 
> > Thanks for pointing that out.
> > I will take a look at that work.
> 
> Ok, I checked the patchset [1] and I think it is nice that those two (devm and HMM)
> get unified.
> I think it will make things easier when we have to change things for the memory-hotplug.
> Actually, I think that after [2], all hot-adding memory will be handled in 
> devm_memremap_pages.

Forgot to include the links:

[1] https://lkml.org/lkml/2018/6/19/108
[2] https://lkml.org/lkml/2018/6/19/110

-- 
Oscar Salvador
SUSE L3
