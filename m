Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 9E20B6B0062
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 22:45:43 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B962B3EE0C5
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 11:45:41 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DDB145DE53
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 11:45:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 856E045DE4F
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 11:45:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 73EA7E18005
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 11:45:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 23A24E18001
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 11:45:41 +0900 (JST)
Message-ID: <4FDE95CA.80809@jp.fujitsu.com>
Date: Mon, 18 Jun 2012 11:43:22 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] mm: memcg set soft_limit_in_bytes to 0 by default
References: <1339007023-10467-1-git-send-email-yinghan@google.com>
In-Reply-To: <1339007023-10467-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

(2012/06/07 3:23), Ying Han wrote:
> This idea is based on discussion with Michal and Johannes from LSF.
> 
> 1. If soft_limit are all set to MAX, it wastes first three priority iterations
> without scanning anything.
> 
> 2. By default every memcg is eligible for softlimit reclaim, and we can also
> set the value to MAX for special memcg which is immune to soft limit reclaim.
> 
> There is a behavior change after this patch: (N == DEF_PRIORITY - 2)
> 
>          A: usage>  softlimit        B: usage<= softlimit        U: softlimit unset
> old:    reclaim at each priority    reclaim when priority<  N    reclaim when priority<  N
> new:    reclaim at each priority    reclaim when priority<  N    reclaim at each priority
> 
> Note: I can leave the counter->soft_limit uninitialized, at least all the
> caller of res_counter_init() have the memcg as pre-zeroed structure. However, I
> might be better not rely on that.
> 
> Signed-off-by: Ying Han<yinghan@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
