Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id mAB51K3j030310
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 10:31:20 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAB516Cs2859120
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 10:31:06 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id mAB51JUF030863
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 16:01:20 +1100
Message-ID: <4919118C.9060701@linux.vnet.ibm.com>
Date: Tue, 11 Nov 2008 10:31:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][mm] [PATCH 4/4] Memory cgroup hierarchy feature selector
 (v2)
References: <20081108091009.32236.26177.sendpatchset@localhost.localdomain> <20081108091113.32236.12390.sendpatchset@localhost.localdomain> <20081111121039.91017d3c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081111121039.91017d3c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Sat, 08 Nov 2008 14:41:13 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Don't enable multiple hierarchy support by default. This patch introduces
>> a features element that can be set to enable the nested depth hierarchy
>> feature. This feature can only be enabled when the cgroup for which the
>> feature this is enabled, has no children.
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
>>
> IMHO, permission to this is not enough.
> 
> I think following is sane way.
> ==
>    When parent->use_hierarchy==1.
> 	my->use_hierarchy must be "1" and cannot be tunrned to be "0" even if no children.
>    When parent->use_hierarchy==0
> 	my->use_hierarchy can be either of "0" or "1".
> 	this value can be chagned if we don't have children
> ==

Sounds reasonable, will fix in v3.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
