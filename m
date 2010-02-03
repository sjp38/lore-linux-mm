Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 135F56B004D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 20:56:06 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o131u35n027032
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Feb 2010 10:56:04 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B82E445DE55
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 10:56:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BA2045DE52
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 10:56:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 539DB1DB8045
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 10:56:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E2AFC1DB803B
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 10:56:02 +0900 (JST)
Date: Wed, 3 Feb 2010 10:52:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Improving OOM killer
Message-Id: <20100203105236.b4a60754.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002021643240.3393@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz>
	<alpine.DEB.2.00.1002011523280.19457@chino.kir.corp.google.com>
	<201002022210.06760.l.lunak@suse.cz>
	<alpine.DEB.2.00.1002021643240.3393@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lubos Lunak <l.lunak@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Feb 2010 17:41:41 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 2 Feb 2010, Lubos Lunak wrote:
> 
> > > > init
> > > >   |- kdeinit
> > > >   |  |- ksmserver
> > > >   |  |  |- kwin
> > > >   |  |- <other>
> > > >   |- konsole
> > > >      |- make
> > > >         |- sh
> > > >         |  |- meinproc4
> > > >         |- sh
> > > >         |  |- meinproc4
> > > >         |- <etc>
> > > >
> > > >  What happens is that OOM killer usually selects either ksmserver (KDE
> > > > session manager) or kdeinit (KDE master process that spawns most KDE
> > > > processes). Note that in either case OOM killer does not reach the point
> > > > of killing the actual offender - it will randomly kill in the tree under
> > > > kdeinit until it decides to kill ksmserver, which means terminating the
> > > > desktop session. As konsole is a KUniqueApplication, it forks into
> > > > background and gets reparented to init, thus getting away from the
> > > > kdeinit subtree. Since the memory pressure is distributed among several
> > > > meinproc4 processes, the badness does not get summed up in its make
> > > > grandparent, as badness() does this only for direct parents.
> > >
> > > There's no randomness involved in selecting a task to kill;
> > 
> >  That was rather a figure of speech, but even if you want to take it 
> > literally, then from the user's point of view it is random. Badness of 
> > kdeinit depends on the number of children it has spawned, badness of 
> > ksmserver depends for example on the number and size of windows open (as its 
> > child kwin is a window and compositing manager).
> > 
> 
> As I've mentioned, I believe Kame (now cc'd) is working on replacing the 
> heuristic that adds the VM size for children into the parent task's 
> badness score with a forkbomb detector. 

I stopped that as I mentioned. I'm heavily disappointed with myself and
would like not to touch oom-killer things for a while.

I'd like to conentrate on memcg for a while, which I've starved for these 3 months.

Then, you don't need to CC me.

Bye,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
