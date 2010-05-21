Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AD2476B01B1
	for <linux-mm@kvack.org>; Thu, 20 May 2010 21:43:32 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4L1hCsq004439
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 21 May 2010 10:43:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D6BE645DE55
	for <linux-mm@kvack.org>; Fri, 21 May 2010 10:43:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B498545DE51
	for <linux-mm@kvack.org>; Fri, 21 May 2010 10:43:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D33AE08003
	for <linux-mm@kvack.org>; Fri, 21 May 2010 10:43:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5995CE08001
	for <linux-mm@kvack.org>; Fri, 21 May 2010 10:43:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at first
In-Reply-To: <alpine.DEB.1.00.1005201822120.19421@tigran.mtv.corp.google.com>
References: <20100519174327.9591.A69D9226@jp.fujitsu.com> <alpine.DEB.1.00.1005201822120.19421@tigran.mtv.corp.google.com>
Message-Id: <20100521103935.1E56.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 21 May 2010 10:43:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

> Acked-by: Hugh Dickins <hughd@google.com>
> 
> Thanks - though I don't quite agree with your description: I can't
> see why the lru_cache_add_active_anon() was ever justified - that
> "active" came in along with the separate anon and file LRU lists.

If you have any worry, can you please share it? I'll test such workload
and fix the issue if necessary. You are expert than me in this area.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
