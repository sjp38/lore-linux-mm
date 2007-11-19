Received: from toip6.srvr.bell.ca ([209.226.175.125])
          by tomts22-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071119190548.SSMT18413.tomts22-srv.bellnexxia.net@toip6.srvr.bell.ca>
          for <linux-mm@kvack.org>; Mon, 19 Nov 2007 14:05:48 -0500
Date: Mon, 19 Nov 2007 14:00:40 -0500
From: Mathieu Desnoyers <compudj@krystal.dyndns.org>
Subject: Re: [RFC 5/7] LTTng instrumentation mm
Message-ID: <20071119190040.GA1609@Krystal>
References: <20071113193349.214098508@polymtl.ca> <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost> <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost> <20071116144742.GA17255@Krystal> <1195495626.27759.119.camel@localhost> <20071119185258.GA998@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <20071119185258.GA998@Krystal>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

* Mathieu Desnoyers (mathieu.desnoyers@polymtl.ca) wrote:
> * Dave Hansen (haveblue@us.ibm.com) wrote:
> > On Fri, 2007-11-16 at 09:47 -0500, Mathieu Desnoyers wrote:
> > > * Dave Hansen (haveblue@us.ibm.com) wrote:
> > > > For most (all?) architectures, the PFN and the virtual address in the
> > > > kernel's linear are interchangeable with pretty trivial arithmetic.  All
> > > > pages have a pfn, but not all have a virtual address.  Thus, I suggested
> > > > using the pfn.  What kind of virtual addresses are you talking about?
> > > > 
> > > 
> > > Hrm, in asm-generic/memory_model.h, we have various versions of
> > > __page_to_pfn. Normally they all cast the result to (unsigned long),
> > > except for :
> > > 
> > > 
> > > #elif defined(CONFIG_SPARSEMEM_VMEMMAP)
> > > 
> > > /* memmap is virtually contigious.  */
> > > #define __pfn_to_page(pfn)      (vmemmap + (pfn))
> > > #define __page_to_pfn(page)     ((page) - vmemmap)
> > > 
> > > So I guess the result is a pointer ? Should this be expected ?
> > 
> > Nope.  'pointer - pointer' is an integer.  Just solve this equation for
> > integer:
> > 
> > 	'pointer + integer = pointer'
> > 
> 
> Well, using page_to_pfn turns out to be ugly in markers (and in
> printks) then. Depending on the architecture, it will result in either
> an unsigned long (x86_64) or an unsigned int (i386), which corresponds

Well, it's signed long and signed int, but the point is still valid.

> to %lu or %u and will print a warning if we don't cast it explicitly.
> 
> Mathieu
> 
> 
> > -- Dave
> > 
> 
> -- 
> Mathieu Desnoyers
> Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
> OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
