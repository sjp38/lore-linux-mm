Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C4F8362001F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 14:53:43 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id o2HIrXkL015369
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 00:23:33 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2HIrXpO2805934
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 00:23:33 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2HIrW2Y026926
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 05:53:33 +1100
Date: Thu, 18 Mar 2010 00:23:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v7)
Message-ID: <20100317185327.GV18054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
 <20100315171209.GI21127@redhat.com>
 <20100315171921.GJ21127@redhat.com>
 <20100317115427.GR18054@balbir.in.ibm.com>
 <20100317133407.GA9198@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100317133407.GA9198@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Vivek Goyal <vgoyal@redhat.com> [2010-03-17 09:34:07]:

> > > 
> > > root cgroup
> > > ==========
> > > #time dd if=/dev/zero of=/root/zerofile bs=4K count=1M
> > > 4294967296 bytes (4.3 GB) copied, 56.098 s, 76.6 MB/s
> > > 
> > > real	0m56.614s
> > > 
> > > test1 cgroup with memory limit 100M
> > > ===================================
> > > # time dd if=/dev/zero of=/root/zerofile1 bs=4K count=1M
> > > 4294967296 bytes (4.3 GB) copied, 19.8097 s, 217 MB/s
> > > 
> > > real	0m19.992s
> > > 
> > 
> > This is strange, did you flish the cache between the two runs?
> > NOTE: Since the files are same, we reuse page cache from the
> > other cgroup.
> 
> Files are different. Note suffix "1".
>

Thanks, I'll get the perf output and see what I get. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
