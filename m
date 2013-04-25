Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 375966B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 19:07:15 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa11so2132433pad.27
        for <linux-mm@kvack.org>; Thu, 25 Apr 2013 16:07:14 -0700 (PDT)
Date: Thu, 25 Apr 2013 16:07:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add anon_hugepage stat
In-Reply-To: <20130425145511.68b278d2731846a6502ecc36@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1304251606480.3010@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1304251440190.27228@chino.kir.corp.google.com> <20130425145511.68b278d2731846a6502ecc36@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, 25 Apr 2013, Andrew Morton wrote:

> > This exports the amount of anonymous transparent hugepages for each memcg
> > via memory.stat in bytes.
> > 
> > This is helpful to determine the hugepage utilization for individual jobs
> > on the system in comparison to rss and opportunities where MADV_HUGEPAGE
> > may be helpful.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  include/linux/memcontrol.h |  3 ++-
> >  mm/huge_memory.c           |  2 ++
> >  mm/memcontrol.c            | 13 +++++++++----
> >  mm/rmap.c                  | 18 +++++++++++++++---
> 
> And Documentation/cgroups/memory.txt, please.
> 

Sounds good, I'll send a v2 after the memcg maintainers have had a chance 
to give feedback.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
