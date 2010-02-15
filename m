Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0BE196B007B
	for <linux-mm@kvack.org>; Sun, 14 Feb 2010 21:51:36 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1F2pYYQ014391
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Feb 2010 11:51:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 32A2145DE51
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 11:51:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1938A45DE4E
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 11:51:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 02437E08001
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 11:51:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A92A3E08009
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 11:51:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 0/7 -mm] oom killer rewrite
In-Reply-To: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
Message-Id: <20100215114715.7278.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Feb 2010 11:51:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> This patchset is a rewrite of the out of memory killer to address several
> issues that have been raised recently.  The most notable change is a
> complete rewrite of the badness heuristic that determines which task is
> killed; the goal was to make it as simple and predictable as possible
> while still addressing issues that plague the VM.
> 
> This patchset is based on mmotm-2010-02-05-15-06 because of the following
> dependencies:

At first, I'm glad that you tackle this issue. unfortunatelly I'm very busy now.
but I'll make a time for reviewing this patches asap.




> 
> 	[patch 4/7] oom: badness heuristic rewrite:
> 		mm-count-swap-usage.patch
> 
> 	[patch 5/7] oom: replace sysctls with quick mode:
> 		sysctl-clean-up-vm-related-variable-delcarations.patch
> 
> To apply to mainline, download 2.6.33-rc7 and apply
> 
> 	mm-clean-up-mm_counter.patch
> 	mm-avoid-false-sharing-of-mm_counter.patch
> 	mm-avoid-false_sharing-of-mm_counter-checkpatch-fixes.patch
> 	mm-count-swap-usage.patch
> 	mm-count-swap-usage-checkpatch-fixes.patch
> 	mm-introduce-dump_page-and-print-symbolic-flag-names.patch
> 	sysctl-clean-up-vm-related-variable-declarations.patch
> 	sysctl-clean-up-vm-related-variable-declarations-fix.patch
> 
> from http://userweb.kernel.org/~akpm/mmotm/broken-out.tar.gz first.
> ---
>  Documentation/filesystems/proc.txt |   78 ++++---
>  Documentation/sysctl/vm.txt        |   51 ++---
>  fs/proc/base.c                     |   13 +-
>  include/linux/mempolicy.h          |   13 +-
>  include/linux/oom.h                |   18 +-
>  kernel/sysctl.c                    |   15 +-
>  mm/mempolicy.c                     |   39 +++
>  mm/oom_kill.c                      |  455 +++++++++++++++++++-----------------
>  mm/page_alloc.c                    |    3 +
>  9 files changed, 383 insertions(+), 302 deletions(-)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
