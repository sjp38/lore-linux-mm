Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 450E28D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 18:20:13 -0500 (EST)
Date: Wed, 9 Mar 2011 15:19:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
Message-Id: <20110309151946.dea51cde.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com>
	<20110303100030.B936.A69D9226@jp.fujitsu.com>
	<20110308134233.GA26884@redhat.com>
	<alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On Tue, 8 Mar 2011 15:57:36 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> > > > @@ -324,7 +324,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> > > >  		 * the process of exiting and releasing its resources.
> > > >  		 * Otherwise we could get an easy OOM deadlock.
> > > >  		 */
> > > > -		if (thread_group_empty(p) && (p->flags & PF_EXITING) && p->mm) {
> > > > +		if ((p->flags & PF_EXITING) && p->mm) {
> > 
> > The previous check was not perfect, we know this.
> > 
> > But with this patch applied, the simple program below disables oom-killer
> > completely. select_bad_process() can never succeed.
> > 
> 
> The program illustrates a problem that shouldn't be fixed in 
> select_bad_process() but rather in oom_kill_process() when choosing an 
> eligible child of the selected task to kill in place of its parent.

If Oleg's test program cause a hang with
oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch and doesn't
cause a hang without
oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch then that's a
big problem for
oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
