From: Andi Kleen <ak@suse.de>
Subject: Re: [patch] generic rwsems
Date: Fri, 13 Apr 2007 12:53:49 +0200
References: <20070413100416.GC31487@wotan.suse.de>
In-Reply-To: <20070413100416.GC31487@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704131253.49301.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Howells <dhowells@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Friday 13 April 2007 12:04:16 Nick Piggin wrote:
> OK, this patch is against 2.6.21-rc6 + Mathieu's atomic_long patches.
> 
> Last time this came up I was asked to get some numbers, so here are
> some in the changelog, captured with a simple kernel module tester.
> I got motivated again because of the MySQL/glibc/mmap_sem issue.
> 
> This patch converts all architectures to a generic rwsem implementation,
> which will compile down to the same code for i386, or powerpc, for
> example, and will allow some (eg. x86-64) to move away from spinlock
> based rwsems.
> 
> Comments?

Fine for me from the x86-64 side. Some more validation with a test suite
would be good though.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
