Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7263B6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:57:36 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 199so23758242pgg.20
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:57:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si6487646pgi.574.2017.11.27.11.57.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 11:57:35 -0800 (PST)
Date: Mon, 27 Nov 2017 20:57:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Message-ID: <20171127195732.3hkfx57d3ytyccvp@dhcp22.suse.cz>
References: <23066.59196.909026.689706@gargle.gargle.HOWL>
 <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
 <87vahv8whv.fsf@linux.intel.com>
 <20171127183218.33zm666jw3uqkxdq@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127183218.33zm666jw3uqkxdq@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Mikael Pettersson <mikpelinux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org

On Mon 27-11-17 19:32:18, Michal Hocko wrote:
> On Mon 27-11-17 09:25:16, Andi Kleen wrote:
[...]
> > The reason the limit was there originally because it allows a DoS
> > attack against the kernel by filling all unswappable memory up with VMAs.
> 
> We can reduce the effect by accounting vmas to memory cgroups.

As it turned out we already do.
	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
