Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5A4EF6B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 20:42:37 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4D0gWOC026393
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 May 2010 09:42:32 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F84145DE4E
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:42:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FB6745DE52
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:42:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F0DB11DB8014
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:42:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 95EBAE08001
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:42:31 +0900 (JST)
Date: Thu, 13 May 2010 09:38:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] track the root (oldest) anon_vma
Message-Id: <20100513093828.1cd022db.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100512133958.3aff0515@annuminas.surriel.com>
References: <20100512133815.0d048a86@annuminas.surriel.com>
	<20100512133958.3aff0515@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 May 2010 13:39:58 -0400
Rik van Riel <riel@redhat.com> wrote:

> Subject: track the root (oldest) anon_vma
> 
> Track the root (oldest) anon_vma in each anon_vma tree.   Because we only
> take the lock on the root anon_vma, we cannot use the lock on higher-up
> anon_vmas to lock anything.  This makes it impossible to do an indirect
> lookup of the root anon_vma, since the data structures could go away from
> under us.
> 
> However, a direct pointer is safe because the root anon_vma is always the
> last one that gets freed on munmap or exit, by virtue of the same_vma list
> order and unlink_anon_vmas walking the list forward.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I welcome this. Thank you!

Reading 4/5, I felt I'm grad if you add a Documentation or very-precise-comment
about the new anon_vma rules and the _meaning_ of anon_vma_root_lock.
I cannot fully convice myself that I understand them all.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
