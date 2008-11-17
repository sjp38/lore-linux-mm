Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAH3b9AS031284
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 14:37:09 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAH3c8Ui2871416
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 14:38:09 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAH3btKr006257
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 14:37:56 +1100
Message-ID: <4920E70C.3020507@linux.vnet.ibm.com>
Date: Mon, 17 Nov 2008 09:07:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 1/4] Memory cgroup hierarchy documentation (v4)
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop> <20081116081040.25166.65142.sendpatchset@balbir-laptop> <4920C395.1000208@cn.fujitsu.com>
In-Reply-To: <4920C395.1000208@cn.fujitsu.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
>> +6.1 Enabling hierarchical accounting and reclaim
>> +
>> +The memory controller by default disables the hierarchy feature. Support
>> +can be enabled by writing 1 to memory.use_hierarchy file of the root cgroup
>> +
>> +# echo 1 > memory.use_hierarchy
>> +
>> +The feature can be disabled by
>> +
>> +# echo 0 > memory.use_hierarchy
>> +
>> +NOTE1: Enabling/disabling will fail if the cgroup already has other
>> +cgroups created below it.
>> +
> 
> It's better to also document that it will fail if it's parent's use_hierarchy
> is already enabled.
> 

Good point, will update the documentation.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
