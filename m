Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 918316B025F
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 02:36:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i124so23218489wmf.7
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 23:36:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t15si4562814wrg.337.2017.10.08.23.36.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 08 Oct 2017 23:36:43 -0700 (PDT)
Date: Mon, 9 Oct 2017 08:36:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
Message-ID: <20171009063642.nykrjazifntrj5zz@dhcp22.suse.cz>
References: <1507152550-46205-1-git-send-email-yang.s@alibaba-inc.com>
 <1507152550-46205-4-git-send-email-yang.s@alibaba-inc.com>
 <20171006093702.3ca2p6ymyycwfgbk@dhcp22.suse.cz>
 <ff7e0d92-0f12-46fa-dbc7-79c556ffb7c2@alibaba-inc.com>
 <20171009063316.qjmunbabyr2nzh52@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171009063316.qjmunbabyr2nzh52@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 09-10-17 08:33:16, Michal Hocko wrote:
> On Sat 07-10-17 00:37:55, Yang Shi wrote:
> > 
> > 
> > On 10/6/17 2:37 AM, Michal Hocko wrote:
> > > On Thu 05-10-17 05:29:10, Yang Shi wrote:
> [...]
> > > > +	list_for_each_entry_safe(s, s2, &slab_caches, list) {
> > > > +		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
> > > > +			continue;
> > > > +
> > > > +		memset(&sinfo, 0, sizeof(sinfo));
> > > 
> > > why do you zero out the structure. All the fields you are printing are
> > > filled out in get_slabinfo.
> > 
> > No special reason, just wipe out the potential stale data on the stack.
> 
> Do not add code that has no meaning. The OOM killer is a slow path but
> that doesn't mean we should throw spare cycles out of the window.

With this fixed and the compile fix [1] folded, feel free to add my
Acked-by: Michal Hocko <mhocko@suse.com>

[1] http://lkml.kernel.org/r/1507492085-42264-1-git-send-email-yang.s@alibaba-inc.com

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
