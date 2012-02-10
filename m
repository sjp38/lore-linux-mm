Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 97B8E6B13F0
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 20:00:46 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8E9F13EE0C2
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 10:00:44 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 723EA45DE4D
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 10:00:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 46AA545DE53
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 10:00:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 356BF1DB8043
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 10:00:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E06A31DB803C
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 10:00:43 +0900 (JST)
Date: Fri, 10 Feb 2012 09:59:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] pagemap: introduce data structure for pagemap entry
Message-Id: <20120210095919.b6236781.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120209162741.283ecb76.akpm@linux-foundation.org>
References: <1328716302-16871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1328716302-16871-7-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20120209162741.283ecb76.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Thu, 9 Feb 2012 16:27:41 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed,  8 Feb 2012 10:51:42 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > Currently a local variable of pagemap entry in pagemap_pte_range()
> > is named pfn and typed with u64, but it's not correct (pfn should
> > be unsigned long.)
> > This patch introduces special type for pagemap entry and replace
> > code with it.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Changes since v4:
> >   - Rename pme_t to pagemap_entry_t
> 
> hm.  Why this change?  I'd have thought that this should be called
> pme_t.  And defined in or under pgtable.h, rather than being private to
> fs/proc/task_mmu.c.
> 

Ah, he changed the name because I complained "pme_t seems a new page table entry
type.." 

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
