Date: Mon, 12 Dec 2005 05:51:46 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 1/6] Framework
Message-ID: <20051212045146.GA11190@wotan.suse.de>
References: <20051210005440.3887.34478.sendpatchset@schroedinger.engr.sgi.com> <20051210005445.3887.94119.sendpatchset@schroedinger.engr.sgi.com> <439CF2A2.60105@yahoo.com.au> <20051212035631.GX11190@wotan.suse.de> <439CF93D.5090207@yahoo.com.au> <20051212042142.GZ11190@wotan.suse.de> <439CFC67.4030107@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <439CFC67.4030107@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

> >With local_t you don't need to turn off interrupts
> >anymore.
> >
> 
> Then you can't use __local_xxx, and so many architectures will use
> atomic instructions (the ones who don't are the ones with tripled
> cacheline footprint of this structure).

They are wrong then. atomic instructions is the wrong implementation
and they would be better off with asm-generic. 

If anything they should use per_cpu counters for interrupts and 
use seq locks. Or just turn off the interrupts for a short time
in the low level code.

> 
> Sure i386 and x86-64 are happy, but this would probably slow down
> most other architectures.

I think it is better to fix the other architectures then - if they
are really using a full scale bus lock for this they're just wrong.

I don't think it is a good idea to do a large change in generic
code just for dumb low level code.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
