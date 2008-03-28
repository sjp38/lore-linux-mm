Date: Fri, 28 Mar 2008 20:21:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
Message-Id: <20080328202144.5c627380.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080328201528.55b22fba.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain>
	<20080328195516.494edde3.kamezawa.hiroyu@jp.fujitsu.com>
	<47ECCE00.70803@linux.vnet.ibm.com>
	<20080328201528.55b22fba.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Mar 2008 20:15:28 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Now,
> - css_get(memcgrp) is called at mm_struct initialization.
> - css_put(memcgrp) is called at mm_struct freeing.
> 
> How about
> - css_get(memcgrp) is called at task_struct initialization.
> - css_put(memcgrp) is called at task_struct freeing.
> 
> Because
> 1. we find mem_cgroup by mm->owner, after this.
> 2. generic group interface have exit() and clone() callback interface.
> 
> mem_cgroup will not be freed until rmdir(), anyway.
> 
Ignore above. As Paul pointed out, reference count from task is not necessary.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
