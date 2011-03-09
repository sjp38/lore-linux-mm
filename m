Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 007868D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 02:11:19 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E82E43EE0AE
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:11:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CCFEC45DE50
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:11:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B63ED45DE4F
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:11:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A73FF1DB803B
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:11:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 711F31DB802F
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:11:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: THP, rmap and page_referenced_one()
In-Reply-To: <4D7635DA.9030707@redhat.com>
References: <20110308113245.GR25641@random.random> <4D7635DA.9030707@redhat.com>
Message-Id: <20110309161132.0409.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed,  9 Mar 2011 16:11:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

> On 03/08/2011 06:32 AM, Andrea Arcangeli wrote:
> 
> > Subject: thp: fix page_referenced to modify mapcount/vm_flags only if page is found
> >
> > From: Andrea Arcangeli<aarcange@redhat.com>
> >
> > When vmscan.c calls page_referenced, if an anon page was created before a
> > process forked, rmap will search for it in both of the processes, even though
> > one of them might have since broken COW. If the child process mlocks the vma
> > where the COWed page belongs to, page_referenced() running on the page mapped
> > by the parent would lead to *vm_flags getting VM_LOCKED set erroneously (leading
> > to the references on the parent page being ignored and evicting the parent page
> > too early).
> 
> > Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> > Reported-by: Michel Lespinasse<walken@google.com>
> 
> Reviewed-by: Rik van Riel<riel@redhat.com>

Thank you, Andrea.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
