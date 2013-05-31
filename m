Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 119DD6B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 07:02:05 -0400 (EDT)
Date: Fri, 31 May 2013 13:02:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130531110202.GB32491@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
 <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri 31-05-13 03:22:59, David Rientjes wrote:
> On Fri, 31 May 2013, Michal Hocko wrote:
[...]
> > > If the oom notifier is in the oom cgroup, it may not be able to       
> > > successfully read the memcg "tasks" file to even determine the set of 
> > > eligible processes.
> > 
> > It would have to use preallocated buffer and have mlocked all the memory
> > that will be used during oom event.
> > 
> 
> Wrong, the kernel itself allocates memory when reading this information 
> and that would fail in an oom memcg.

But that memory is not charged to a memcg, is it? So unless you are
heading towards global OOM you should be safe.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
