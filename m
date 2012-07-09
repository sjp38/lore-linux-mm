Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 9294A6B0062
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 22:57:52 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2A10E3EE0BB
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:57:51 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A7B445DE52
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:57:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E531B45DE4D
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:57:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C66961DB8040
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:57:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F2581DB803A
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:57:50 +0900 (JST)
Message-ID: <4FFA481E.7010602@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 11:55:26 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 09/11] mm: memcg: split swapin charge function into private
 and public part
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org> <1341449103-1986-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-10-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/05 9:45), Johannes Weiner wrote:
> When shmem is charged upon swapin, it does not need to check twice
> whether the memory controller is enabled.
> 
> Also, shmem pages do not have to be checked for everything that
> regular anon pages have to be checked for, so let shmem use the
> internal version directly and allow future patches to move around
> checks that are only required when swapping in anon pages.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
