Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAC6NPK9019141
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 17:23:25 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAC6N4uv4006070
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 17:23:04 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAC6Mt06015543
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 17:22:55 +1100
Message-ID: <491A7637.3050402@linux.vnet.ibm.com>
Date: Wed, 12 Nov 2008 11:52:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v3)
References: <20081111123314.6566.54133.sendpatchset@balbir-laptop> <20081111123417.6566.52629.sendpatchset@balbir-laptop> <20081112140236.46448b47.kamezawa.hiroyu@jp.fujitsu.com> <491A6E71.5010307@linux.vnet.ibm.com> <20081112150126.46ac6042.kamezawa.hiroyu@jp.fujitsu.com> <491A7345.4090500@linux.vnet.ibm.com> <20081112151233.0ec8dc44.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112151233.0ec8dc44.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 12 Nov 2008 11:40:13 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> I think of it as easy to update - as in the modularity, you can plug out
>> hierarchical reclaim easily and implement your own hierarchical reclaim.
>>
> When I do so, I'll rewrite all, again.
> 

I don't intend to ask you to rewrite it, rewrite all, I meant you as in a
generic person. With hierarchy we will need weighted reclaim, which I'll add in
later.

>>> Can you make this code iterative rather than recursive ?
>>>
>>> I don't like this kind of recursive call with complexed lock/unlock.
>> I tried an iterative version, which ended up looking very ugly. I think the
>> recursive version is easier to understand. What we do is a DFS walk - pretty
>> standard algorithm.
>>
> But recursive one is not good for search-and-try algorithm.

OK, I'll post the iterative algorithm, but it is going to be dirty :)

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
