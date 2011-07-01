Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6E67C6B004A
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 20:22:33 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5D6D73EE0B5
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 09:22:29 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 007EE45DE8F
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 09:22:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CEE4045DE87
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 09:22:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BC1F51DB8044
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 09:22:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 79E601DB802C
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 09:22:28 +0900 (JST)
Date: Fri, 1 Jul 2011 09:15:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2011-06-30-15-59 uploaded (mm/memcontrol.c)
Message-Id: <20110701091525.bd8095f1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110630172054.49287627.randy.dunlap@oracle.com>
References: <201106302259.p5UMxh5i019162@imap1.linux-foundation.org>
	<20110630172054.49287627.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, 30 Jun 2011 17:20:54 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Thu, 30 Jun 2011 15:59:43 -0700 akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2011-06-30-15-59 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > and will soon be available at
> >    git://zen-kernel.org/kernel/mmotm.git
> > or
> >    git://git.cmpxchg.org/linux-mmotm.git
> > 
> > It contains the following patches against 3.0-rc5:
> 
> I see several of these build errors:
> 
> mmotm-2011-0630-1559/mm/memcontrol.c:1579: error: implicit declaration of function 'mem_cgroup_node_nr_file_lru_pages'
> mmotm-2011-0630-1559/mm/memcontrol.c:1583: error: implicit declaration of function 'mem_cgroup_node_nr_anon_lru_pages'
> 

Thanks...maybe !CONFIG_NUMA again. will post a fix soon.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
