Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 6ECD86B005C
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 22:31:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C98923EE0B6
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:31:37 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A6B6D45DE52
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:31:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 90B7045DD74
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:31:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 805561DB803F
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:31:37 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 38F661DB802C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:31:37 +0900 (JST)
Message-ID: <4FFA4207.4060406@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 11:29:27 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 02/11] mm: swapfile: clean up unuse_pte race handling
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org> <1341449103-1986-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/05 9:44), Johannes Weiner wrote:
> The conditional mem_cgroup_cancel_charge_swapin() is a leftover from
> when the function would continue to reestablish the page even after
> mem_cgroup_try_charge_swapin() failed.  After 85d9fc8 "memcg: fix
> refcnt handling at swapoff", the condition is always true when this
> code is reached.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
