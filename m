Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 537BD6B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 20:58:41 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C11433EE0C0
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:58:39 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A71E545DE64
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:58:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E6C545DE5D
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:58:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B09E1DB8053
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:58:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AAEE1DB804A
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:58:39 +0900 (JST)
Date: Fri, 9 Mar 2012 10:57:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm, memcg: do not allow tasks to be attached with zero
 limit
Message-Id: <20120309105706.4001646a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120308173818.ae5f621b.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1203071914150.15244@chino.kir.corp.google.com>
	<20120308122951.2988ec4e.akpm@linux-foundation.org>
	<20120309102255.bbf94164.kamezawa.hiroyu@jp.fujitsu.com>
	<20120308173818.ae5f621b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, 8 Mar 2012 17:38:18 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 9 Mar 2012 10:22:55 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 8 Mar 2012 12:29:51 -0800
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > On Wed, 7 Mar 2012 19:14:49 -0800 (PST)
> > > David Rientjes <rientjes@google.com> wrote:
> > > 
> > > > This patch prevents tasks from being attached to a memcg if there is a
> > > > hard limit of zero.
> > > 
> > > We're talking about the memcg's limit_in_bytes here, yes?
> > > 
> > > > Additionally, the hard limit may not be changed to
> > > > zero if there are tasks attached.
> > > 
> > > hm, well...  why?  That would be user error, wouldn't it?  What is
> > > special about limit_in_bytes=0?  The memcg will also be unviable if
> > > limit_in_bytes=1, but we permit that.
> > > 
> > > IOW, confused.
> > > 
> > Ah, yes. limit_in_bytes < some small size can cause the same trouble.
> > Hmm... should we have configurable min_limit_in_bytes as sysctl or root memcg's
> > attaribute.. ?
> 
> Why do *anything*?  If the operator chose an irrational configuration
> then things won't work correctly and the operator will then fix the
> configuration?
> 

Because the result of 'error operaton' is SIGKILL to a task, which may be
owned by very importang customer of hosting service.

Isn't this severe punishment for error operation ?

Considering again, I have 2 thoughts.

- it should be guarded by MiddleWare, it's not kernel job !
- memcg should be more easy-to-use, friendly to users.

If the result is just an error as EINVAL or EBUSY, I may not be nervous....

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
