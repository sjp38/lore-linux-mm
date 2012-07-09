Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 10DDD6B0062
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 22:55:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 88FD03EE0BD
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:55:09 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7013745DE4E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:55:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5729745DD74
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:55:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 49A511DB803C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:55:09 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 020231DB803A
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:55:09 +0900 (JST)
Message-ID: <4FFA478D.4030007@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 11:53:01 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 08/11] mm: memcg: remove needless !mm fixup to init_mm
 when charging
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org> <1341449103-1986-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-9-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/05 9:45), Johannes Weiner wrote:
> It does not matter to __mem_cgroup_try_charge() if the passed mm is
> NULL or init_mm, it will charge the root memcg in either case.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
