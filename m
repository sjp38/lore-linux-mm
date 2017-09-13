Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5A86B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 10:35:13 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m127so968451wmm.3
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 07:35:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si1230861wmc.93.2017.09.13.07.35.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 07:35:12 -0700 (PDT)
Date: Wed, 13 Sep 2017 16:35:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: respect the __GFP_NOWARN flag when warning about
 stalls
Message-ID: <20170913143509.6wtp3pd5yhqe53ck@dhcp22.suse.cz>
References: <20170911082650.dqfirwc63xy7i33q@dhcp22.suse.cz>
 <alpine.LRH.2.02.1709111926480.31898@file01.intranet.prod.int.rdu2.redhat.com>
 <20170913115442.4tpbiwu77y7lrz6g@dhcp22.suse.cz>
 <201709132254.DEE34807.LQOtMFOFJSOVHF@I-love.SAKURA.ne.jp>
 <bcd7002d-d352-1f24-e15b-49642f978267@suse.cz>
 <201709132314.BID39077.HMFOJSLFtVOFOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201709132314.BID39077.HMFOJSLFtVOFOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: vbabka@suse.cz, mpatocka@redhat.com, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 13-09-17 23:14:43, Tetsuo Handa wrote:
> Vlastimil Babka wrote:
> > On 09/13/2017 03:54 PM, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > >> Let's see what others think about this.
> > > 
> > > Whether __GFP_NOWARN should warn about stalls is not a topic to discuss.
> > 
> > It is the topic of this thread, which tries to address a concrete
> > problem somebody has experienced. In that context, the rest of your
> > concerns seem to me not related to this problem, IMHO.
> 
> I suggested replacing warn_alloc() with safe/useful one rather than tweaking
> warn_alloc() about __GFP_NOWARN.

What you seem to ignore is that whatever method you use for reporting
stalling allocations you would still have to consider whether to dump
a stall information for __GFP_NOWARN ones. And as the current report
shows that might be a bad idea. So please stick to the topic and do not
move it towards _what_ is the proper way of stall detection.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
