Date: Thu, 6 Mar 2008 18:05:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Supporting overcommit with the memory controller
Message-Id: <20080306180541.404bfd12.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47CFB193.3040501@openvz.org>
References: <6599ad830803051617w7835d9b2l69bbc1a0423eac41@mail.gmail.com>
	<20080306100158.a521af1b.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830803051854x5ee204bej7212d9c1e444e4d0@mail.gmail.com>
	<47CFB193.3040501@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Paul Menage <menage@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>, Linux Containers <containers@lists.osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 06 Mar 2008 11:55:47 +0300
Pavel Emelyanov <xemul@openvz.org> wrote:

> >>  Can Balbir's soft-limit patches help ?
> 
> [snip]
> 
> > 
> > Yes, that could be a useful part of the solution - I suspect we'd need
> > to have kswapd do the soft-limit push back as well as in
> > try_to_free_pages(), to avoid the high-priority jobs getting stuck in
> > the reclaim code. It would also be nice if we had:
> 
> BTW, one of the way OpenVZ users determine how much memory they
> need for containers is the following: they set the limits to
> maximal values and then check the "maxheld" (i.e. the maximal level
> of consumption over the time) value.
> 
> Currently, we don't have such in res_counters and I'm going to
> implement this. Objections?
> 
Basically, no objection.

BTW, which does it means ? 
- create a new cgroup to accounting max memory consumption, etc...
or
- add new member to mem_cgroup
or
- add new member to res_counter

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
