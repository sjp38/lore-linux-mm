Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA056B00F7
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 19:29:00 -0400 (EDT)
Date: Tue, 19 Jul 2011 16:28:57 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH 1/12] radix_tree: exceptional entries and indices
Message-Id: <20110719162857.63b6b0be.rdunlap@xenotime.net>
In-Reply-To: <alpine.LSU.2.00.1107191532130.1541@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
	<alpine.LSU.2.00.1106140341070.29206@sister.anvils>
	<20110617163854.49225203.akpm@linux-foundation.org>
	<20110617170742.282a1bd6.rdunlap@xenotime.net>
	<20110617171228.4c85fd38.rdunlap@xenotime.net>
	<alpine.LSU.2.00.1106171845480.20321@sister.anvils>
	<alpine.LSU.2.00.1107191532130.1541@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: akpm <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 19 Jul 2011 15:36:37 -0700 (PDT) Hugh Dickins wrote:

> On Fri, 17 Jun 2011, Hugh Dickins wrote:
> > On Fri, 17 Jun 2011, Randy Dunlap wrote:
> > 
> > > > And one Andrew Morton has a userspace radix tree test harness at
> > > > http://userweb.kernel.org/~akpm/stuff/rtth.tar.gz
> > 
> > This should still be as relevant as it was before, but I notice its
> > radix_tree.c is almost identical to the source currently in the kernel
> > tree, so I ought at the least to keep it in synch.
> 
> I was hoping to have dealt with this by now, Randy; but after downloading
> an up-to-date urcu, I'm finding what's currently in rtth does not build
> with it.  Unlikely to be hard to fix, but means I'll have to defer it a
> little while longer.

Sure, not a problem.  Thanks for not dropping it completely.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
