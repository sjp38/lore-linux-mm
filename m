Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 121CA6B0062
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 22:51:29 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 780203EE0BD
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:51:27 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5204A45DE59
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:51:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2866A45DE53
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:51:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA77B1DB8043
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:51:26 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F48B1DB8041
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:51:26 +0900 (JST)
Message-ID: <4FFA46A4.20309@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 11:49:08 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 05/11] mm: memcg: only check for PageSwapCache when uncharging
 anon
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org> <1341449103-1986-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-6-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/05 9:44), Johannes Weiner wrote:
> Only anon pages that are uncharged at the time of the last page table
> mapping vanishing may be in swapcache.
> 
> When shmem pages, file pages, swap-freed anon pages, or just migrated
> pages are uncharged, they are known for sure to be not in swapcache.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
