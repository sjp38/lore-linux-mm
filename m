Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CE2E96B01AF
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:36:07 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: [PATCH] oom: Make coredump interruptible
In-Reply-To: Oleg Nesterov's message of  Sunday, 13 June 2010 17:53:54 +0200 <20100613155354.GA8428@redhat.com>
References: <20100604112721.GA12582@redhat.com>
	<20100609195309.GA6899@redhat.com>
	<20100613175547.616F.A69D9226@jp.fujitsu.com>
	<20100613155354.GA8428@redhat.com>
Message-Id: <20100614003601.0FB21408C1@magilla.sf.frob.com>
Date: Sun, 13 Jun 2010 17:36:00 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> > 	1) back to implement signal->oom_victim
> > 	   because We are using SIGKILL for OOM and struct signal
> > 	   naturally represent signal target.
> 
> Yes, but if this process participates in the coredump, we should find
> the right thread, or mark mm or mm->core_state.
> 
> In fact, I was never sure that oom-kill should kill the single process.
> Perhaps it should kill all tasks using the same ->mm instead. But this
> is another story.

Indeed.  But as long as oom_kill acts on process granularity, I don't think
we should have it set an mm-granularity flag.  That calculus changes if a
core dump is actually in progress, since that is already definitely going
to kill all tasks using that mm.  When no dump is in progress, it feels
wrong to leave any state change in mm, since the other mm-sharers were not
affected.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
