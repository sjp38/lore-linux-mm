Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 928A36B025F
	for <linux-mm@kvack.org>; Sun, 13 Aug 2017 10:52:40 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id c74so85445379iod.4
        for <linux-mm@kvack.org>; Sun, 13 Aug 2017 07:52:40 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h2si3542613itg.75.2017.08.13.07.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Aug 2017 07:52:39 -0700 (PDT)
Date: Sun, 13 Aug 2017 16:52:27 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/3] mm/sched: memdelay: memory health interface for
 systems and workloads
Message-ID: <20170813145227.eblt2ihn6wlqmcyn@hirez.programming.kicks-ass.net>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
 <20170727153010.23347-4-hannes@cmpxchg.org>
 <20170729091055.GA6524@worktop.programming.kicks-ass.net>
 <20170730152813.GA26672@cmpxchg.org>
 <20170731083111.tgjgkwge5dgt5m2e@hirez.programming.kicks-ass.net>
 <20170731184142.GA30943@cmpxchg.org>
 <20170801075728.GE6524@worktop.programming.kicks-ass.net>
 <20170801122634.GA7237@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170801122634.GA7237@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Aug 01, 2017 at 08:26:34AM -0400, Johannes Weiner wrote:
> On Tue, Aug 01, 2017 at 09:57:28AM +0200, Peter Zijlstra wrote:

> > And you haven't even defined wth a memdelay section is yet..
> 
> It's what a task is in after it calls memdelay_enter() and before it
> calls memdelay_leave().

Urgh, yes that makes it harder to reusing existing bits.. although
delayacct seems to do something vaguely similar. I've never really
looked at that, but if you can reuse/merge that would of course be good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
