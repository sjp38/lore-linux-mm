Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCFA06B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:21:23 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id k84so17872040pfj.18
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:21:23 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d77si10585968pfj.97.2017.11.27.12.21.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 12:21:22 -0800 (PST)
Date: Mon, 27 Nov 2017 12:21:21 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Message-ID: <20171127202121.GB3070@tassilo.jf.intel.com>
References: <23066.59196.909026.689706@gargle.gargle.HOWL>
 <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
 <87vahv8whv.fsf@linux.intel.com>
 <20171127183218.33zm666jw3uqkxdq@dhcp22.suse.cz>
 <20171127195732.3hkfx57d3ytyccvp@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127195732.3hkfx57d3ytyccvp@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikael Pettersson <mikpelinux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org

On Mon, Nov 27, 2017 at 08:57:32PM +0100, Michal Hocko wrote:
> On Mon 27-11-17 19:32:18, Michal Hocko wrote:
> > On Mon 27-11-17 09:25:16, Andi Kleen wrote:
> [...]
> > > The reason the limit was there originally because it allows a DoS
> > > attack against the kernel by filling all unswappable memory up with VMAs.
> > 
> > We can reduce the effect by accounting vmas to memory cgroups.
> 
> As it turned out we already do.
> 	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT);

That only helps if you have memory cgroups enabled. It would be a regression
to break the accounting on all the systems that don't.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
