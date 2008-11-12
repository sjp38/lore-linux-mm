Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAC3qgeW024040
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 12 Nov 2008 12:52:42 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E41545DD79
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:52:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 365F845DD77
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:52:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CDE041DB803C
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:52:41 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E7291DB803A
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 12:52:41 +0900 (JST)
Date: Wed, 12 Nov 2008 12:52:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v3)
Message-Id: <20081112125204.a92816cc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081111123417.6566.52629.sendpatchset@balbir-laptop>
References: <20081111123314.6566.54133.sendpatchset@balbir-laptop>
	<20081111123417.6566.52629.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Nov 2008 18:04:17 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> +
> +		/*
> +		 * We need to give up the cgroup lock if it is held, since
> +		 * it creates the potential for deadlock. cgroup_mutex should
> +		 * be acquired after cpu_hotplug lock. In this path, we
> +		 * acquire the cpu_hotplug lock after acquiring the cgroup_mutex
> +		 * Giving it up should be OK
> +		 */
> +		if (cgroup_locked)
> +			cgroup_unlock();

nice catch. I'll post a fix to this as its own patch. 

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
