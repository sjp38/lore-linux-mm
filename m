Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 99C1C6B005C
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 00:14:50 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2I3jO6e005882
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 09:15:24 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2I4ErG93661864
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 09:44:53 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2I4Ei0W015220
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 15:14:44 +1100
Date: Wed, 18 Mar 2009 09:44:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v6)
Message-ID: <20090318041433.GX16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain> <20090314173111.16591.68465.sendpatchset@localhost.localdomain> <20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com> <20090316083512.GV16897@balbir.in.ibm.com> <20090318090747.61f09554.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090318090747.61f09554.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-18 09:07:47]:

> On Mon, 16 Mar 2009 14:05:12 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > +				next_mem =
> > > > +					__mem_cgroup_largest_soft_limit_node();
> > > > +			} while (next_mem == mem);
> > > > +		}
> > > > +		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> > > > +		__mem_cgroup_remove_exceeded(mem);
> > > > +		if (mem->usage_in_excess)
> > > > +			__mem_cgroup_insert_exceeded(mem);
> > > 
> > > If next_mem == NULL here, (means "mem" is an only mem_cgroup which excess softlimit.)
> > > mem will be found again even if !reclaimed.
> > > plz check.
> > 
> > Yes, We need to add a if (!next_mem) break; Thanks!
> > 
> Plz be sure that there can be following case.
> 
>   1. several memcg is over softlimit.
>   2. almost all memory usage comes from ANON or tmpfile/shmem.
>   3. Swapless system
>      or
>      Most of memory are mlocked.
>

Good point, will test with those as well. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
