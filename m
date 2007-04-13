From: David Howells <dhowells@redhat.com>
In-Reply-To: <20070413102518.GD31487@wotan.suse.de> 
References: <20070413102518.GD31487@wotan.suse.de>  <20070413100416.GC31487@wotan.suse.de> 
Subject: Re: [patch] generic rwsems 
Date: Fri, 13 Apr 2007 12:44:50 +0100
Message-ID: <25428.1176464690@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote:

> I think I should put wait_lock after wait_list, so as to get a better
> packing on most 64-bit architectures.

It makes no difference.  struct lockdep_map contains at least one pointer and
so is going to be 8-byte aligned (assuming it's there at all).  struct
rw_semaphore contains at least one pointer/long, so it will be padded out to
8-byte size.

If you want to make a difference, you'd need to add __attribute__((packed))
but you would need to be very careful with that.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
