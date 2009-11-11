Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CD7CE6B0078
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 21:42:12 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB2gANn007517
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Nov 2009 11:42:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 091EA45DE60
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:42:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B385545DE70
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:42:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 707E0E1800A
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:42:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F132C1DB803A
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:42:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] mm: sigbus instead of abusing oom
In-Reply-To: <20091111113719.589e61d7.kamezawa.hiroyu@jp.fujitsu.com>
References: <Pine.LNX.4.64.0911102202500.2816@sister.anvils> <20091111113719.589e61d7.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20091111114119.FD53.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Nov 2009 11:42:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 10 Nov 2009 22:06:49 +0000 (GMT)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> 
> > When do_nonlinear_fault() realizes that the page table must have been
> > corrupted for it to have been called, it does print_bad_pte() and
> > returns ... VM_FAULT_OOM, which is hard to understand.
> > 
> > It made some sense when I did it for 2.6.15, when do_page_fault()
> > just killed the current process; but nowadays it lets the OOM killer
> > decide who to kill - so page table corruption in one process would
> > be liable to kill another.
> > 
> > Change it to return VM_FAULT_SIGBUS instead: that doesn't guarantee
> > that the process will be killed, but is good enough for such a rare
> > abnormality, accompanied as it is by the "BUG: Bad page map" message.
> > 
> > And recent HWPOISON work has copied that code into do_swap_page(),
> > when it finds an impossible swap entry: fix that to VM_FAULT_SIGBUS too.
> > 
> > Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> Thank you !
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thank you, me too.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
