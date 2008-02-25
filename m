Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1PHNLC5025401
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 04:23:21 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PHNsau1695802
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 04:23:55 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PHNs23003327
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 04:23:54 +1100
Message-ID: <47C2F86A.9010709@linux.vnet.ibm.com>
Date: Mon, 25 Feb 2008 22:48:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Memory Resource Controller Add Boot Option
References: <20080225115509.23920.66231.sendpatchset@localhost.localdomain> <20080225115550.23920.43199.sendpatchset@localhost.localdomain> <6599ad830802250816m1f83dbeekbe919a60d4b51157@mail.gmail.com>
In-Reply-To: <6599ad830802250816m1f83dbeekbe919a60d4b51157@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Feb 25, 2008 at 3:55 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>>  A boot option for the memory controller was discussed on lkml. It is a good
>>  idea to add it, since it saves memory for people who want to turn off the
>>  memory controller.
>>
>>  By default the option is on for the following two reasons
>>
>>  1. It provides compatibility with the current scheme where the memory
>>    controller turns on if the config option is enabled
>>  2. It allows for wider testing of the memory controller, once the config
>>    option is enabled
>>
>>  We still allow the create, destroy callbacks to succeed, since they are
>>  not aware of boot options. We do not populate the directory will
>>  memory resource controller specific files.
> 
> Would it make more sense to have a generic cgroups boot option for this?
> 
> Something like cgroup_disable=xxx, which would be parsed by cgroups
> and would cause:
> 
> - a "disabled" flag to be set to true in the subsys object (you could
> use this in place of the mem_cgroup_on flag)
> 

I thought about it, but it did not work out all that well. The reason being,
that the memory controller is called in from places besides cgroup.
mem_cgroup_charge_common() for example is called from several places in mm.
Calling into cgroups to check, enabled/disabled did not seem right.

Hence I put the boot option in mm/memcontrol.c

> - prevent the disabled cgroup from being bound to any mounted
> hierarchy (so it would be ignored in a mount with no subsystem
> options, and a mount with options that specifically pick that
> subsystem would give an error)
> 

The controller can be bound, but I just don't populate the files associated with
the controller

> Paul


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
