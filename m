Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D7E8E8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 01:06:40 -0500 (EST)
Date: Wed, 9 Mar 2011 06:06:17 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/6] mm: use mm_struct to resolve gate vma's in
 __get_user_pages
Message-ID: <20110309060617.GB22723@ZenIV.linux.org.uk>
References: <1299631343-4499-1-git-send-email-wilsons@start.ca>
 <1299631343-4499-2-git-send-email-wilsons@start.ca>
 <20110309141208.03F7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110309141208.03F7.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Stephen Wilson <wilsons@start.ca>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Roland McGrath <roland@redhat.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Wed, Mar 09, 2011 at 02:19:30PM +0900, KOSAKI Motohiro wrote:

> Hmm..
> Is this works? In exec() case task has two mm, old and new-borned. tsk has
> no enough information to detect gate area if 64bit process exec 32bit process
> or oppsite case. On Linux, 32bit and 64bit processes have perfectly different
> process vma layout.
> 
> Am I missing something?

Patch series refered to in [0/6] ;-)  FWIW, that would probably be better
off as one mail thread - would be easier to find.

What happens is that mm_struct gets marked as 32bit/64bit at execve time
(on x86, everything else doesn't care), so this stuff becomes possible
to calculate by mm_struct alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
