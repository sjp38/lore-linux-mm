Date: Thu, 31 Jan 2008 12:32:24 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm: MADV_WILLNEED implementation for anonymous memory
Message-ID: <20080131113224.GB31090@one.firstfloor.org>
References: <20080130144049.73596898.akpm@linux-foundation.org> <1201769040.28547.245.camel@lappy> <20080131011227.257b9437.akpm@linux-foundation.org> <1201772118.28547.254.camel@lappy> <20080131014702.705f1040.akpm@linux-foundation.org> <1201773206.28547.259.camel@lappy> <p73ve5a47yr.fsf@bingen.suse.de> <20080131021949.92715ba4.akpm@linux-foundation.org> <20080131110610.GA31090@one.firstfloor.org> <20080131055209.6adede04@riellaptop.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080131055209.6adede04@riellaptop.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, mztabzr@0pointer.de, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 05:52:09AM -0500, Rik van Riel wrote:
> On Thu, 31 Jan 2008 12:06:10 +0100
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > > Yeah, the 2.5 switch to physical scanning killed us there.
> > > 
> > > I still don't know why my
> > > allocate-swapspace-according-to-virtual-address change didn't
> > > help.  Much.  Marcelo played with that a bit too.
> > 
> > I've been thinking about just always doing swap on > page clusters. 
> > Any reason swapping couldn't be done on e.g. 1MB chunks? 
> 
> Don't malloc() and free() hopelessly fragment memory
> over time, ensuring that little related data can be
> found inside each 1MB chunk if the process is large
> enough?  (say, firefox)

Even if they do (I don't know if it's true or not) it does not really 
matter because on modern hard disks/systems it does not cost less to 
transfer 1MB versus 4K. The actual threshold seems to be rising in fact.

The only drawback is that the swap might be full sooner, but 
I would actually consider this a feature because it would likely
end many prolonged oom death dances much sooner.

-Andi 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
