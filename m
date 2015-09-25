Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id D63156B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 11:20:19 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so26625409wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 08:20:19 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id hg7si5247941wib.23.2015.09.25.08.20.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 08:20:18 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so24164583wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 08:20:18 -0700 (PDT)
Date: Fri, 25 Sep 2015 17:20:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: make mem_cgroup_read_stat() unsigned
Message-ID: <20150925152017.GO16497@dhcp22.suse.cz>
References: <20150922210346.749204fb.akpm@linux-foundation.org>
 <xr936131mwhu.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr936131mwhu.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed 23-09-15 00:21:33, Greg Thelen wrote:
> 
> Andrew Morton wrote:
> 
> > On Tue, 22 Sep 2015 17:42:13 -0700 Greg Thelen <gthelen@google.com> wrote:
[...]
> >> I assume it's pretty straightforward to create generic
> >> percpu_counter_array routines which memcg could use.  Possibly something
> >> like this could be made general enough could be created to satisfy
> >> vmstat, but less clear.
> >> 
> >> [1] http://www.spinics.net/lists/cgroups/msg06216.html
> >> [2] https://lkml.org/lkml/2014/9/11/1057
> >
> > That all sounds rather bogus to me.  __percpu_counter_add() doesn't
> > modify struct percpu_counter at all except for when the cpu-local
> > counter overflows the configured batch size.  And for the memcg
> > application I suspect we can set the batch size to INT_MAX...
> 
> Nod.  The memory usage will be a bit larger, but the code reuse is
> attractive.  I dusted off Vladimir's
> https://lkml.org/lkml/2014/9/11/710.  Next step is to benchmark it
> before posting.

I am definitely in favor of using generic per-cpu counters.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
