Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A36096B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 13:32:23 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n8so11541912wmg.4
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 10:32:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w10si2184434edj.349.2017.11.27.10.32.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 10:32:21 -0800 (PST)
Date: Mon, 27 Nov 2017 19:32:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Message-ID: <20171127183218.33zm666jw3uqkxdq@dhcp22.suse.cz>
References: <23066.59196.909026.689706@gargle.gargle.HOWL>
 <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
 <87vahv8whv.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87vahv8whv.fsf@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Mikael Pettersson <mikpelinux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org

On Mon 27-11-17 09:25:16, Andi Kleen wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> >
> > Could you be more explicit about _why_ we need to remove this tunable?
> > I am not saying I disagree, the removal simplifies the code but I do not
> > really see any justification here.
> 
> It's an arbitrary scaling limit on the how many mappings the process
> has. The more memory you have the bigger a problem it is. We've
> ran into this problem too on larger systems.

Why cannot you increase the limit?

> The reason the limit was there originally because it allows a DoS
> attack against the kernel by filling all unswappable memory up with VMAs.

We can reduce the effect by accounting vmas to memory cgroups.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
