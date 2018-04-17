Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF036B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 02:44:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q6so15318531wre.20
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 23:44:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z16si3551310eda.75.2018.04.16.23.44.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 23:44:16 -0700 (PDT)
Date: Tue, 17 Apr 2018 08:44:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-ID: <20180417064414.GX17484@dhcp22.suse.cz>
References: <20180305133743.12746-5-guro@fb.com>
 <20180413133519.GA213834@rodete-laptop-imager.corp.google.com>
 <20180413135923.GT17484@dhcp22.suse.cz>
 <13f1f5b5-f3f8-956c-145a-4641fb996048@suse.cz>
 <20180413142821.GW17484@dhcp22.suse.cz>
 <20180413143716.GA5378@cmpxchg.org>
 <20180416114144.GK17484@dhcp22.suse.cz>
 <1475594b-c1ad-9625-7aeb-ad8ad385b793@suse.cz>
 <20180416122747.GM17484@dhcp22.suse.cz>
 <a6413098-b37c-a6b8-45cb-ce273ff16c29@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a6413098-b37c-a6b8-45cb-ce273ff16c29@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, lsf-pc@lists.linux-foundation.org

[the head of the thread is http://lkml.kernel.org/r/08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz]

On Mon 16-04-18 21:57:50, Vlastimil Babka wrote:
> On 04/16/2018 02:27 PM, Michal Hocko wrote:
> > On Mon 16-04-18 14:06:21, Vlastimil Babka wrote:
> >>
> >> For example the percpu (and other) array caches...
> >>
> >>> maybe it will turn out that such a large
> >>> portion of the chache would need to duplicate the state that a
> >>> completely new cache would be more reasonable.
> >>
> >> I'm afraid that's the case, yes.
> >>
> >>> Is this worth exploring
> >>> at least? I mean something like this should help with the fragmentation
> >>> already AFAIU. Accounting would be just free on top.
> >>
> >> Yep. It could be also CONFIG_urable so smaller systems don't need to
> >> deal with the memory overhead of this.
> >>
> >> So do we put it on LSF/MM agenda?
> > 
> > If you volunteer to lead the discussion, then I do not have any
> > objections.
> 
> Sure, let's add the topic of SLAB_MINIMIZE_WASTE [1] as well.
> 
> Something like "Supporting reclaimable kmalloc caches and large
> non-buddy-sized objects in slab allocators" ?
> 
> [1] https://marc.info/?l=linux-mm&m=152156671614796&w=2

OK, noted.

-- 
Michal Hocko
SUSE Labs
