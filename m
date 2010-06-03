Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2264C6B0222
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 10:28:40 -0400 (EDT)
Date: Thu, 3 Jun 2010 16:27:17 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/5] oom: select_bad_process: check PF_KTHREAD instead
	of !mm to skip kthreads
Message-ID: <20100603142717.GC3548@redhat.com>
References: <20100601212023.GA24917@redhat.com> <alpine.DEB.2.00.1006011424200.16725@chino.kir.corp.google.com> <20100602223612.F52D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006021405280.32666@chino.kir.corp.google.com> <20100602213331.GA31949@redhat.com> <alpine.DEB.2.00.1006021437010.4765@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006021437010.4765@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/02, David Rientjes wrote:
>
> On Wed, 2 Jun 2010, Oleg Nesterov wrote:
>
> > > This isn't a bugfix, it simply prevents a recall to the oom killer after
> > > the kthread has called unuse_mm().  Please show where any side effects of
> > > oom killing a kthread, which cannot exit, as a result of use_mm() causes a
> > > problem _anywhere_.
> >
> > I already showed you the side effects, but you removed this part in your
> > reply.
> >
> > From http://marc.info/?l=linux-kernel&m=127542732121077
> >
> > 	It can't die but force_sig() does bad things which shouldn't be done
> > 	with workqueue thread. Note that it removes SIG_IGN, sets
> > 	SIGNAL_GROUP_EXIT, makes signal_pending/fatal_signal_pedning true, etc.
> >
> > A workqueue thread must not run with SIGNAL_GROUP_EXIT set, SIGKILL
> > must be ignored, signal_pending() must not be true.
> >
> > This is bug. It is minor, agreed, currently use_mm() is only used by aio.
>
> It's a problem that would probably never happen in practice because

No need to convince me this bug is minor. I repeated this every time.
I only argued with the "isn't a bugfix, no side effects".

> considered the ideal task to kill.  If you think this is rc material, then
> push it to Andrew and say that.

No, I don't think it is strictly necessary to push this fix into rc.
But I don't understand why this matters. And in any case, when it comes
to oom, I am in no position to make any authoritative decisions.


David, I don't understand why do you refuse to re-diff your changes
on top of Kosaki's work. If nothing else, this will help to review
your changes.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
