Date: Fri, 13 Apr 2007 06:22:00 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch] generic rwsems
Message-ID: <20070413132200.GT2986@holomorphy.com>
References: <20070413100416.GC31487@wotan.suse.de> <25821.1176466182@redhat.com> <20070413124303.GD966@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070413124303.GD966@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 13, 2007 at 02:43:03PM +0200, Nick Piggin wrote:
> Yes, this is the case on our 2 premiere SMP powerhouse architectures,
> sparc32 and parsic.

sparc32 is ultra-legacy and I have a tremendous amount of work to do on
SMP there. I don't feel that efficiency of locking primitives is a
crucial issue for sparc32.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
