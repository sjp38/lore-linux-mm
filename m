From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
Date: Mon, 15 Oct 2007 14:15:55 +1000
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200710141101.02649.nickpiggin@yahoo.com.au> <20071014181929.GA19902@linux-os.sc.intel.com>
In-Reply-To: <20071014181929.GA19902@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710151415.55332.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Cc: Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Monday 15 October 2007 04:19, Siddha, Suresh B wrote:
> On Sun, Oct 14, 2007 at 11:01:02AM +1000, Nick Piggin wrote:
> > On Sunday 14 October 2007 09:27, Nick Piggin wrote:
> > > On Saturday 13 October 2007 06:34, Siddha, Suresh B wrote:
> > > > sounds like two birds in one shot, I think.
> > >
> > > OK, I'll flesh it out a bit more and see if I can actually get
> > > something working (and working with hugepages too).
> >
> > This is just a really quick hack, untested ATM, but one that
> > has at least a chance of working (on x86).
>
> When we fall back to slow mode, we should decrement the ref counts
> on the pages we got so far in the fast mode.

Oops, you're right of course!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
