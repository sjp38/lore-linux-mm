Subject: Re: [PATCH 1/1] mm: unify pmd_free() implementation
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org>
References: <> <1217260287-13115-1-git-send-email-righi.andrea@gmail.com>
	 <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org>
Content-Type: text/plain
Date: Mon, 28 Jul 2008 11:17:32 -0500
Message-Id: <1217261852.3503.89.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Righi <righi.andrea@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-28 at 08:53 -0700, Linus Torvalds wrote:
> But this is horrible, because it forces a totally unnecessary function 
> call for that empty function.
> 
> Yeah, the function will be cheap, but the call itself will not be (it's a 
> C language barrier and basically disables optimizations around it, causing 
> thigns like register spill/reload for no good reason).

Are you sure about this (the barrier)?  We've been struggling to find a
paradigm for our trace points but the consensus seemed to be that
compiler barriers were pretty tiny perturbations in the optimiser stream
(they affect calculation ordering, but not usually enough to be
noticed).  The register spills to get known locations for the tracepoint
variables seemed to be the much more expensive thing.

If this basic assumption is wrong, we need to know now ...

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
