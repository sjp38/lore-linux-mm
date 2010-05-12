Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCEE6B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 15:55:37 -0400 (EDT)
Date: Wed, 12 May 2010 12:54:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,migration: Avoid race between shift_arg_pages() and
 rmap_walk() during migration by not migrating temporary stacks
Message-Id: <20100512125427.d1b170ba.akpm@linux-foundation.org>
In-Reply-To: <20100512092239.2120.A69D9226@jp.fujitsu.com>
References: <20100511085752.GM26611@csn.ul.ie>
	<20100512092239.2120.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 May 2010 09:23:44 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > diff --git a/fs/exec.c b/fs/exec.c
> > index 725d7ef..13f8e7f 100644
> > --- a/fs/exec.c
> > +++ b/fs/exec.c
> > @@ -242,9 +242,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
> >  	 * use STACK_TOP because that can depend on attributes which aren't
> >  	 * configured yet.
> >  	 */
> > +	BUG_ON(VM_STACK_FLAGS & VM_STACK_INCOMPLETE_SETUP);
> 
> Can we use BUILD_BUG_ON()? 

That's vastly preferable - I made that change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
