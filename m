Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id mA67QDvx019276
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 12:57:56 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA66uWAf1499264
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 12:26:32 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id mA66uVXq007501
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 17:56:32 +1100
Message-ID: <4912951D.60301@linux.vnet.ibm.com>
Date: Thu, 06 Nov 2008 12:26:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 4/4] Memory cgroup hierarchy feature selector
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop> <20081101184902.2575.11443.sendpatchset@balbir-laptop> <20081102143817.99edca6d.kamezawa.hiroyu@jp.fujitsu.com> <490D42C7.4000301@linux.vnet.ibm.com> <20081102152412.2af29a1b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081102152412.2af29a1b.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Sun, 02 Nov 2008 11:33:51 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> On Sun, 02 Nov 2008 00:19:02 +0530
>>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>
>>>> Don't enable multiple hierarchy support by default. This patch introduces
>>>> a features element that can be set to enable the nested depth hierarchy
>>>> feature. This feature can only be enabled when there is just one cgroup
>>>> (the root cgroup).
>>>>
>>> Why the flag is for the whole system ?
>>> flag-per-subtree is of no use ?
>> Flag per subtree might not be useful, since we charge all the way up to root,
> Ah, what I said is "How about enabling/disabling hierarhcy support per subtree ?"
> Sorry for bad text.
> 
> like this.
>   - you can set hierarchy mode of a cgroup turned on/off when...
>     * you don't have any tasks under it && it doesn't have any child cgroup.

I see.. the presence of tasks don't matter, since the root cgroup will always
have tasks. Presence of child groups does matter.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
