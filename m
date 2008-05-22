Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4MAEsqR003238
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:44:54 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4MAEgFV1384696
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:44:42 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4MAEKBZ022698
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:44:20 +0530
Message-ID: <4835476A.3020506@linux.vnet.ibm.com>
Date: Thu, 22 May 2008 15:44:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 2/4] Setup the memrlimit controller (v5)
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain> <20080521152948.15001.39361.sendpatchset@localhost.localdomain> <20080521211833.bc7c5255.akpm@linux-foundation.org>
In-Reply-To: <20080521211833.bc7c5255.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 21 May 2008 20:59:48 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> +static int memrlimit_cgroup_write_strategy(char *buf, unsigned long long *tmp)
> 
> grumble.  I think I requested a checkpatch warning whenever it comes
> across "tmp" or "temp".  Even better would be a gcc coredump.
> 

:-)

> I'm sure there's something more meaningful we could use here?

I'll send a patch to fix this.


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
