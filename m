Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1J8g0kD009086
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 19:42:00 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1J8gEce4493522
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 19:42:14 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1J8gDlZ028480
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 19:42:14 +1100
Message-ID: <47BA9573.1090703@linux.vnet.ibm.com>
Date: Tue, 19 Feb 2008 14:08:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 2/4] Add the soft limit interface v2
References: <20080219070232.25349.21196.sendpatchset@localhost.localdomain> <20080219070258.25349.25994.sendpatchset@localhost.localdomain> <47BA8665.3080302@cn.fujitsu.com> <47BA8864.7080803@cn.fujitsu.com>
In-Reply-To: <47BA8864.7080803@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Herbert Poetzl <herbert@13thfloor.at>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik Van Riel <riel@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
> Li Zefan a??e??:
>> Balbir Singh wrote:
>>> A new configuration file called soft_limit_in_bytes is added. The parsing
>>> and configuration rules remain the same as for the limit_in_bytes user
>>> interface.
>>>
>>> A global list of all memory cgroups over their soft limit is maintained.
>>> This list is then used to reclaim memory on global pressure. A cgroup is
>>> removed from the list when the cgroup is deleted.
>>>
>>> The global list is protected with a read-write spinlock.
>>>
>> You are not using read-write spinlock..
>>
> 
> Ah, the spinlock is changed to r/w spinlock in [PATCH 3/4].
> 

Yes, I'll fix that as well in v3. Thanks for spotting it.

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
