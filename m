Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 924016B0047
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:23:40 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Fri, 13 Mar 2009 04:23:35 +1100
References: <20090311170611.GA2079@elte.hu> <20090312170010.GT27823@random.random> <200903130420.28772.nickpiggin@yahoo.com.au>
In-Reply-To: <200903130420.28772.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903130423.36142.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 13 March 2009 04:20:27 Nick Piggin wrote:
> On Friday 13 March 2009 04:00:11 Andrea Arcangeli wrote:

> > and I think you have implementation issues in the patch (the
> > parent pte can't be left writeable if you are in a don't-cow vma, or
> > the copy will not be atomic, and glibc will have no chance to fix its
> > bugs)
>
> Oh, we need to do that? OK, then just take out that statement, and

Should read: "take out that *if* statement" (the one which I put in to
avoid wrprotect in the parent)

> change VM_BUG_ON(PageDontCOW()) in do_wp_page to
> VM_BUG_ON(PageDontCOW() && !reuse);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
