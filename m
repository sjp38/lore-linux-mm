Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 61E546B004A
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 21:36:39 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAT2aawx028944
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 29 Nov 2010 11:36:37 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D619C45DE5B
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:36:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BAEEC45DE57
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:36:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AD3D1E18003
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:36:36 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 791D71DB803C
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 11:36:36 +0900 (JST)
Date: Mon, 29 Nov 2010 11:30:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 06/21] mm: Simplify anon_vma refcounts
Message-Id: <20101129113054.7db4664c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101126145410.601515267@chello.nl>
References: <20101126143843.801484792@chello.nl>
	<20101126145410.601515267@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Nov 2010 15:38:49 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> This patch changes the anon_vma refcount to be 0 when the object is
> free. It does this by adding 1 ref to being in use in the anon_vma
> structure (iow. the anon_vma->head list is not empty).
> 
> This allows a simpler release scheme without having to check both the
> refcount and the list as well as avoids taking a ref for each entry
> on the list.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
