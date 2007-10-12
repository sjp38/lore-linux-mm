Date: Fri, 12 Oct 2007 13:34:21 -0700
From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Subject: Re: [rfc] more granular page table lock for hugepages
Message-ID: <20071012203421.GC19625@linux-os.sc.intel.com>
References: <20071008225234.GC27824@linux-os.sc.intel.com> <b040c32a0710092310t22693865ue0b53acec85fae44@mail.gmail.com> <b040c32a0710100050x51498022m247acf34da7bc3de@mail.gmail.com> <200710112139.51354.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200710112139.51354.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ken Chen <kenchen@google.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 11, 2007 at 04:39:51AM -0700, Nick Piggin wrote:
> Attached is the really basic sketch of how it will work. Any
> party poopers care tell me why I'm an idiot? :)

I tried to be a party pooper but no. This sounds like a good idea as you
are banking on the 'mm' being the 'active mm'.

sounds like two birds in one shot, I think.

On ia64, we have "tpa" instruction which does the virtual to physical
address conversion for us. But talking to Tony, that will fault during not
present or vhpt misses.

Well, for now, manual walk is probably the best we have.

thanks,
suresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
