Date: Mon, 15 Oct 2007 10:54:14 -0700
From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
Message-ID: <20071015175414.GB10840@linux-os.sc.intel.com>
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200710141101.02649.nickpiggin@yahoo.com.au> <20071014181929.GA19902@linux-os.sc.intel.com> <200710152225.11433.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200710152225.11433.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com, twichell@us.ibm.com, shaggy@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 15, 2007 at 10:25:11PM +1000, Nick Piggin wrote:
> On Monday 15 October 2007 04:19, Siddha, Suresh B wrote:
> > On Sun, Oct 14, 2007 at 11:01:02AM +1000, Nick Piggin wrote:
> > > On Sunday 14 October 2007 09:27, Nick Piggin wrote:
> > > > On Saturday 13 October 2007 06:34, Siddha, Suresh B wrote:
> > > > > sounds like two birds in one shot, I think.
> > > >
> > > > OK, I'll flesh it out a bit more and see if I can actually get
> > > > something working (and working with hugepages too).
> > >
> > > This is just a really quick hack, untested ATM, but one that
> > > has at least a chance of working (on x86).
> >
> > When we fall back to slow mode, we should decrement the ref counts
> > on the pages we got so far in the fast mode.
> 
> Here is something that is actually tested and works (not
> tested with hugepages yet, though).
> 
> However it's not 100% secure at the moment. It's actually
> not completely trivial; I think we need to use an extra bit
> in the present pte in order to exclude "not normal" pages,
> if we want fast_gup to work on small page mappings too. I
> think this would be possible to do on most architectures, but
> I haven't done it here obviously.
> 
> Still, it should be enough to test the design. I've added
> fast_gup and fast_gup_slow to /proc/vmstat, which count the
> number of times fast_gup was called, and the number of times
> it dropped into the slowpath. It would be interesting to know
> how it performs compared to your granular hugepage ptl...

I am reasonably sure, it will perform better than mine, as it addresses
the mmap_sem cacheline bouncing also.

I think Brian/Badari can help us out in getting the numbers.

thanks,
suresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
