Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0D2838D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 10:49:12 -0500 (EST)
Date: Thu, 10 Mar 2011 16:40:32 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/1] Was: oom: prevent unnecessary oom kills or kernel
	panics
Message-ID: <20110310154032.GA29044@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309110606.GA16719@redhat.com> <alpine.DEB.2.00.1103091222420.13353@chino.kir.corp.google.com> <20110310120519.GA18415@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110310120519.GA18415@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On 03/10, Oleg Nesterov wrote:
>
> On 03/09, David Rientjes wrote:
> >
> > On Wed, 9 Mar 2011, Oleg Nesterov wrote:
> >
> > > > Using for_each_process() does not consider threads that have failed to
> > > > exit after the oom killed parent and, thus, we select another innocent
> > > > task to kill when we're really just waiting for those threads to exit
> > >
> > > How so? select_bad_process() checks TIF_MEMDIE and returns ERR_PTR()
> > > if it is set.
> > >
> >
> > TIF_MEMDIE is quite obviously a per-thread flag

> Yes, and this is why I think it should be replaced.

But this is not simple. I'd suggest this patch as the first step.

It is not tested. I do not pretend I really understand oom-killer in
all details (although oom_kill.c itself is quite trivial).

The patch assumes that

	oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch
	oom-skip-zombies-when-iterating-tasklist.patch

are dropped.

I think, this patch __might__ address the problems described in the
changelog, but of course I am not sure.

I am relying on your and Kosaki's review, if you disagree with this
change I won't argue.

But the current usage of TIF_MEMDIE can't be right.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
