Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 378C26B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 20:36:13 -0500 (EST)
Date: Thu, 8 Mar 2012 17:38:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, memcg: do not allow tasks to be attached with zero
 limit
Message-Id: <20120308173818.ae5f621b.akpm@linux-foundation.org>
In-Reply-To: <20120309102255.bbf94164.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.DEB.2.00.1203071914150.15244@chino.kir.corp.google.com>
	<20120308122951.2988ec4e.akpm@linux-foundation.org>
	<20120309102255.bbf94164.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Fri, 9 Mar 2012 10:22:55 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 8 Mar 2012 12:29:51 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Wed, 7 Mar 2012 19:14:49 -0800 (PST)
> > David Rientjes <rientjes@google.com> wrote:
> > 
> > > This patch prevents tasks from being attached to a memcg if there is a
> > > hard limit of zero.
> > 
> > We're talking about the memcg's limit_in_bytes here, yes?
> > 
> > > Additionally, the hard limit may not be changed to
> > > zero if there are tasks attached.
> > 
> > hm, well...  why?  That would be user error, wouldn't it?  What is
> > special about limit_in_bytes=0?  The memcg will also be unviable if
> > limit_in_bytes=1, but we permit that.
> > 
> > IOW, confused.
> > 
> Ah, yes. limit_in_bytes < some small size can cause the same trouble.
> Hmm... should we have configurable min_limit_in_bytes as sysctl or root memcg's
> attaribute.. ?

Why do *anything*?  If the operator chose an irrational configuration
then things won't work correctly and the operator will then fix the
configuration?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
