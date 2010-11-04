Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id ABE6D6B00C5
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 16:35:08 -0400 (EDT)
Received: by gyd8 with SMTP id 8so1461602gyd.14
        for <linux-mm@kvack.org>; Thu, 04 Nov 2010 13:35:06 -0700 (PDT)
Message-ID: <4CD318F7.8050503@gmail.com>
Date: Fri, 05 Nov 2010 04:35:03 +0800
From: Li Zefan <lizf.kern@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] cgroup: prefer [kv]zalloc[_node] over [kv]malloc+memset
 in memory controller code.
References: <alpine.LNX.2.00.1011042104140.15349@swampdragon.chaosbits.net>
In-Reply-To: <alpine.LNX.2.00.1011042104140.15349@swampdragon.chaosbits.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, containers@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> In mem_cgroup_alloc() we currently do either kmalloc() or vmalloc() then 
> followed by memset() to zero the memory. This can be more efficiently 
> achieved by using kzalloc() and vzalloc().
> There's also one situation where we can use kzalloc_node() - this is 
> what's new in this version of the patch.
> 
> The original patch was:
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>
> Here's version 2. I'd appreciate it if someone could merge it, but I don't 
> know who that someone would be.
> 

Normally it's Andrew Morton.

btw, a better title is: [...] memcgroup: prefer ... over ... memset

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
