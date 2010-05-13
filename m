Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C96246B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 20:34:39 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4D0YZ53019361
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 May 2010 09:34:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D1B9B45DE58
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:34:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A4C2345DE55
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:34:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D12E1DB8050
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:34:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B43701DB8056
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:34:34 +0900 (JST)
Date: Thu, 13 May 2010 09:30:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] rename anon_vma_lock to vma_lock_anon_vma
Message-Id: <20100513093033.4f17a741.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100512133931.14c79d22@annuminas.surriel.com>
References: <20100512133815.0d048a86@annuminas.surriel.com>
	<20100512133931.14c79d22@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 May 2010 13:39:31 -0400
Rik van Riel <riel@redhat.com> wrote:

> Subject: rename anon_vma_lock to vma_lock_anon_vma
> 
> Rename anon_vma_lock to vma_lock_anon_vma.  This matches the
> naming style used in page_lock_anon_vma and will come in really
> handy further down in this patch series.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
