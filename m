Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AE1B46B0092
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 23:39:43 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 36E8F3EE0BC
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 12:39:40 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EFC745DE7E
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 12:39:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E978145DE7A
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 12:39:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DAA481DB803C
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 12:39:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 95AC81DB803A
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 12:39:39 +0900 (JST)
Date: Thu, 30 Jun 2011 12:32:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [Cleanup] memcg: export memory cgroup's swappiness v2
Message-Id: <20110630123229.37424449.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110629130043.4dc47249.akpm@linux-foundation.org>
References: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110629130043.4dc47249.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

On Wed, 29 Jun 2011 13:00:43 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 29 Jun 2011 19:03:25 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Each memory cgroup has 'swappiness' value and it can be accessed by
> > get_swappiness(memcg). The major user is try_to_free_mem_cgroup_pages()
> > and swappiness is passed by argument. It's propagated by scan_control.
> > 
> > get_swappiness is static function but some planned updates will need to
> > get swappiness from files other than memcontrol.c
> > This patch exports get_swappiness() as mem_cgroup_swappiness().
> > By this, we can remove the argument of swapiness from try_to_free...
> > and drop swappiness from scan_control. only memcg uses it.
> > 
> 
> > +extern unsigned int mem_cgroup_swappiness(struct mem_cgroup *mem);
> > +unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> > +static int vmscan_swappiness(struct scan_control *sc)
> 
> The patch seems a bit confused about the signedness of swappiness.
> 

ok, v3 here. Now, memcg's one use "int" because vm_swapiness is "int".
==
