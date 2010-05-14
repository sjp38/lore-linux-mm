Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 43D576B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 20:09:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4E091KX019451
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 14 May 2010 09:09:01 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DC33245DE53
	for <linux-mm@kvack.org>; Fri, 14 May 2010 09:09:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B3D6145DE50
	for <linux-mm@kvack.org>; Fri, 14 May 2010 09:09:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 808A11DB803C
	for <linux-mm@kvack.org>; Fri, 14 May 2010 09:09:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 210751DB803E
	for <linux-mm@kvack.org>; Fri, 14 May 2010 09:09:00 +0900 (JST)
Date: Fri, 14 May 2010 09:04:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] track the root (oldest) anon_vma
Message-Id: <20100514090458.acaedb48.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4BEB630B.8070805@redhat.com>
References: <20100512133815.0d048a86@annuminas.surriel.com>
	<20100512133958.3aff0515@annuminas.surriel.com>
	<20100513093828.1cd022db.kamezawa.hiroyu@jp.fujitsu.com>
	<4BEB630B.8070805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 May 2010 22:25:15 -0400
Rik van Riel <riel@redhat.com> wrote:

> On 05/12/2010 08:38 PM, KAMEZAWA Hiroyuki wrote:
> > On Wed, 12 May 2010 13:39:58 -0400
> > Rik van Riel<riel@redhat.com>  wrote:
> >
> >> Subject: track the root (oldest) anon_vma
> >>
> >> Track the root (oldest) anon_vma in each anon_vma tree.   Because we only
> >> take the lock on the root anon_vma, we cannot use the lock on higher-up
> >> anon_vmas to lock anything.  This makes it impossible to do an indirect
> >> lookup of the root anon_vma, since the data structures could go away from
> >> under us.
> >>
> >> However, a direct pointer is safe because the root anon_vma is always the
> >> last one that gets freed on munmap or exit, by virtue of the same_vma list
> >> order and unlink_anon_vmas walking the list forward.
> >>
> >> Signed-off-by: Rik van Riel<riel@redhat.com>
> >
> >
> > Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> >
> > I welcome this. Thank you!
> >
> > Reading 4/5, I felt I'm grad if you add a Documentation or very-precise-comment
> > about the new anon_vma rules and the _meaning_ of anon_vma_root_lock.
> > I cannot fully convice myself that I understand them all.
> 
> Please send me a list of all the questions that come up
> when you read the patches, and I'll prepare a patch 6/5
> with just documentation :)
> 

0. Why it's dangerous to take vma->anon_vma->lock ?

1. What kinds of anon_vmas we'll found in
     page->mapping => anon_vma->head and avc->same_anon_vma ?
   IOW, what kinds of avc->vmas will see when we walk anon_vma->head.

2. Why we have to walk from the root ?

3. What anon_vma_lock guards, actually ?


etc....the facts which is unclear for guys who are not involved in this fix.
Preparing some explanation seems to be kindly rather than "plz ask google"

Bye.
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
