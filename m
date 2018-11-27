Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 837246B47D0
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 07:12:29 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id v34so9979000ote.7
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 04:12:29 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j12si1766398ota.192.2018.11.27.04.12.27
        for <linux-mm@kvack.org>;
        Tue, 27 Nov 2018 04:12:28 -0800 (PST)
Date: Tue, 27 Nov 2018 12:12:44 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v4 4/5] lib/ioremap: Ensure phys_addr actually
 corresponds to a physical address
Message-ID: <20181127121244.GB4181@arm.com>
References: <1543252067-30831-1-git-send-email-will.deacon@arm.com>
 <1543252067-30831-5-git-send-email-will.deacon@arm.com>
 <20181126190009.GG25719@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126190009.GG25719@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, akpm@linux-foundation.org

On Mon, Nov 26, 2018 at 11:00:10AM -0800, Sean Christopherson wrote:
> On Mon, Nov 26, 2018 at 05:07:46PM +0000, Will Deacon wrote:
> > The current ioremap() code uses a phys_addr variable at each level of
> > page table, which is confusingly offset by subtracting the base virtual
> > address being mapped so that adding the current virtual address back on
> > when iterating through the page table entries gives back the corresponding
> > physical address.
> > 
> > This is fairly confusing and results in all users of phys_addr having to
> > add the current virtual address back on. Instead, this patch just updates
> > phys_addr when iterating over the page table entries, ensuring that it's
> > always up-to-date and doesn't require explicit offsetting.
> > 
> > Cc: Chintan Pandya <cpandya@codeaurora.org>
> > Cc: Toshi Kani <toshi.kani@hpe.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Sean Christopherson <sean.j.christopherson@intel.com>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> 
> Tested-by: Sean Christopherson <sean.j.christopherson@intel.com>
> Reviewed-by: Sean Christopherson <sean.j.christopherson@intel.com>

Thanks, Sean. I think Andrew can queue these now.

Will
