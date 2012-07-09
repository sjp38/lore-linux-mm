Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id DFA826B0062
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 22:54:06 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 74CC33EE0C0
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:54:05 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5463C45DE5C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:54:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 341AB45DE56
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:54:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E1F1E7800A
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:54:05 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 65C9D1DB8054
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:54:04 +0900 (JST)
Message-ID: <4FFA474B.3080606@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 11:51:55 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 07/11] mm: memcg: remove unneeded shmem charge type
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org> <1341449103-1986-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-8-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/05 9:44), Johannes Weiner wrote:
> shmem page charges have not needed a separate charge type to tell them
> from regular file pages since 08e552c 'memcg: synchronized LRU'.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
