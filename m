Date: Wed, 27 Feb 2008 08:41:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 04/15] memcg: when do_swap's do_wp_page fails
Message-Id: <20080227084156.fca91c86.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802252337110.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252337110.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:38:02 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Don't uncharge when do_swap_page's call to do_wp_page fails: the page which
> was charged for is there in the pagetable, and will be correctly uncharged
> when that area is unmapped - it was only its COWing which failed.
> 
> And while we're here, remove earlier XXX comment: yes, OR in do_wp_page's
> return value (maybe VM_FAULT_WRITE) with do_swap_page's there; but if it
> fails, mask out success bits, which might confuse some arches e.g. sparc.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
