Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4B1280255
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 04:07:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so9378784wmg.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:07:17 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id xt6si6379139wjb.168.2016.09.23.01.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 01:07:12 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id l132so1432905wmf.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:07:11 -0700 (PDT)
Date: Fri, 23 Sep 2016 10:07:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] scripts: Include postprocessing script for memory
 allocation tracing
Message-ID: <20160923080709.GB4478@dhcp22.suse.cz>
References: <20160911222411.GA2854@janani-Inspiron-3521>
 <20160912121635.GL14524@dhcp22.suse.cz>
 <0ACE5927-A6E5-4B49-891D-F990527A9F50@gmail.com>
 <20160919094224.GH10785@dhcp22.suse.cz>
 <BFAF8DCA-F4A6-41C6-9AA0-C694D33035A3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BFAF8DCA-F4A6-41C6-9AA0-C694D33035A3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, rostedt@goodmis.org

On Thu 22-09-16 11:30:36, Janani Ravichandran wrote:
> 
> > On Sep 19, 2016, at 5:42 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > On Tue 13-09-16 14:04:49, Janani Ravichandran wrote:
> >> 
> >>> On Sep 12, 2016, at 8:16 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >> 
> >> Ia??m using the function graph tracer to see how long __alloc_pages_nodemask()
> >> took.
> > 
> > How can you map the function graph tracer to a specif context? Let's say
> > I would like to know why a particular allocation took so long. Would
> > that be possible?
> 
> Maybe not. If the latencies are due to direct reclaim or memory compaction, you
> get some information from the tracepoints (like mm_vmscan_direct_reclaim_begin,
> mm_compaction_begin, etc). But otherwise, you dona??t get any context information. 
> Function graph only gives the time spent in alloc_pages_nodemask() in that case.

Then I really think that we need a starting trace point. I think that
having the full context information is really helpful in order to
understand latencies induced by allocations.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
