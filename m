Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m5PNpO8s015064
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 09:51:24 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5PNpDLk4579478
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 09:51:13 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5PNpafn012589
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 09:51:37 +1000
Message-ID: <4862DA05.7000902@linux.vnet.ibm.com>
Date: Thu, 26 Jun 2008 05:21:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [2/2] memrlimit fix usage of tmp as a parameter name
References: <20080620150132.16094.29151.sendpatchset@localhost.localdomain> <20080620150152.16094.76790.sendpatchset@localhost.localdomain> <20080625164121.9146fb56.akpm@linux-foundation.org>
In-Reply-To: <20080625164121.9146fb56.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: yamamoto@valinux.co.jp, menage@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 20 Jun 2008 20:31:52 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Fix the variable tmp being used in write_strategy. This patch replaces tmp
>> with val, the fact that it is an output parameter can be interpreted from
>> the pass by reference.
> 
> Paul's "CGroup Files: Convert res_counter_write() to be a cgroups
> write_string() handler"
> (memrlimit-setup-the-memrlimit-controller-cgroup-files-convert-res_counter_write-to-be-a-cgroups-write_string-handler-memrlimitcgroup.patch)
> deleted memrlimit_cgroup_write_strategy(), so problem solved ;)

Yes, I remember reviewing those patches. Nice to have problems solved
automatically :)

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
