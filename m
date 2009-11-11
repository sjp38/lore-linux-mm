Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E29EF6B006A
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 21:40:12 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB2eAv1006324
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 11 Nov 2009 11:40:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D7C145DE61
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:40:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AA80C45DE4F
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:40:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 897DE1DB8042
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:40:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 054A3E38003
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:40:03 +0900 (JST)
Date: Wed, 11 Nov 2009 11:37:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] mm: sigbus instead of abusing oom
Message-Id: <20091111113719.589e61d7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0911102202500.2816@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
	<Pine.LNX.4.64.0911102202500.2816@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Nov 2009 22:06:49 +0000 (GMT)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> When do_nonlinear_fault() realizes that the page table must have been
> corrupted for it to have been called, it does print_bad_pte() and
> returns ... VM_FAULT_OOM, which is hard to understand.
> 
> It made some sense when I did it for 2.6.15, when do_page_fault()
> just killed the current process; but nowadays it lets the OOM killer
> decide who to kill - so page table corruption in one process would
> be liable to kill another.
> 
> Change it to return VM_FAULT_SIGBUS instead: that doesn't guarantee
> that the process will be killed, but is good enough for such a rare
> abnormality, accompanied as it is by the "BUG: Bad page map" message.
> 
> And recent HWPOISON work has copied that code into do_swap_page(),
> when it finds an impossible swap entry: fix that to VM_FAULT_SIGBUS too.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Thank you !
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
