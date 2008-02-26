Date: Wed, 27 Feb 2008 08:44:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 06/15] memcg: bad page if page_cgroup when free
Message-Id: <20080227084406.2c78c377.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802252339310.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252339310.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:40:14 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Replace free_hot_cold_page's VM_BUG_ON(page_get_page_cgroup(page)) by a
> "Bad page state" and clear: most users don't have CONFIG_DEBUG_VM on, and
> if it were set here, it'd likely cause corruption when the page is reused.
> 
> Don't use page_assign_page_cgroup to clear it: that should be private to
> memcontrol.c, and always called with the lock taken; and memmap_init_zone
> doesn't need it either - like page->mapping and other pointers throughout
> the kernel, Linux assumes pointers in zeroed structures are NULL pointers.
> 
> Instead use page_reset_bad_cgroup, added to memcontrol.h for this only.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
Seems reasonable

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
