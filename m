Date: Sun, 14 Oct 2007 11:19:29 -0700
From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
Message-ID: <20071014181929.GA19902@linux-os.sc.intel.com>
References: <20071008225234.GC27824@linux-os.sc.intel.com> <20071012203421.GC19625@linux-os.sc.intel.com> <200710140927.46478.nickpiggin@yahoo.com.au> <200710141101.02649.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200710141101.02649.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Sun, Oct 14, 2007 at 11:01:02AM +1000, Nick Piggin wrote:
> On Sunday 14 October 2007 09:27, Nick Piggin wrote:
> > On Saturday 13 October 2007 06:34, Siddha, Suresh B wrote:
> 
> > > sounds like two birds in one shot, I think.
> >
> > OK, I'll flesh it out a bit more and see if I can actually get
> > something working (and working with hugepages too).
> 
> This is just a really quick hack, untested ATM, but one that
> has at least a chance of working (on x86).

When we fall back to slow mode, we should decrement the ref counts
on the pages we got so far in the fast mode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
