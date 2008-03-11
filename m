Date: Mon, 10 Mar 2008 21:41:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Move memory controller allocations to their own slabs
Message-Id: <20080310214100.d7fe7904.akpm@linux-foundation.org>
In-Reply-To: <20080311043149.20251.50059.sendpatchset@localhost.localdomain>
References: <20080311043149.20251.50059.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Mar 2008 10:01:49 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> 
> Move the memory controller data structures page_cgroup and
> mem_cgroup_per_zone to their own slab caches. It saves space on the system,
> allocations are not necessarily pushed to order of 2 and should provide
> performance benefits.

eh?  Those structures are tiny.  Which slab allocator has gone and used an
order-2 allocation and for which structure did it (stupidly) do this?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
