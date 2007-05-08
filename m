Message-ID: <4641065D.6060403@yahoo.com.au>
Date: Wed, 09 May 2007 09:23:09 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] MM: implement MADV_FREE lazy freeing of anonymous memory
References: <4632D0EF.9050701@redhat.com> <463B108C.10602@yahoo.com.au> <463B598B.80200@redhat.com> <463BC62C.3060605@yahoo.com.au> <463E5A00.6070708@redhat.com> <464014B0.7060308@yahoo.com.au> <4640906B.2020301@redhat.com>
In-Reply-To: <4640906B.2020301@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Nick Piggin wrote:
> 
>> We have percpu and cache affine page allocators, so when
>> userspace just frees a page, it is likely to be cache hot, so
>> we want to free it up so it can be reused by this CPU ASAP.
>> Likewise, when we newly allocate a page, we want it to be one
>> that is cache hot on this CPU.
> 
> 
> Actually, isn't the clear page function capable of doing
> some magic, when it writes all zeroes into the page, that
> causes the zeroes to just live in CPU cache without the old
> data ever being loaded from RAM?
> 
> That would sure be faster than touching RAM.  Not sure if
> we use/trigger that kind of magic, though :)
> 

powerpc has and uses an instruction to zero a full cacheline, yes.

Not sure about x86-64 CPUs... I don't think they can do it.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
