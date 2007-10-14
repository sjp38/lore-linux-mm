Date: Sun, 14 Oct 2007 08:42:24 -0700
From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Subject: Re: [rfc] more granular page table lock for hugepages
Message-ID: <20071014154223.GD19625@linux-os.sc.intel.com>
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200710112139.51354.nickpiggin@yahoo.com.au> <20071012203421.GC19625@linux-os.sc.intel.com> <200710140927.46478.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200710140927.46478.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Sun, Oct 14, 2007 at 09:27:46AM +1000, Nick Piggin wrote:
> On Saturday 13 October 2007 06:34, Siddha, Suresh B wrote:
> > On ia64, we have "tpa" instruction which does the virtual to physical
> > address conversion for us. But talking to Tony, that will fault during not
> > present or vhpt misses.
> >
> > Well, for now, manual walk is probably the best we have.
> 
> Hmm, we'd actually want it to fault, and go through the full
> handle_mm_fault path if possible, and somehow just give an

But, this walk was happening with interrupts disabled. So the best will be
to have a peek at the page tables without faulting and the peek can comeback
and say, sorry, you have to go through slowest path.

Anyhow, lets first make sure that no one else has any major issues with
the simplest solution first :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
