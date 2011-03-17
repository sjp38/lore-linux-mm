Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5438D0041
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 19:38:06 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p2HNbwZ0003932
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 16:37:59 -0700
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by kpbe18.cbf.corp.google.com with ESMTP id p2HNbqd0020429
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 16:37:57 -0700
Received: by pzk35 with SMTP id 35so572722pzk.34
        for <linux-mm@kvack.org>; Thu, 17 Mar 2011 16:37:52 -0700 (PDT)
Date: Thu, 17 Mar 2011 16:37:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: give current access to memory reserves if it's
 trying to die
In-Reply-To: <20110310083011.c36247b8.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103171636330.10971@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com> <20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com> <20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com> <20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1103081540320.27910@chino.kir.corp.google.com> <20110309150452.29883939.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103082239340.15665@chino.kir.corp.google.com> <20110309161621.f890c148.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1103091307370.15068@chino.kir.corp.google.com> <alpine.DEB.2.00.1103091327260.15068@chino.kir.corp.google.com> <20110310083011.c36247b8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Thu, 10 Mar 2011, KAMEZAWA Hiroyuki wrote:

> On Wed, 9 Mar 2011 13:27:50 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
> 
> > When a memcg is oom and current has already received a SIGKILL, then give
> > it access to memory reserves with a higher scheduling priority so that it
> > may quickly exit and free its memory.
> > 
> > This is identical to the global oom killer and is done even before
> > checking for panic_on_oom: a pending SIGKILL here while panic_on_oom is
> > selected is guaranteed to have come from userspace; the thread only needs
> > access to memory reserves to exit and thus we don't unnecessarily panic
> > the machine until the kernel has no last resort to free memory.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Thank you.
> 

I'm hoping this can make 2.6.39 so that userspace can kill a thread in a 
memcg when it is oom and the oom killer is disabled via memory.oom_control 
and it will still get access to memory reserves if needed while trying to 
exit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
