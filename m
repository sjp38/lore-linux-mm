Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3090560080F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 21:21:21 -0400 (EDT)
Date: Tue, 24 Aug 2010 10:14:25 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: use ID in page_cgroup
Message-Id: <20100824101425.2dc25773.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100824085243.8dd3c8de.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820190132.43684862.kamezawa.hiroyu@jp.fujitsu.com>
	<20100823143237.b7822ffc.nishimura@mxp.nes.nec.co.jp>
	<20100824085243.8dd3c8de.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> > > @@ -723,6 +729,11 @@ static inline bool mem_cgroup_is_root(st
> > >  	return (mem == root_mem_cgroup);
> > >  }
> > >  
> > > +static inline bool mem_cgroup_is_rootid(unsigned short id)
> > > +{
> > > +	return (id == 1);
> > > +}
> > > +
> > It might be better to add
> > 
> > 	BUG_ON(newid->id != 1)
> > 
> > in cgroup.c::cgroup_init_idr().
> > 
> 
> Why ??
> 
Just to make sure that the root css has id==1. mem_cgroup_is_rootid() make
use of the fact.
I'm sorry if I miss something.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
