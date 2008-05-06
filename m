Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m468Foi9002389
	for <linux-mm@kvack.org>; Tue, 6 May 2008 18:15:50 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m468KeD4272152
	for <linux-mm@kvack.org>; Tue, 6 May 2008 18:20:40 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m468GbYT017568
	for <linux-mm@kvack.org>; Tue, 6 May 2008 18:16:38 +1000
Message-ID: <482013B0.5040405@linux.vnet.ibm.com>
Date: Tue, 06 May 2008 13:45:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 1/4] Setup the rlimit controller
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain> <20080503213736.3140.83278.sendpatchset@localhost.localdomain> <481FB50D.1070308@cn.fujitsu.com>
In-Reply-To: <481FB50D.1070308@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
> Balbir Singh wrote:
>> +struct cgroup_subsys rlimit_cgroup_subsys;
>> +
>> +struct rlimit_cgroup {
>> +	struct cgroup_subsys_state css;
>> +	struct res_counter as_res;	/* address space counter */
>> +};
>> +
>> +static struct rlimit_cgroup init_rlimit_cgroup;
>> +
>> +struct rlimit_cgroup *rlimit_cgroup_from_cgrp(struct cgroup *cgrp)
> 
> It can be static if I don't miss anything.

Yes, it can be. Thanks!

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
