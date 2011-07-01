Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F346F6B004A
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 21:01:40 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 260813EE0AE
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:01:37 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 08A5445DE5D
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:01:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB3D945DE5A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:01:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CBFAC1DB8050
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:01:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 87B131DB804D
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:01:36 +0900 (JST)
Date: Fri, 1 Jul 2011 09:54:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2011-06-30-15-59 uploaded (mm/memcontrol.c)
Message-Id: <20110701095433.71c2aa18.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110701091525.bd8095f1.kamezawa.hiroyu@jp.fujitsu.com>
References: <201106302259.p5UMxh5i019162@imap1.linux-foundation.org>
	<20110630172054.49287627.randy.dunlap@oracle.com>
	<20110701091525.bd8095f1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, 1 Jul 2011 09:15:25 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 30 Jun 2011 17:20:54 -0700
> Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 
> > On Thu, 30 Jun 2011 15:59:43 -0700 akpm@linux-foundation.org wrote:
> > 
> > > The mm-of-the-moment snapshot 2011-06-30-15-59 has been uploaded to
> > > 
> > >    http://userweb.kernel.org/~akpm/mmotm/
> > > 
> > > and will soon be available at
> > >    git://zen-kernel.org/kernel/mmotm.git
> > > or
> > >    git://git.cmpxchg.org/linux-mmotm.git
> > > 
> > > It contains the following patches against 3.0-rc5:
> > 
> > I see several of these build errors:
> > 
> > mmotm-2011-0630-1559/mm/memcontrol.c:1579: error: implicit declaration of function 'mem_cgroup_node_nr_file_lru_pages'
> > mmotm-2011-0630-1559/mm/memcontrol.c:1583: error: implicit declaration of function 'mem_cgroup_node_nr_anon_lru_pages'
> > 
> 
> Thanks...maybe !CONFIG_NUMA again. will post a fix soon.
> 

fix here. compiled and booted on !CONFIG_NUMA on my host.
I think I should do total cleanup of functions in mm/memcontrol.c 
in the next week..several functions implements similar logics....
==
