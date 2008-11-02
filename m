Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id mA262u1c002340
	for <linux-mm@kvack.org>; Sun, 2 Nov 2008 17:02:56 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA263ubd2363552
	for <linux-mm@kvack.org>; Sun, 2 Nov 2008 17:03:56 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA263tWg016319
	for <linux-mm@kvack.org>; Sun, 2 Nov 2008 17:03:55 +1100
Message-ID: <490D42C7.4000301@linux.vnet.ibm.com>
Date: Sun, 02 Nov 2008 11:33:51 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 4/4] Memory cgroup hierarchy feature selector
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop> <20081101184902.2575.11443.sendpatchset@balbir-laptop> <20081102143817.99edca6d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081102143817.99edca6d.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Sun, 02 Nov 2008 00:19:02 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Don't enable multiple hierarchy support by default. This patch introduces
>> a features element that can be set to enable the nested depth hierarchy
>> feature. This feature can only be enabled when there is just one cgroup
>> (the root cgroup).
>>
> Why the flag is for the whole system ?
> flag-per-subtree is of no use ?

Flag per subtree might not be useful, since we charge all the way up to root,
which means that all subtrees have the root cgroup and hence the global flag.

Thanks for the comments,

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
