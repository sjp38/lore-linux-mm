Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4N6kDG9008983
	for <linux-mm@kvack.org>; Fri, 23 May 2008 12:16:13 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4N6k1jN1298436
	for <linux-mm@kvack.org>; Fri, 23 May 2008 12:16:01 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4N6kDnB021596
	for <linux-mm@kvack.org>; Fri, 23 May 2008 12:16:13 +0530
Message-ID: <483667FB.1030702@linux.vnet.ibm.com>
Date: Fri, 23 May 2008 12:15:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] swapcgroup(v2)
References: <48364D38.7000304@linux.vnet.ibm.com> <4836563B.4060603@anu.edu.au> <20080523145947.84F4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080523145947.84F4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David.Singleton@anu.edu.au, Rik van Riel <riel@redhat.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux MM <linux-mm@kvack.org>, Linux Containers <containers@lists.osdl.org>, Hugh Dickins <hugh@veritas.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>>> Have you seen any real world example of this? 
>> At the unsophisticated end, there are lots of (Fortran) HPC applications
>> with very large static array declarations but only "use" a small fraction
>> of that.  Those users know they only need a small fraction and are happy
>> to volunteer small physical memory limits that we (admins/queuing
>> systems) can apply.
>>
>> At the sophisticated end, the use of numerous large memory maps in
>> parallel HPC applications to gain visibility into other processes is
>> growing.  We have processes with VSZ > 400GB just because they have
>> 4GB maps into 127 other processes.  Their physical page use is of
>> the order 2GB.
> 
> Ah, agreed.
> Fujitsu HPC user said similar things ago.

OK, so this use case is HPC specific. I am not against the swap controller, but
overcommit can lead to problems if not controlled - such as OOM kill. The
virtual address space limit helps applications fail gracefully rather than swap
out excessively or OOM.

I suspect there'll be applications that swing both ways.

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
