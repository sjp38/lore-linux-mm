Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0A46B0027
	for <linux-mm@kvack.org>; Thu, 19 May 2011 04:02:14 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id p4J7uuWs010397
	for <linux-mm@kvack.org>; Thu, 19 May 2011 17:56:56 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4J822vj1228986
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:02:04 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4J821rQ019732
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:02:02 +1000
Date: Thu, 19 May 2011 00:02:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem
 fix
Message-ID: <20110518183212.GD3139@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

* Hugh Dickins <hughd@google.com> [2011-05-17 11:24:40]:

> mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
> target mm, not for current mm (but of course they're usually the same).
> 
> We don't know the target mm in shmem_getpage(), so do it at the outer
> level in shmem_fault(); and it's easier to follow if we move the
> count_vm_event(PGMAJFAULT) there too.
> 
> Hah, it was using __count_vm_event() before, sneaking that update into
> the unpreemptible section under info->lock: well, it comes to the same
> on x86 at least, and I still think it's best to keep these together.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

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
