Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 4401F6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 01:18:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5BB803EE0BC
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 14:18:55 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 412D345DE4D
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 14:18:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2925645DE4F
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 14:18:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AD8D1DB8042
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 14:18:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CAE101DB803F
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 14:18:54 +0900 (JST)
Message-ID: <4F963742.2030607@jp.fujitsu.com>
Date: Tue, 24 Apr 2012 14:16:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] propagate gfp_t to page table alloc functions
References: <1335171318-4838-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1335171318-4838-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2012/04/23 17:55), Minchan Kim wrote:

> As I test some code, I found a problem about deadlock by lockdep.
> The reason I saw the message is __vmalloc calls map_vm_area which calls
> pud/pmd_alloc without gfp_t. so although we call __vmalloc with
> GFP_ATOMIC or GFP_NOIO, it ends up allocating pages with GFP_KERNEL.
> The should be a BUG. This patch fixes it by passing gfp_to to low page
> table allocate functions.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>


Hmm ? vmalloc should support GFP_ATOMIC ?

And, do we need to change all pud_,pgd_,pmd_,pte_alloc() for users pgtables ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
