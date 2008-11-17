Message-ID: <4920C395.1000208@cn.fujitsu.com>
Date: Mon, 17 Nov 2008 09:06:29 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 1/4] Memory cgroup hierarchy documentation (v4)
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop> <20081116081040.25166.65142.sendpatchset@balbir-laptop>
In-Reply-To: <20081116081040.25166.65142.sendpatchset@balbir-laptop>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> +6.1 Enabling hierarchical accounting and reclaim
> +
> +The memory controller by default disables the hierarchy feature. Support
> +can be enabled by writing 1 to memory.use_hierarchy file of the root cgroup
> +
> +# echo 1 > memory.use_hierarchy
> +
> +The feature can be disabled by
> +
> +# echo 0 > memory.use_hierarchy
> +
> +NOTE1: Enabling/disabling will fail if the cgroup already has other
> +cgroups created below it.
> +

It's better to also document that it will fail if it's parent's use_hierarchy
is already enabled.

> +NOTE2: This feature can be enabled/disabled per subtree.
> +
> +7. TODO
>  
>  1. Add support for accounting huge pages (as a separate controller)
>  2. Make per-cgroup scanner reclaim not-shared pages first
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
