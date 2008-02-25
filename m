Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1PHgDpi010381
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 04:42:13 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PHgPYp3227776
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 04:42:25 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PHgOpN020771
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 04:42:25 +1100
Message-ID: <47C2FCC1.7090203@linux.vnet.ibm.com>
Date: Mon, 25 Feb 2008 23:07:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Memory Resource Controller Add Boot Option
References: <20080225115509.23920.66231.sendpatchset@localhost.localdomain> <20080225115550.23920.43199.sendpatchset@localhost.localdomain> <6599ad830802250816m1f83dbeekbe919a60d4b51157@mail.gmail.com> <47C2F86A.9010709@linux.vnet.ibm.com> <6599ad830802250932s5eaa3bcchbfc49fe0e76d3f7d@mail.gmail.com>
In-Reply-To: <6599ad830802250932s5eaa3bcchbfc49fe0e76d3f7d@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Feb 25, 2008 at 9:18 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  I thought about it, but it did not work out all that well. The reason being,
>>  that the memory controller is called in from places besides cgroup.
>>  mem_cgroup_charge_common() for example is called from several places in mm.
>>  Calling into cgroups to check, enabled/disabled did not seem right.
> 
> You wouldn't need to call into cgroups - if it's a flag in the subsys
> object (which is defined in memcontrol.c) you'd just say
> 
> if (mem_cgroup_subsys.disabled) {
> ...
> }
> 
> I'll send out a prototype for comment.

Sure thing, if css has the flag, then it would nice. Could you wrap it up to say
something like css_disabled(&mem_cgroup_subsys)


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
