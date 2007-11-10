Subject: Re: [patch 1/2] mm: page trylock rename
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20071110051222.GA16018@wotan.suse.de>
References: <20071110051222.GA16018@wotan.suse.de>
Content-Type: text/plain
Date: Sat, 10 Nov 2007 12:43:19 +0100
Message-Id: <1194694999.20832.22.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2007-11-10 at 06:12 +0100, Nick Piggin wrote:
> Hi,
> 
> OK minus the memory barrier changes for now. Can we possibly please
> get these into 2.6.24?
> 
> --
> mm: rename page trylock
> 
> Converting page lock to new locking bitops requires a change of page flag
> operation naming, so we might as well convert it to something nicer
> (!TestSetPageLocked => trylock_page, SetPageLocked => set_page_locked).
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
