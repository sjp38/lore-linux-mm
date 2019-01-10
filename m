Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CEEA8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 04:14:35 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id w16so2893600wrk.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 01:14:35 -0800 (PST)
Received: from tartarus.angband.pl (tartarus.angband.pl. [2001:41d0:602:dbe::8])
        by mx.google.com with ESMTPS id s184si10712745wmf.46.2019.01.10.01.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 Jan 2019 01:14:34 -0800 (PST)
Date: Thu, 10 Jan 2019 10:14:24 +0100
From: Adam Borowski <kilobyte@angband.pl>
Subject: Re: [PATCH] mm/mmu_notifier: mm/rmap.c: Fix a mmu_notifier range bug
 in try_to_unmap_one
Message-ID: <20190110091424.mzgpdaqq74ie6ro5@angband.pl>
References: <20190110005117.18282-1-sean.j.christopherson@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190110005117.18282-1-sean.j.christopherson@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, leozinho29_eu@hotmail.com, Mike Galbraith <efault@gmx.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Jan 09, 2019 at 04:51:17PM -0800, Sean Christopherson wrote:
> Manifests as KVM use-after-free WARNINGs and subsequent "BUG: Bad page
> state in process X" errors when reclaiming from a KVM guest due to KVM
> removing the wrong pages from its own mappings.

With your patch, no badness happened so far.  Thanks!

> Reported-by: Adam Borowski <kilobyte@angband.pl>
> Fixes: ac46d4f3c432 ("mm/mmu_notifier: use structure for invalidate_range_start/end calls v2")

> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> -	mmu_notifier_range_init(&range, vma->vm_mm, vma->vm_start,
> -				min(vma->vm_end, vma->vm_start +
> +	mmu_notifier_range_init(&range, vma->vm_mm, address,
> +				min(vma->vm_end, address +


Meow.
-- 
⢀⣴⠾⠻⢶⣦⠀ Hans 1 was born and raised in Johannesburg, then moved to Boston,
⣾⠁⢠⠒⠀⣿⡁ and has just became a naturalized citizen.  Hans 2's grandparents
⢿⡄⠘⠷⠚⠋⠀ came from Melanesia to Düsseldorf, and he hasn't ever been outside
⠈⠳⣄⠀⠀⠀⠀ Germany until yesterday.  Which one is an African-American?
