Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 884E06B0275
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:22:38 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l124so4785738wml.4
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 00:22:38 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id p202si1517706wme.71.2016.10.27.00.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 00:22:37 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id m83so1204316wmc.0
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 00:22:37 -0700 (PDT)
Date: Thu, 27 Oct 2016 09:22:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm/memblock: prepare a capability to support
 memblock near alloc
Message-ID: <20161027072235.GB6454@dhcp22.suse.cz>
References: <1477364358-10620-1-git-send-email-thunder.leizhen@huawei.com>
 <1477364358-10620-2-git-send-email-thunder.leizhen@huawei.com>
 <20161025132338.GA31239@dhcp22.suse.cz>
 <58101EB4.2080305@huawei.com>
 <20161026093152.GE18382@dhcp22.suse.cz>
 <58116954.8080908@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58116954.8080908@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Thu 27-10-16 10:41:24, Leizhen (ThunderTown) wrote:
> 
> 
> On 2016/10/26 17:31, Michal Hocko wrote:
> > On Wed 26-10-16 11:10:44, Leizhen (ThunderTown) wrote:
> >>
> >>
> >> On 2016/10/25 21:23, Michal Hocko wrote:
> >>> On Tue 25-10-16 10:59:17, Zhen Lei wrote:
> >>>> If HAVE_MEMORYLESS_NODES is selected, and some memoryless numa nodes are
> >>>> actually exist. The percpu variable areas and numa control blocks of that
> >>>> memoryless numa nodes need to be allocated from the nearest available
> >>>> node to improve performance.
> >>>>
> >>>> Although memblock_alloc_try_nid and memblock_virt_alloc_try_nid try the
> >>>> specified nid at the first time, but if that allocation failed it will
> >>>> directly drop to use NUMA_NO_NODE. This mean any nodes maybe possible at
> >>>> the second time.
> >>>>
> >>>> To compatible the above old scene, I use a marco node_distance_ready to
> >>>> control it. By default, the marco node_distance_ready is not defined in
> >>>> any platforms, the above mentioned functions will work as normal as
> >>>> before. Otherwise, they will try the nearest node first.
> >>>
> >>> I am sorry but it is absolutely unclear to me _what_ is the motivation
> >>> of the patch. Is this a performance optimization, correctness issue or
> >>> something else? Could you please restate what is the problem, why do you
> >>> think it has to be fixed at memblock layer and describe what the actual
> >>> fix is please?
> >>
> >> This is a performance optimization.
> > 
> > Do you have any numbers to back the improvements?
>
> I have not collected any performance data, but at least in theory,
> it's beneficial and harmless, except make code looks a bit
> urly.

The whole memoryless area is cluttered with hacks because everybody just
adds pieces here and there to make his particular usecase work IMHO.
Adding more on top for performance reasons which are even not measured
to prove a clear win is a no go. Please step back try to think how this
could be done with an existing infrastructure we have (some cleanups
while doing that would be hugely appreciated) and if that is not
possible then explain why and why it is not feasible to fix that before
you start adding a new API.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
