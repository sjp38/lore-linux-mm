Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 5D8946B004D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:49:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D85303EE0C2
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:49:11 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BDC3F45DE50
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:49:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A4C9645DE4E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:49:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 921191DB803A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:49:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B2CD1DB8038
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:49:11 +0900 (JST)
Date: Tue, 13 Mar 2012 14:47:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 3/3] memcg: avoid THP split in task migration
Message-Id: <20120313144736.e4a39634.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1331591456-20769-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1331591456-20769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1331591456-20769-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 12 Mar 2012 18:30:56 -0400
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently we can't do task migration among memory cgroups without THP split,
> which means processes heavily using THP experience large overhead in task
> migration. This patch introduces the code for moving charge of THP and makes
> THP more valuable.
> 
> Changes from v3:
> - use enum mc_target_type and MC_TARGET_* explicitly
> - replace lengthy name is_target_thp_for_mc() with get_mctgt_type_thp()
> - drop cond_resched()
> - drop mapcount check of page sharing (Hugh and KAMEZAWA-san are preparing
>   patches to change the behavior of moving charge of shared pages, so this
>   patch keeps up with the change to avoid potential conflict.)
> 
> Changes from v2:
> - add move_anon() and mapcount check
> 
> Changes from v1:
> - rename is_target_huge_pmd_for_mc() to is_target_thp_for_mc()
> - remove pmd_present() check (it's buggy when pmd_trans_huge(pmd) is true)
> - is_target_thp_for_mc() calls get_page() only when checks are passed
> - unlock page table lock if !mc.precharge
> - compare return value of is_target_thp_for_mc() explicitly to MC_TARGET_TYPE
> - clean up &walk->mm->page_table_lock to &vma->vm_mm->page_table_lock
> - add comment about why race with split_huge_page() does not happen
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Hillf Danton <dhillf@gmail.com>

Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
