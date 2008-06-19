Date: Thu, 19 Jun 2008 12:24:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Question : memrlimit cgroup's task_move (2.6.26-rc5-mm3)
Message-Id: <20080619122429.138a1d32.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4859CEE7.9030505@linux.vnet.ibm.com>
References: <20080619121435.f868c110.kamezawa.hiroyu@jp.fujitsu.com>
	<4859CEE7.9030505@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jun 2008 08:43:43 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

>
> > I think the charge of the new group goes to minus. right ?
> > (and old group's charge never goes down.)
> > I don't think this is "no problem".
> > 
> > What kind of patch is necessary to fix this ?
> > task_attach() should be able to fail in future ?
> > 
> > I'm sorry if I misunderstand something or this is already in TODO list.
> > 
> 
> It's already on the TODO list. Thanks for keeping me reminded about it.
> 
Okay, I'm looking foward to see how can_attach and roll-back(if necessary)
is implemnted.
As you know, I'm interested in how to handle failure of task move.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
