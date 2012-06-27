Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id EC90E6B0071
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:46:11 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2233057dak.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:46:11 -0700 (PDT)
Date: Wed, 27 Jun 2012 12:46:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 06/11] memcg: kmem controller infrastructure
In-Reply-To: <4FEAD351.2030203@parallels.com>
Message-ID: <alpine.DEB.2.00.1206271239340.22162@chino.kir.corp.google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-7-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206260210200.16020@chino.kir.corp.google.com> <4FE97E31.3010201@parallels.com>
 <alpine.DEB.2.00.1206262100320.24245@chino.kir.corp.google.com> <4FEAD351.2030203@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 27 Jun 2012, Glauber Costa wrote:

> > > Nothing, but I also don't see how to prevent that.
> > 
> > You can test for current->flags & PF_KTHREAD following the check for
> > in_interrupt() and return true, it's what you were trying to do with the
> > check for !current->mm.
> > 
> 
> am I right to believe that if not in interrupt context - already ruled out -
> and !(current->flags & PF_KTHREAD), I am guaranteed to have a mm context, and
> thus, don't need to test against it ?
> 

No, because an mm may have been detached in the exit path by running 
exit_mm().  We'd certainly hope that there are no slab allocations 
following that point, though, but you'd still need to test current->mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
