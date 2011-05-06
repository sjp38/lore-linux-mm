Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 602EE6B0012
	for <linux-mm@kvack.org>; Fri,  6 May 2011 13:05:46 -0400 (EDT)
Date: Fri, 6 May 2011 19:05:42 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Batch locking for rmap fork/exit processing
Message-ID: <20110506170542.GG11636@one.firstfloor.org>
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org> <BANLkTi=kxGkRS-VamLBnZCoHC7TpMsJ90w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTi=kxGkRS-VamLBnZCoHC7TpMsJ90w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, tim.c.chen@linux.intel.com, lwoodman@redhat.com, mel@csn.ul.ie

On Fri, May 06, 2011 at 09:44:40AM -0700, Linus Torvalds wrote:
> Hmm. Andrew wasn't cc'd on this series, and usually things like this
> go through the -mm tree
> 
> Maybe Andrew saw it by virtue of the linux-mm list, but maybe he
> didn't. So here he is cc'd directly.
> 
> The series looks reasonable to me,

Thanks.

To be honest I'm not really happy about it, it's more a short term
bandaid.  anon_vma lock and file mapping i_mmap_lock lock are still very hot
in the test, compared to .35. And I didn't find any way to improve
i_mmap_lock.

If someone has better ideas to fix this I would be interested.

Still it's probably a useful short term bandaid.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
