Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 955C08D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:21:43 -0400 (EDT)
Date: Tue, 15 Mar 2011 20:12:56 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/3 for 2.6.38] oom: oom_kill_process: don't set
	TIF_MEMDIE if !p->mm
Message-ID: <20110315191256.GB21640@redhat.com>
References: <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com> <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com> <20110313212726.GA24530@redhat.com> <20110314190419.GA21845@redhat.com> <20110314190446.GB21845@redhat.com> <AANLkTi=YnG7tYCSrCPTNSQANOkD2MkP0tMjbOyZbx4NG@mail.gmail.com> <alpine.DEB.2.00.1103141322390.31514@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103141322390.31514@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, Frantisek Hrbata <fhrbata@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/14, David Rientjes wrote:
>
> On Mon, 14 Mar 2011, Linus Torvalds wrote:
>
> > The combination of testing PF_EXITING and p->mm just doesn't seem to
> > make any sense.
> >
>
> Right, it doesn't (and I recently removed testing the combination from
> select_bad_process() in -mm).  The check for PF_EXITING in the oom killer
> is purely to avoid needlessly killing tasks when something is already
> exiting

Maybe 0/3 wasn't clear enough. This patches does not try to fix things,
it only tries to close the hole in 2.6.38. But it was already released
today.

> and will (hopefully) be freeing its memory soon.

This is not clear to me.

When I did this change I looked at 81236810226f71bd9ff77321c8e8276dae7efc61
and the changelog says:

	__oom_kill_task() is called to elevate the task's timeslice and give it
	access to memory reserves so that it may quickly exit.

	This privilege is unnecessary, however, if the task has already detached
	its mm.

Now you are saing this is pointless.

OK. I already said I do not understand this special case. Perhaps I'll ask
the questions later.

> If an eligible
> thread is found to be PF_EXITING,

The problem is, we can't trust per-thread PF_EXITING checks. But I guess
we will discuss this more anyway.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
