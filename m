Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAB4qOMS001083
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 15:52:24 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAB4rA28314034
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 15:53:10 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAB4r9nX013141
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 15:53:10 +1100
Message-ID: <49190FA3.3040003@linux.vnet.ibm.com>
Date: Tue, 11 Nov 2008 10:22:51 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][mm] [PATCH 2/4] Memory cgroup resource counters for hierarchy
 (v2)
References: <20081108091009.32236.26177.sendpatchset@localhost.localdomain> <20081108091047.32236.22994.sendpatchset@localhost.localdomain> <20081111120427.bbb64a44.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081111120427.bbb64a44.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Sat, 08 Nov 2008 14:40:47 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Add support for building hierarchies in resource counters. Cgroups allows us
>> to build a deep hierarchy, but we currently don't link the resource counters
>> belonging to the memory controller control groups, in the same fashion
>> as the corresponding cgroup entries in the cgroup hierarchy. This patch
>> provides the infrastructure for resource counters that have the same hiearchy
>> as their cgroup counter parts.
>>
>> These set of patches are based on the resource counter hiearchy patches posted
>> by Pavel Emelianov.
>>
>> NOTE: Building hiearchies is expensive, deeper hierarchies imply charging
>> the all the way up to the root. It is known that hiearchies are expensive,
>> so the user needs to be careful and aware of the trade-offs before creating
>> very deep ones.
>>
> Do you have numbers ?
> 

I am getting those numbers, I'll post them soon.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
