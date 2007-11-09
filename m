Date: Fri, 9 Nov 2007 13:10:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] x86_64: Configure stack size
Message-Id: <20071109131057.a78c914b.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0711091242200.16284@schroedinger.engr.sgi.com>
References: <20071107004357.233417373@sgi.com>
	<20071107004710.862876902@sgi.com>
	<20071107191453.GC5080@shadowen.org>
	<200711080012.06752.ak@suse.de>
	<Pine.LNX.4.64.0711071639491.4640@schroedinger.engr.sgi.com>
	<20071109121332.7dd34777.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0711091242200.16284@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: ak@suse.de, apw@shadowen.org, linux-mm@kvack.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007 12:45:06 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 9 Nov 2007, Andrew Morton wrote:
> 
> > otoh, I doubt if anyone will actually ship an NR_CPUS=16384 kernel, so it
> > isn't terribly pointful.
> 
> Our competition (Cray) just announced a product featuring up to 21k 
> cpus although that is a cluster. We are definitely getting there...

I'm talking about software, not hardware.  I'd expect that you'll have
trouble talking RH/suse/etc into general shipping of an NR_CPUS=16384
kernel.

If I'm correct than I'd have thought that this will be a significant
problem for SGI, so we should find other solutions.

> > So I'm wobbly.  Could we please examine the alternatives before proceeding?
> 
> This works fine with a 32k stack on IA64 with 4k processors.

yeah, but that's an order-1 allocation on ia64, not an order-3.

> So I tend to 
> think of this as a solution that is already working on another platform. 
> An 8k stack is also going to be tough with 4k processors on x86_64 which 
> we will have soon.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
