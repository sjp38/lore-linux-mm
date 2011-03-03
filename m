Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C31D48D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 16:52:59 -0500 (EST)
Date: Thu, 3 Mar 2011 13:52:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110303135223.0a415e69.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com>
	<20110223150850.8b52f244.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Wed, 23 Feb 2011 16:51:24 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> > The problem is that the userspace oom handler is also taking peeks into
> > processes which are in the stressed memcg and is getting stuck on
> > mmap_sem in the procfs reads.  Correct?
> > 
> 
> That's outside the scope of this feature and is a separate discussion; 
> this patch specifically addresses an issue where a userspace job scheduler 
> wants to take action when a memcg is oom before deferring to the kernel 
> and happens to become unresponsive for whatever reason.

That's just handwaving used to justify a workaround for a kernel
deficiency.

If userspace has chosen to repalce the oom-killer then userspace should
be able to appropriately perform the role.  But for some
as-yet-undescribed reason, userspace is *not* able to perform that
role.

And I'm suspecting that the as-yet-undescribed reason is a kernel
deficiency.  Spit it out.

> > It seems to me that such a userspace oom handler is correctly designed,
> > and that we should be looking into the reasons why it is unreliable,
> > and fixing them.  Please tell us about this?
> > 
> 
> The problem isn't specific to any one cause or implementation, we know 
> that userspace programs have bugs, they can stall forever in D-state, they 
> can be oom themselves, they get stuck waiting on a lock, etc etc.

It's not the kernel's role to work around userspace bugs and it's
certainly not the kernel's role to work around kernel bugs.

Now please tell us: why is the userspace job manager getting stuck?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
