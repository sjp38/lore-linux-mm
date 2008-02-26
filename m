Date: Tue, 26 Feb 2008 10:32:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 07/15] memcg: mem_cgroup_charge never NULL
Message-Id: <20080226103235.afe4d2f8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802252340210.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252340210.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:41:17 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> My memcgroup patch to fix hang with shmem/tmpfs added NULL page handling
> to mem_cgroup_charge_common.  It seemed convenient at the time, but hard
> to justify now: there's a perfectly appropriate swappage to charge and
> uncharge instead, this is not on any hot path through shmem_getpage,
> and no performance hit was observed from the slight extra overhead.
> 
> So revert that NULL page handling from mem_cgroup_charge_common; and
> make it clearer by bringing page_cgroup_assign_new_page_cgroup into its
> body - that was a helper I found more of a hindrance to understanding.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
This is welcome.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
