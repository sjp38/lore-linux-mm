Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAC41xm4016642
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:01:59 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAC40uQE2125834
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:00:56 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAC40lYF023354
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:00:47 +1100
Message-ID: <491A54EB.3020500@linux.vnet.ibm.com>
Date: Wed, 12 Nov 2008 09:30:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v3)
References: <20081111123314.6566.54133.sendpatchset@balbir-laptop> <20081111123417.6566.52629.sendpatchset@balbir-laptop> <20081112125204.a92816cc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112125204.a92816cc.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 11 Nov 2008 18:04:17 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> +
>> +		/*
>> +		 * We need to give up the cgroup lock if it is held, since
>> +		 * it creates the potential for deadlock. cgroup_mutex should
>> +		 * be acquired after cpu_hotplug lock. In this path, we
>> +		 * acquire the cpu_hotplug lock after acquiring the cgroup_mutex
>> +		 * Giving it up should be OK
>> +		 */
>> +		if (cgroup_locked)
>> +			cgroup_unlock();
> 
> nice catch. I'll post a fix to this as its own patch. 

Sure, feel free to add my signed-off-by on it.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
