Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 24A305F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 12:28:20 -0400 (EDT)
Date: Tue, 7 Apr 2009 18:30:57 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] POISON: The high level memory error handler in the VM
Message-ID: <20090407163057.GR17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407151010.E72A91D0471@basil.firstfloor.org> <49DB7934.3060008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49DB7934.3060008@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, npiggin@suse.de, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 12:03:00PM -0400, Rik van Riel wrote:
> Andi Kleen wrote:
> 
> >This is rather tricky code and needs a lot of review. Undoubtedly it still
> >has bugs.
> 
> It's just complex enough that it looks like it might have
> more bugs, but I sure couldn't find any.

Thanks for the review.

Perhaps I didn't put it strongly enough: I know there are still bugs 
in there (e.g. nonlinear mappings deadlock and there are some cases
where the reference count of the page doesn't drop the zero).

> Hitting a bug in this code seems favorable to hitting
> guaranteed memory corruption, so I hope Andrew or Ingo

Yes the alternative is always panic() when the hardware detects
the consumed corruption and bails out.  So even if this code is buggy it's 
very likely still an improvement. So it would be reasonable to
do a relatively early merge and improve further in tree.

> >Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> Acked-by: Rik van Riel <riel@redhat.com>

Thanks added 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
