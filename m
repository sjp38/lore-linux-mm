Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E277B6B4336
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:00:12 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 68so12032193pfr.6
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 11:00:12 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t184si1216122pfb.22.2018.11.26.11.00.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 11:00:11 -0800 (PST)
Date: Mon, 26 Nov 2018 11:00:10 -0800
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: Re: [PATCH v4 4/5] lib/ioremap: Ensure phys_addr actually
 corresponds to a physical address
Message-ID: <20181126190009.GG25719@linux.intel.com>
References: <1543252067-30831-1-git-send-email-will.deacon@arm.com>
 <1543252067-30831-5-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543252067-30831-5-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, akpm@linux-foundation.org

On Mon, Nov 26, 2018 at 05:07:46PM +0000, Will Deacon wrote:
> The current ioremap() code uses a phys_addr variable at each level of
> page table, which is confusingly offset by subtracting the base virtual
> address being mapped so that adding the current virtual address back on
> when iterating through the page table entries gives back the corresponding
> physical address.
> 
> This is fairly confusing and results in all users of phys_addr having to
> add the current virtual address back on. Instead, this patch just updates
> phys_addr when iterating over the page table entries, ensuring that it's
> always up-to-date and doesn't require explicit offsetting.
> 
> Cc: Chintan Pandya <cpandya@codeaurora.org>
> Cc: Toshi Kani <toshi.kani@hpe.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Sean Christopherson <sean.j.christopherson@intel.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Tested-by: Sean Christopherson <sean.j.christopherson@intel.com>
Reviewed-by: Sean Christopherson <sean.j.christopherson@intel.com>
