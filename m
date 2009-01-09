Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CDB3D6B0044
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 01:01:13 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n09617F9031300
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 11:31:07 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n095xQ4Z4112590
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 11:29:26 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n09617px023593
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 17:01:07 +1100
Date: Fri, 9 Jan 2009 11:31:09 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/4] memcg: fix error path of
	mem_cgroup_move_parent
Message-ID: <20090109060109.GG9737@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp> <20090108191445.cd860c37.nishimura@mxp.nes.nec.co.jp> <20090109051522.GC9737@balbir.in.ibm.com> <20090109143346.5ad2b971.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090109143346.5ad2b971.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2009-01-09 14:33:46]:

> > Looks good to me, just out of curiousity how did you catch this error?
> > Through review or testing? 
> > 
> Through testing.
> 
> I got "an unremovable directory" sometimes, which had res.usage remained
> even after all lru lists had become empty, or which had ref counts remained
> even after res.usage had become 0.
> And tracked down the cause of this problem .
>

Thanks,

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
