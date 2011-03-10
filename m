Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 15AB78D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 11:48:41 -0500 (EST)
Date: Thu, 10 Mar 2011 17:40:00 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/1] select_bad_process: improve the PF_EXITING check
Message-ID: <20110310164000.GC345@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309110606.GA16719@redhat.com> <alpine.DEB.2.00.1103091222420.13353@chino.kir.corp.google.com> <20110310120519.GA18415@redhat.com> <20110310154032.GA29044@redhat.com> <20110310163652.GA345@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110310163652.GA345@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On 03/10, Oleg Nesterov wrote:
>
> On 03/10, Oleg Nesterov wrote:
> >
> > It is not tested. I do not pretend I really understand oom-killer in
> > all details (although oom_kill.c itself is quite trivial).
> >
> > The patch assumes that
> >
> > 	oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch
> > 	oom-skip-zombies-when-iterating-tasklist.patch
> >
> > are dropped.
> >
> > I think, this patch __might__ address the problems described in the
> > changelog, but of course I am not sure.
> >
> > I am relying on your and Kosaki's review, if you disagree with this
> > change I won't argue.
>
> And another uncompiled/untested/needs_review patch which might help.
              ^^^^^^^^^^

I meant, compile-tested only ;)

> Nobody ever argued, the current PF_EXITING check is not very good.
> I do not know how much it is useful, but we can at least improve it.
>
> Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
