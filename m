Date: Tue, 26 Feb 2008 10:38:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 11/15] memcg: remove clear_page_cgroup and atomics
Message-Id: <20080226103819.84ec7c3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802252344500.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252344500.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:46:22 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Remove clear_page_cgroup: it's an unhelpful helper, see for example how
> mem_cgroup_uncharge_page had to unlock_page_cgroup just in order to call
> it (serious races from that? I'm not sure).
> 
> Once that's gone, you can see it's pointless for page_cgroup's ref_cnt
> to be atomic: it's always manipulated under lock_page_cgroup, except
> where force_empty unilaterally reset it to 0 (and how does uncharge's
> atomic_dec_and_test protect against that?).
> 
> Simplify this page_cgroup locking: if you've got the lock and the pc
> is attached, then the ref_cnt must be positive: VM_BUG_ONs to check
> that, and to check that pc->page matches page (we're on the way to
> finding why sometimes it doesn't, but this patch doesn't fix that).
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
O.K.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
