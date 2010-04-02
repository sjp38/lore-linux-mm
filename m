Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E65A46B01F3
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 15:46:43 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o32JkdM0006883
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 12:46:40 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by wpaz1.hot.corp.google.com with ESMTP id o32Jkbwx013306
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 12:46:38 -0700
Received: by pwi5 with SMTP id 5so1888628pwi.19
        for <linux-mm@kvack.org>; Fri, 02 Apr 2010 12:46:37 -0700 (PDT)
Date: Fri, 2 Apr 2010 12:46:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
 been killed
In-Reply-To: <20100402191414.GA982@redhat.com>
Message-ID: <alpine.DEB.2.00.1004021244010.15445@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com>
 <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com> <20100402111406.GA4432@redhat.com> <alpine.DEB.2.00.1004021159310.1773@chino.kir.corp.google.com>
 <20100402191414.GA982@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Apr 2010, Oleg Nesterov wrote:

> > > David, you continue to ignore my arguments ;) select_bad_process()
> > > must not filter out the tasks with ->mm == NULL.
> > >
> > I'm not ignoring your arguments, I think you're ignoring what I'm
> > responding to.
> 
> Ah, sorry, I misunderstood your replies.
> 
> > I prefer to keep oom_badness() to be a positive range as
> > it always has been (and /proc/pid/oom_score has always used an unsigned
> > qualifier),
> 
> Yes, I thought about /proc/pid/oom_score, but imho this is minor issue.
> We can s/%lu/%ld/ though, or just report 0 if oom_badness() returns -1.
> Or something.
> 

Just have it return 0, meaning never kill, and then ensure "chosen" is 
never set for an oom_badness() of 0, even if we don't have another task to 
kill.  That's how Documentation/filesystems/proc.txt describes it anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
