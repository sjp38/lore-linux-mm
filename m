Date: Tue, 28 Oct 2008 22:13:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [discuss][memcg] oom-kill extension
In-Reply-To: <20081029140012.fff30bce.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0810282206260.10159@chino.kir.corp.google.com>
References: <20081029113826.cc773e21.kamezawa.hiroyu@jp.fujitsu.com> <4907E1B4.6000406@linux.vnet.ibm.com> <20081029140012.fff30bce.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Oct 2008, KAMEZAWA Hiroyuki wrote:

> > > Does anyone have plan to enhance oom-kill ?
> > > 
> > > What I can think of now is
> > >   - add an notifier to user-land.
> > >     - receiver of notify should work in another cgroup.
> > 
> > The discussion at the mini-summit was to notify a FIFO in the cgroup and any
> > application can listen in for events.
> > 
> add FIFO rather than netlink or user mode helper ?
> 

There was a patchset from February that added /dev/mem_notify to warn 
userspace of low or out of memory conditions:

	http://marc.info/?l=linux-kernel&m=120257050719077
	http://marc.info/?l=linux-kernel&m=120257050719087
	http://marc.info/?l=linux-kernel&m=120257062719234
	http://marc.info/?l=linux-kernel&m=120257071219327
	http://marc.info/?l=linux-kernel&m=120257071319334
	http://marc.info/?l=linux-kernel&m=120257080919488
	http://marc.info/?l=linux-kernel&m=120257081019497
	http://marc.info/?l=linux-kernel&m=120257096219705
	http://marc.info/?l=linux-kernel&m=120257096319717

Perhaps this idea can simply be reworked for the memory controller or 
standalone cgroup?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
