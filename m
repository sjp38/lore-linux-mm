Date: Thu, 17 Apr 2008 09:18:52 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 2/2]: introduce fast_gup
In-Reply-To: <1208448768.7115.30.camel@twins>
Message-ID: <alpine.LFD.1.00.0804170916470.2879@woody.linux-foundation.org>
References: <20080328025455.GA8083@wotan.suse.de>  <20080328030023.GC8083@wotan.suse.de> <1208444605.7115.2.camel@twins>  <alpine.LFD.1.00.0804170814090.2879@woody.linux-foundation.org> <1208448768.7115.30.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, Clark Williams <williams@redhat.com>, Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>
List-ID: <linux-mm.kvack.org>


On Thu, 17 Apr 2008, Peter Zijlstra wrote:
> 
> Jeremy, did I get the paravirt stuff right?

I don't think this is worth it to virtualize.

We access the page tables directly in any number of places, having a 
"get_pte()" indirection here is not going to help anything.

Just make it an x86-only inline function. In fact, you can keep it inside 
arch/x86/mm/gup.c, because nobody else is likely to ever even need it, 
since normal accesses are all supposed to be done under the page table 
spinlock, so they do not have this issue at all.

The indirection and virtualization thing is just going to complicate 
matters for no good reason.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
