Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id BB6546B0072
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 17:05:02 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so1014857pbb.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 14:05:02 -0700 (PDT)
Date: Tue, 10 Jul 2012 14:05:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/5] mm, oom: move declaration for mem_cgroup_out_of_memory
 to oom.h
In-Reply-To: <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1207101404470.12399@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, 29 Jun 2012, David Rientjes wrote:

> mem_cgroup_out_of_memory() is defined in mm/oom_kill.c, so declare it in
> linux/oom.h rather than linux/memcontrol.h.
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: David Rientjes <rientjes@google.com>

Ping on this patchset?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
