Date: Tue, 26 Feb 2008 10:34:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 08/15] memcg: remove mem_cgroup_uncharge
Message-Id: <20080226103443.f0c022c2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802252341250.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252341250.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:42:05 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Nothing uses mem_cgroup_uncharge apart from mem_cgroup_uncharge_page,
> (a trivial wrapper around it) and mem_cgroup_end_migration (which does
> the same as mem_cgroup_uncharge_page).  And it often ends up having to
> lock just to let its caller unlock.  Remove it (but leave the silly
> locking until a later patch).
> 
> Moved mem_cgroup_cache_charge next to mem_cgroup_charge in memcontrol.h.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Hmm, ok.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
