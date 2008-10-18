MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18681.20241.347889.843669@cargo.ozlabs.ibm.com>
Date: Sat, 18 Oct 2008 13:50:57 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <20081018015323.GA11149@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de>
	<Pine.LNX.4.64.0810172300280.30871@blonde.site>
	<alpine.LFD.2.00.0810171549310.3438@nehalem.linux-foundation.org>
	<Pine.LNX.4.64.0810180045370.8995@blonde.site>
	<20081018015323.GA11149@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin writes:

> But after thinking about this a bit more, I think Linux would be
> broken all over the map under such ordering schemes. I think we'd
> have to mandate causal consistency. Are there any architectures we
> run on where this is not guaranteed? (I think recent clarifications
> to x86 ordering give us CC on that architecture).
> 
> powerpc, ia64, alpha, sparc, arm, mips? (cced linux-arch)

Not sure what you mean by causal consistency, but I assume it's the
same as saying that barriers give cumulative ordering, as described on
page 413 of the Power Architecture V2.05 document at:

http://www.power.org/resources/reading/PowerISA_V2.05.pdf

The ordering provided by sync, lwsync and eieio is cumulative (see
pages 446 and 448), so we should be OK on powerpc AFAICS.  (The
cumulative property of eieio only applies to accesses to normal system
memory, but that should be OK since we use sync when we want barriers
that affect non-cacheable accesses as well as cacheable.)

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
