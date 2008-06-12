Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
In-Reply-To: Your message of "Wed, 11 Jun 2008 13:14:37 +0900"
	<20080611131437.76961fc3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611131437.76961fc3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080612052033.ED6FD5A0D@siro.lan>
Date: Thu, 12 Jun 2008 14:20:33 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, menage@google.com, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> > i think that you can redirect new charges in TASK to DEST
> > so that usage_of_task(TASK) will not grow.
> > 
> 
> Hmm, to do that, we have to handle complicated cgroup's attach ops.
> 
> at this moving, memcg is pointed by
>  - TASK->cgroup->memcg(CURR)
> after move
>  - TASK->another_cgroup->memcg(DEST)
> 
> This move happens before cgroup is replaced by another_cgroup.

currently cgroup_attach_task calls ->attach callbacks after
assigning tsk->cgroups.  are you talking about something else?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
