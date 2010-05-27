Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3BBC56B01B0
	for <linux-mm@kvack.org>; Wed, 26 May 2010 21:02:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4R12VBe013283
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 27 May 2010 10:02:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C4D745DE7A
	for <linux-mm@kvack.org>; Thu, 27 May 2010 10:02:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A7D845DE60
	for <linux-mm@kvack.org>; Thu, 27 May 2010 10:02:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6471F1DB8040
	for <linux-mm@kvack.org>; Thu, 27 May 2010 10:02:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E39201DB803E
	for <linux-mm@kvack.org>; Thu, 27 May 2010 10:02:27 +0900 (JST)
Date: Thu, 27 May 2010 09:57:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] always lock the root (oldest) anon_vma
Message-Id: <20100527095747.e32a0598.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100526154044.2769e707@annuminas.surriel.com>
References: <20100526153819.6e5cec0d@annuminas.surriel.com>
	<20100526154044.2769e707@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 26 May 2010 15:40:44 -0400
Rik van Riel <riel@redhat.com> wrote:

> Subject: always lock the root (oldest) anon_vma
> 
> Always (and only) lock the root (oldest) anon_vma whenever we do something in an
> anon_vma.  The recently introduced anon_vma scalability is due to the rmap code
> scanning only the VMAs that need to be scanned.  Many common operations still
> took the anon_vma lock on the root anon_vma, so always taking that lock is not
> expected to introduce any scalability issues.
> 
> However, always taking the same lock does mean we only need to take one lock,
> which means rmap_walk on pages from any anon_vma in the vma is excluded from
> occurring during an munmap, expand_stack or other operation that needs to
> exclude rmap_walk and similar functions.
> 
> Also add the proper locking to vma_adjust.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
