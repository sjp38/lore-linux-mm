Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 7D6A46B005C
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 22:30:21 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 59BB53EE0C0
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:30:19 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A69345DEA6
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:30:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2297145DE9E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:30:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1465D1DB8040
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:30:19 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C00B81DB8038
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:30:18 +0900 (JST)
Message-ID: <4FFA41A9.2030806@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 11:27:53 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 01/11] mm: memcg: fix compaction/migration failing due
 to memcg limits
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org> <1341449103-1986-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/05 9:44), Johannes Weiner wrote:
> Compaction (and page migration in general) can currently be hindered
> through pages being owned by memory cgroups that are at their limits
> and unreclaimable.
> 
> The reason is that the replacement page is being charged against the
> limit while the page being replaced is also still charged.  But this
> seems unnecessary, given that only one of the two pages will still be
> in use after migration finishes.
> 
> This patch changes the memcg migration sequence so that the
> replacement page is not charged.  Whatever page is still in use after
> successful or failed migration gets to keep the charge of the page
> that was going to be replaced.
> 
> Reported-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
