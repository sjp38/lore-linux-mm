Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7946B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 07:36:48 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp09.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4PBSWJ0015696
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:58:32 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4PBagVE2998352
	for <linux-mm@kvack.org>; Wed, 25 May 2011 17:06:42 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4PBaeN2014659
	for <linux-mm@kvack.org>; Wed, 25 May 2011 21:36:42 +1000
Date: Wed, 25 May 2011 08:55:21 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH V5] memcg: add memory.numastat api for numa statistics
Message-ID: <20110525032521.GD3440@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1305928918-15207-1-git-send-email-yinghan@google.com>
 <20110524154644.GA3440@balbir.in.ibm.com>
 <BANLkTim+evwxEAYtQQ339N_tqV5jyWVH2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <BANLkTim+evwxEAYtQQ339N_tqV5jyWVH2w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

* Ying Han <yinghan@google.com> [2011-05-24 09:54:43]:

> > >  static struct cftype mem_cgroup_files[] = {
> > >       {
> > >               .name = "usage_in_bytes",
> > > @@ -4544,6 +4693,12 @@ static struct cftype mem_cgroup_files[] = {
> > >               .unregister_event = mem_cgroup_oom_unregister_event,
> > >               .private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
> > >       },
> > > +#ifdef CONFIG_NUMA
> > > +     {
> > > +             .name = "numa_stat",
> > > +             .open = mem_control_numa_stat_open,
> > > +     },
> > > +#endif
> >
> > Can't we do this the way we do the stats file? Please see
> > mem_control_stat_show().
> >
> 
> I looked that earlier but can not get the formating working as well as the
> seq_*. Is there a particular reason we prefer one than the other?
>

Fair enough, I wanted to avoid repeating what kernel/cgroup.c already
does in terms of formatting output.

 
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
