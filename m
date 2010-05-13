Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C6A896B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 20:36:40 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4D0abC7023771
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 May 2010 09:36:38 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B3A2045DE53
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:36:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9790645DE50
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:36:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DA421DB8015
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:36:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C6FB1DB8012
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:36:34 +0900 (JST)
Date: Thu, 13 May 2010 09:32:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] change direct call of spin_lock(anon_vma->lock) to
 inline function
Message-Id: <20100513093232.9cd50baf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100512134118.4a261072@annuminas.surriel.com>
References: <20100512133815.0d048a86@annuminas.surriel.com>
	<20100512134118.4a261072@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 May 2010 13:41:18 -0400
Rik van Riel <riel@redhat.com> wrote:

> Subject: change direct call of spin_lock(anon_vma->lock) to inline function
> 
> Subsitute a direct call of spin_lock(anon_vma->lock) with
> an inline function doing exactly the same.
> 
> This makes it easier to do the substitution to the root
> anon_vma lock in a following patch.
> 
> We will deal with the handful of special locks (nested,
> dec_and_lock, etc) separately.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
