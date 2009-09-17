Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F401D6B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 00:48:08 -0400 (EDT)
Date: Thu, 17 Sep 2009 13:40:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 4/8] memcg: add interface to migrate charge
Message-Id: <20090917134029.2a3f5c54.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090917132007.8e371add.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917112602.1db6e21e.nishimura@mxp.nes.nec.co.jp>
	<20090917132007.8e371add.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 13:20:07 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 17 Sep 2009 11:26:02 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This patch adds "memory.migrate_charge" file and handlers of it.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |   69 +++++++++++++++++++++++++++++++++++++++++++++++++++---
> >  1 files changed, 65 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 6d77c80..6466e3c 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -225,6 +225,8 @@ struct mem_cgroup {
> >  	/* set when res.limit == memsw.limit */
> >  	bool		memsw_is_minimum;
> >  
> > +	unsigned int 	migrate_charge;
> > +
> >  	/*
> >  	 * statistics. This must be placed at the end of memcg.
> >  	 */
> > @@ -2826,6 +2828,31 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
> >  	return 0;
> >  }
> >  
> > +enum migrate_charge_type {
> > +	NR_MIGRATE_CHARGE_TYPE,
> > +};
> > +
> 
> To be honest, I don't like this MIGRATE_CHARGE_TYPE.
> Why is this necessary to be complicated rather than true/false here ?
> Is there much variation of use-case ?
> 
hmm, I introduced it just to implement and test this feature step by step.
But considering more, I think you're right. It just complicate the code.

I'll change it bool. It will make the code simpler.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
