Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBD466B0038
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:52:13 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 190so29903099pgh.16
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:52:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si24253622plm.768.2017.11.27.12.52.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 12:52:12 -0800 (PST)
Date: Mon, 27 Nov 2017 21:52:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Message-ID: <20171127205210.zmah36uliajnbjon@dhcp22.suse.cz>
References: <23066.59196.909026.689706@gargle.gargle.HOWL>
 <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
 <87vahv8whv.fsf@linux.intel.com>
 <20171127183218.33zm666jw3uqkxdq@dhcp22.suse.cz>
 <20171127195732.3hkfx57d3ytyccvp@dhcp22.suse.cz>
 <20171127202121.GB3070@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127202121.GB3070@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Mikael Pettersson <mikpelinux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org

On Mon 27-11-17 12:21:21, Andi Kleen wrote:
> On Mon, Nov 27, 2017 at 08:57:32PM +0100, Michal Hocko wrote:
> > On Mon 27-11-17 19:32:18, Michal Hocko wrote:
> > > On Mon 27-11-17 09:25:16, Andi Kleen wrote:
> > [...]
> > > > The reason the limit was there originally because it allows a DoS
> > > > attack against the kernel by filling all unswappable memory up with VMAs.
> > > 
> > > We can reduce the effect by accounting vmas to memory cgroups.
> > 
> > As it turned out we already do.
> > 	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT);
> 
> That only helps if you have memory cgroups enabled. It would be a regression
> to break the accounting on all the systems that don't.

I agree. And I didn't say we should remove the existing limit. I am just
saying that we can reduce existing problems by increasing the limit and
relying on memcg accounting where possible.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
