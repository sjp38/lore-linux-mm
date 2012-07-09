Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 784906B006C
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 23:29:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 19DA13EE0B6
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 12:29:03 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0281D45DEAD
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 12:29:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E18F045DEA6
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 12:29:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D58B31DB803B
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 12:29:02 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FF521DB803E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 12:29:02 +0900 (JST)
Message-ID: <4FFA4F76.7090901@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 12:26:46 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 10/11] mm: memcg: only check swap cache pages for repeated
 charging
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org> <1341449103-1986-11-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-11-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/05 9:45), Johannes Weiner wrote:
> Only anon and shmem pages in the swap cache are attempted to be
> charged multiple times, from every swap pte fault or from
> shmem_unuse().  No other pages require checking PageCgroupUsed().
> 
> Charging pages in the swap cache is also serialized by the page lock,
> and since both the try_charge and commit_charge are called under the
> same page lock section, the PageCgroupUsed() check might as well
> happen before the counter charging, let alone reclaim.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

You're right. This is SwapCache handling is done by commit d13d144309d...
I should notice this....

Thank you very much !

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
