Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA40FiT7009347
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 4 Nov 2008 09:15:44 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AA7A45DD7B
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 09:15:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3401545DD7A
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 09:15:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 173331DB803F
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 09:15:44 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C70FA1DB803A
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 09:15:43 +0900 (JST)
Date: Tue, 4 Nov 2008 09:15:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mm][PATCH 0/4] Memory cgroup hierarchy introduction
Message-Id: <20081104091510.01cf3a1e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081101184812.2575.68112.sendpatchset@balbir-laptop>
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 02 Nov 2008 00:18:12 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> This patch follows several iterations of the memory controller hierarchy
> patches. The hardwall approach by Kamezawa-San[1]. Version 1 of this patchset
> at [2].
> 
> The current approach is based on [2] and has the following properties
> 
> 1. Hierarchies are very natural in a filesystem like the cgroup filesystem.
>    A multi-tree hierarchy has been supported for a long time in filesystems.
>    When the feature is turned on, we honor hierarchies such that the root
>    accounts for resource usage of all children and limits can be set at
>    any point in the hierarchy. Any memory cgroup is limited by limits
>    along the hierarchy. The total usage of all children of a node cannot
>    exceed the limit of the node.
> 2. The hierarchy feature is selectable and off by default
> 3. Hierarchies are expensive and the trade off is depth versus performance.
>    Hierarchies can also be completely turned off.
> 
> The patches are against 2.6.28-rc2-mm1 and were tested in a KVM instance
> with SMP and swap turned on.
> 

As first impression, I think hierarchical LRU management is not good...means
not fair from viewpoint of memory management.
I'd like to show some other possible implementation of
try_to_free_mem_cgroup_pages() if I can.

Anyway, I have to merge this with mem+swap controller. 

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
