Date: Thu, 31 Jan 2008 02:19:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: MADV_WILLNEED implementation for anonymous memory
Message-Id: <20080131021949.92715ba4.akpm@linux-foundation.org>
In-Reply-To: <p73ve5a47yr.fsf@bingen.suse.de>
References: <1201714139.28547.237.camel@lappy>
	<20080130144049.73596898.akpm@linux-foundation.org>
	<1201769040.28547.245.camel@lappy>
	<20080131011227.257b9437.akpm@linux-foundation.org>
	<1201772118.28547.254.camel@lappy>
	<20080131014702.705f1040.akpm@linux-foundation.org>
	<1201773206.28547.259.camel@lappy>
	<p73ve5a47yr.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, riel@redhat.com, mztabzr@0pointer.de, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008 11:15:08 +0100 Andi Kleen <andi@firstfloor.org> wrote:

> Peter Zijlstra <a.p.zijlstra@chello.nl> writes:
> >
> > Ah, that is Lennarts Pulse Audio thing, he has samples in memory which
> > might not have been used for a while, and he wants to be able to
> > pre-fetch those when he suspects they might need to be played. So that
> > once the audio thread comes along and stuffs them down /dev/dsp its all
> > nice in memory.
> 
> The real problem that seems to make swapping so slow is that the data
> tends to be badly fragmented on the swap partition. I suspect if that
> problem was attached the need for such prefetching would be far less
> because swap in would be much faster.
> 

Yeah, the 2.5 switch to physical scanning killed us there.

I still don't know why my allocate-swapspace-according-to-virtual-address
change didn't help.  Much.  Marcelo played with that a bit too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
