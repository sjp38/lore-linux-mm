Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F05AD6B01F2
	for <linux-mm@kvack.org>; Tue, 11 May 2010 20:23:50 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4C0Nm70015368
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 12 May 2010 09:23:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 64DB045DE7D
	for <linux-mm@kvack.org>; Wed, 12 May 2010 09:23:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9096945DE4D
	for <linux-mm@kvack.org>; Wed, 12 May 2010 09:23:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BB85E0800B
	for <linux-mm@kvack.org>; Wed, 12 May 2010 09:23:45 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EBFA0E08005
	for <linux-mm@kvack.org>; Wed, 12 May 2010 09:23:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm,migration: Avoid race between shift_arg_pages() and rmap_walk() during migration by not migrating temporary stacks
In-Reply-To: <20100511085752.GM26611@csn.ul.ie>
References: <20100511085752.GM26611@csn.ul.ie>
Message-Id: <20100512092239.2120.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 12 May 2010 09:23:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

> diff --git a/fs/exec.c b/fs/exec.c
> index 725d7ef..13f8e7f 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -242,9 +242,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
>  	 * use STACK_TOP because that can depend on attributes which aren't
>  	 * configured yet.
>  	 */
> +	BUG_ON(VM_STACK_FLAGS & VM_STACK_INCOMPLETE_SETUP);

Can we use BUILD_BUG_ON()? 

but anyway
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
