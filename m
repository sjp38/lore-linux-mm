Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 051726B006E
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 23:46:53 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C3C2C3EE0AE
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 12:46:51 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AA90345DE51
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 12:46:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9146245DE4E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 12:46:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 82CF21DB802F
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 12:46:51 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3797B1DB8037
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 12:46:51 +0900 (JST)
Message-ID: <4FFA539E.70805@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 12:44:30 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 11/11] mm: memcg: only check anon swapin page charges
 for swap cache
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org> <1341449103-1986-12-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-12-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/05 9:45), Johannes Weiner wrote:
> shmem knows for sure that the page is in swap cache when attempting to
> charge a page, because the cache charge entry function has a check for
> it.  Only anon pages may be removed from swap cache already when
> trying to charge their swapin.
> 
> Adjust the comment, though: '4969c11 mm: fix swapin race condition'
> added a stable PageSwapCache check under the page lock in the
> do_swap_page() before calling the memory controller, so it's
> unuse_pte()'s pte_same() that may fail.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
