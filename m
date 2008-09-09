Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m89E7kn9024606
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 19:37:46 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m89E7kre1167566
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 19:37:46 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m89E7j2f006992
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 00:07:45 +1000
Message-ID: <48C6832A.7030102@linux.vnet.ibm.com>
Date: Tue, 09 Sep 2008 07:07:38 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: memcg swappiness (Re: memo: mem+swap controller)
References: <4892B135.4090203@linux.vnet.ibm.com> <20080909091715.81D7E5AA5@siro.lan>
In-Reply-To: <20080909091715.81D7E5AA5@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com, linux-mm@kvack.org, menage@google.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
> hi,
> 
> here's the updated patch.
> 
> changes from the previous one:
> 	- adapt to v2.6.27-rc1-mm1.

I just applied it to 2.6.27-rc5-mm1 and I am beginning to test it.

> 	- implement per-cgroup per-zone recent_scanned and recent_rotated.
> 	- when creating a cgroup, inherit the swappiness value from its parent.

Looks good

> 	- fix build w/o memcg.
> 

> any comments?
> 

I'll review the patches later, but I just tested them, by running "dd" and a RSS
intensive application in the same control group. I am not seeing the desired
result. Let me debug that further.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
