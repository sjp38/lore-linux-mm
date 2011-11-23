Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 675E46B00AB
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 17:35:56 -0500 (EST)
Received: by iaek3 with SMTP id k3so2870160iae.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 14:35:53 -0800 (PST)
Date: Wed, 23 Nov 2011 14:35:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/8] mm: oom_kill: remove memcg argument from
 oom_kill_task()
In-Reply-To: <1322062951-1756-2-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.00.1111231435400.5261@chino.kir.corp.google.com>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org> <1322062951-1756-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Nov 2011, Johannes Weiner wrote:

> From: Johannes Weiner <jweiner@redhat.com>
> 
> The memcg argument of oom_kill_task() hasn't been used since 341aea2
> 'oom-kill: remove boost_dying_task_prio()'.  Kill it.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
