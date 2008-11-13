Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id mADDW6CB003933
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 00:32:06 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mADDXVkW089052
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 00:33:31 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mADDXUd9001806
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 00:33:31 +1100
Message-ID: <491C2CA3.1070903@linux.vnet.ibm.com>
Date: Thu, 13 Nov 2008 19:03:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v3)
References: <20081111123314.6566.54133.sendpatchset@balbir-laptop> <20081111123417.6566.52629.sendpatchset@balbir-laptop> <20081112140236.46448b47.kamezawa.hiroyu@jp.fujitsu.com> <491A6E71.5010307@linux.vnet.ibm.com> <20081112150126.46ac6042.kamezawa.hiroyu@jp.fujitsu.com> <491A7345.4090500@linux.vnet.ibm.com> <20081112151233.0ec8dc44.kamezawa.hiroyu@jp.fujitsu.com> <491A7637.3050402@linux.vnet.ibm.com> <20081112153314.a7162192.kamezawa.hiroyu@jp.fujitsu.com> <20081112112141.GA25386@balbir.in.ibm.com> <20081113131807.b2f22261.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081113131807.b2f22261.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 12 Nov 2008 16:51:41 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> 
>> Here is the iterative version of this patch. I tested it in my
>> test environment. NOTE: The cgroup_locked check is still present, I'll
>> remove that shortly after your patch is accepted.
>>
>> This patch introduces hierarchical reclaim. When an ancestor goes over its
>> limit, the charging routine points to the parent that is above its limit.
>> The reclaim process then starts from the last scanned child of the ancestor
>> and reclaims until the ancestor goes below its limit.
>>
> 
> complicated as you said but it seems it's from style.
> 
> I expected following kind of one.

Thanks, it looks very similar to what I have, I like the split of the iterator,
start token and next token. I'll refactor the code based on your suggestion if
possible in the next version.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
