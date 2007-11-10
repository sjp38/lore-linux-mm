Subject: Re: [patch 2/2] fs: buffer trylock rename
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20071110051501.GB16018@wotan.suse.de>
References: <20071110051222.GA16018@wotan.suse.de>
	 <20071110051501.GB16018@wotan.suse.de>
Content-Type: text/plain
Date: Sat, 10 Nov 2007 12:44:31 +0100
Message-Id: <1194695071.20832.24.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2007-11-10 at 06:15 +0100, Nick Piggin wrote:
> fs: rename buffer trylock
> 
> Converting the buffer lock to new bitops also requires name change, so convert
> the raw test_and_set bitop to a trylock.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Looks simple enough, I'll look into doing a lockdep annotation for it
some time.

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
