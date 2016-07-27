Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8D66B0261
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 14:44:48 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so2358917lfw.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:44:48 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id fx15si8399854wjc.291.2016.07.27.11.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 11:44:47 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id x83so7723903wma.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:44:47 -0700 (PDT)
Date: Wed, 27 Jul 2016 20:44:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
Message-ID: <20160727184445.GG21859@dhcp22.suse.cz>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
 <6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
 <20160727163351.GC21859@dhcp22.suse.cz>
 <1469643382.10218.20.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469643382.10218.20.camel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com, rostedt@goodmis.org

On Wed 27-07-16 14:16:22, Rik van Riel wrote:
> On Wed, 2016-07-27 at 18:33 +0200, Michal Hocko wrote:
> > On Wed 27-07-16 10:47:59, Janani Ravichandran wrote:
> > > 
> > > Add tracepoints to the slowpath code to gather some information.
> > > The tracepoints can also be used to find out how much time was
> > > spent in
> > > the slowpath.
> > I do not think this is a right thing to measure.
> > __alloc_pages_slowpath
> > is more a code organization thing. The fast path might perform an
> > expensive operations like zone reclaim (if node_reclaim_mode > 0) so
> > these trace point would miss it.
> 
> It doesn't look like it does. The fast path either
> returns an allocated page to the caller, or calls
> into the slow path.

I must be missing something here but what prevents
__alloc_pages_nodemask->get_page_from_freelist from doing zone_reclaim?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
