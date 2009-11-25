Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 262956B0083
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 23:10:30 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id nAP46QjE014771
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 15:06:26 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAP49ctr1601666
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 15:09:38 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAP49bgX013828
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 15:09:38 +1100
Date: Wed, 25 Nov 2009 09:39:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH -mmotm] memcg: avoid oom-killing innocent task
	in case of use_hierarchy
Message-ID: <20091125040933.GE3365@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, stable <stable@kernel.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-24 14:57:59]:

> task_in_mem_cgroup(), which is called by select_bad_process() to check whether
> a task can be a candidate for being oom-killed from memcg's limit, checks
> "curr->use_hierarchy"("curr" is the mem_cgroup the task belongs to).
> 
> But this check return true(it's false positive) when:
> 
> 	<some path>/00		use_hierarchy == 0	<- hitting limit
> 	  <some path>/00/aa	use_hierarchy == 1	<- "curr"
> 
> This leads to killing an innocent task in 00/aa. This patch is a fix for this
> bug. And this patch also fixes the arg for mem_cgroup_print_oom_info(). We
> should print information of mem_cgroup which the task being killed, not current,
> belongs to.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>


Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
