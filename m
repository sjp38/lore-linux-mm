Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2H3DCAb002305
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 14:13:12 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2H3HMnT276940
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 14:17:22 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2H3Db7X007224
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 14:13:38 +1100
Message-ID: <47DDE187.70109@linux.vnet.ibm.com>
Date: Mon, 17 Mar 2008 08:42:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][0/3] Virtual address space control for cgroups
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain> <6599ad830803161626q1fcf261bta52933bb5e7a6bdd@mail.gmail.com> <47DDCE5E.9020104@linux.vnet.ibm.com> <6599ad830803161855y1ceb8aa8t2f486434b521bd81@mail.gmail.com>
In-Reply-To: <6599ad830803161855y1ceb8aa8t2f486434b521bd81@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Mar 17, 2008 at 9:50 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  I am yet to measure the performance overhead of the accounting checks. I'll try
>>  and get started on that today. I did not consider making it a separate system,
>>  because I suspect that anybody wanting memory control would also want address
>>  space control (for the advantages listed in the documentation).
> 
> I'm a counter-example to your suspicion :-)
> 
> Trying to control virtual address space is a complete nightmare in the
> presence of anything that uses large sparsely-populated mappings
> (mmaps of large files, or large sparse heaps such as the JVM uses.)
> 

Not really. Virtual limits are more gentle than an OOM kill that can occur if
the cgroup runs out of memory. Please also see
http://linux-vserver.org/Memory_Limits

> If we want to control the effect of swapping, the right way to do it
> is to control disk I/O, and ensure that the swapping is accounted to
> that. Or simply just not give apps much swap space.

Yes, a disk I/O and swap I/O controller are being developed (not by us, but
others in the community). How does one restrict swap space for a particular
application? I can think of RLIMIT_AS for a process and something similar to
what I've posted for cgroups. Not enabling swap is an option, but not very
practical IMHO.

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
