Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA856B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 09:00:09 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so35385493lfe.0
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 06:00:09 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id o2si3377481wmg.89.2016.07.29.06.00.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 06:00:08 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id B97511C198B
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 14:00:07 +0100 (IST)
Date: Fri, 29 Jul 2016 14:00:06 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
Message-ID: <20160729130005.GE2799@techsingularity.net>
References: <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
 <20160711143342.GN1811@dhcp22.suse.cz>
 <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
 <20160720145405.GP11249@dhcp22.suse.cz>
 <5e6e4f2d-ae94-130e-198d-fa402a9eef50@suse.de>
 <20160728054947.GL12670@dastard>
 <20160728102513.GA2799@techsingularity.net>
 <20160729001340.GM12670@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160729001340.GM12670@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Tony Jones <tonyj@suse.de>, Michal Hocko <mhocko@suse.cz>, Janani Ravichandran <janani.rvchndrn@gmail.com>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Fri, Jul 29, 2016 at 10:13:40AM +1000, Dave Chinner wrote:
> On Thu, Jul 28, 2016 at 11:25:13AM +0100, Mel Gorman wrote:
> > On Thu, Jul 28, 2016 at 03:49:47PM +1000, Dave Chinner wrote:
> > > Seems you're all missing the obvious.
> > > 
> > > Add a tracepoint for a shrinker callback that includes a "name"
> > > field, have the shrinker callback fill it out appropriately. e.g
> > > in the superblock shrinker:
> > > 
> > > 	trace_shrinker_callback(shrinker, shrink_control, sb->s_type->name);
> > > 
> > 
> > That misses capturing the latency of the call unless there is a begin/end
> > tracepoint.
> 
> Sure, but I didn't see that in the email talking about how to add a
> name. Even if it is a requirement, it's not necessary as we've
> already got shrinker runtime measurements from the
> trace_mm_shrink_slab_start and trace_mm_shrink_slab_end trace
> points. With the above callback event, shrinker call runtime is
> simply the time between the calls to the same shrinker within
> mm_shrink_slab start/end trace points.
> 

Fair point. It's not that hard to correlate them.

> <SNIP>
> 
> > My understanding was the point of the tracepoints was to get detailed
> > information on points where the kernel is known to stall for long periods
> > of time.
> 
> First I've heard that's what tracepoints are supposed to be used
> for.

I meant the specific case of trace_X_begin followed by trace_X_end, not
tracepoints in general.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
