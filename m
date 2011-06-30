Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CE5636B0082
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 03:33:07 -0400 (EDT)
Date: Thu, 30 Jun 2011 09:33:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] [Cleanup] memcg: export memory cgroup's swappiness v2
Message-ID: <20110630073300.GA13560@tiehlicka.suse.cz>
References: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
 <20110629130043.4dc47249.akpm@linux-foundation.org>
 <20110630123229.37424449.kamezawa.hiroyu@jp.fujitsu.com>
 <20110630063231.GA12342@tiehlicka.suse.cz>
 <20110630161039.604f91b9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110630161039.604f91b9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>

On Thu 30-06-11 16:10:39, KAMEZAWA Hiroyuki wrote:
> On Thu, 30 Jun 2011 08:32:32 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Thu 30-06-11 12:32:29, KAMEZAWA Hiroyuki wrote:
> > [...]
> > > @@ -4288,7 +4287,7 @@ static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
> > >  {
> > >  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > >  
> > > -	return get_swappiness(memcg);
> > > +	return mem_cgroup_swappiness(memcg);
> > >  }
> > 
> > If you want to be type clean you should change this one as well. I
> > think it is worth it, though. The function is called only to return the
> > current value to userspace and mem_cgroup_swappiness_write guaranties
> > that it falls down into <0,100> interval. Additionally, cftype doesn't
> > have any read specialization for int values so you would need to use a
> > generic one. Finally if you changed read part you should change also
> > write part and add > 0 check which is a lot of code for not that good
> > reason.
> 
> I don't want to make this type-clean. 

Agreed.

> Should I add type casting as
> ==
>  return (u64) mem_cgroup_swappiness(memcg);
> ==
> ?

I do not think it is necessary. The value is promoted to u64
automatically.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
