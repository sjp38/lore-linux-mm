Date: Thu, 12 Jun 2008 15:51:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Message-Id: <20080612155141.80e4050d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080612052033.ED6FD5A0D@siro.lan>
References: <20080611131437.76961fc3.kamezawa.hiroyu@jp.fujitsu.com>
	<20080612052033.ED6FD5A0D@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, menage@google.com, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008 14:20:33 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > > i think that you can redirect new charges in TASK to DEST
> > > so that usage_of_task(TASK) will not grow.
> > > 
> > 
> > Hmm, to do that, we have to handle complicated cgroup's attach ops.
> > 
> > at this moving, memcg is pointed by
> >  - TASK->cgroup->memcg(CURR)
> > after move
> >  - TASK->another_cgroup->memcg(DEST)
> > 
> > This move happens before cgroup is replaced by another_cgroup.
> 
> currently cgroup_attach_task calls ->attach callbacks after
> assigning tsk->cgroups.  are you talking about something else?
> 

Sorry, I move all in can_attach().  s/attach/can_attach

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
