Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4N4pwTt019186
	for <linux-mm@kvack.org>; Fri, 23 May 2008 10:21:58 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4N4pk3D1302658
	for <linux-mm@kvack.org>; Fri, 23 May 2008 10:21:46 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4N4pgfQ019772
	for <linux-mm@kvack.org>; Fri, 23 May 2008 10:21:42 +0530
Message-ID: <48364D38.7000304@linux.vnet.ibm.com>
Date: Fri, 23 May 2008 10:21:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] swapcgroup(v2)
References: <20080523121027.b0eecfa0.kamezawa.hiroyu@jp.fujitsu.com> <4836411B.2030601@linux.vnet.ibm.com> <20080523131812.84F1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080523131812.84F1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>> One option is to limit the virtual address space usage of the cgroup to ensure
>> that swap usage of a cgroup will *not* exceed the specified limit. Along with a
>> good swap controller, it should provide good control over the cgroup's memory usage.
> 
> unfortunately, it doesn't works in real world.
> IMHO you said as old good age.
> 
> because, Some JavaVM consume crazy large virtual address space.
> it often consume >10x than phycal memory consumption.
> 

Have you seen any real world example of this? The overcommit feature of Linux.
We usually by default limit the overcommit to 1.5 times total memory (IIRC).
Yes, one can override that value, you get the same flexibility with the virtual
address space controller.

I thought java was particular about it with it's heap management options and policy.

> yes, that behaviour is crazy. but it is used widely.
> thus, We shouldn't assume virtual address space limitation.

It's useful in many cases to limit the virtual address space - to allow
applications to deal with memory failure, rather than

1. OOM the application later
2. Allow uncontrolled swapping (swap controller would help here)

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
