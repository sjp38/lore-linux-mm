Date: Fri, 9 Nov 2007 13:19:11 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/2] x86_64: Configure stack size
In-Reply-To: <20071109131057.a78c914b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0711091313040.16547@schroedinger.engr.sgi.com>
References: <20071107004357.233417373@sgi.com> <20071107004710.862876902@sgi.com>
 <20071107191453.GC5080@shadowen.org> <200711080012.06752.ak@suse.de>
 <Pine.LNX.4.64.0711071639491.4640@schroedinger.engr.sgi.com>
 <20071109121332.7dd34777.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0711091242200.16284@schroedinger.engr.sgi.com>
 <20071109131057.a78c914b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ak@suse.de, apw@shadowen.org, linux-mm@kvack.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007, Andrew Morton wrote:

> I'm talking about software, not hardware.  I'd expect that you'll have
> trouble talking RH/suse/etc into general shipping of an NR_CPUS=16384
> kernel.

Yeah that is one reason why I removed all percpu arrays from the kernel 
with the cpu_alloc patchset. I think we can get to a point where this does 
not hurt that much. We want to be as close as possible to a distro kernel 
as possible.
 
> > If I'm correct than I'd have thought that this will be a significant
> problem for SGI, so we should find other solutions.

Maybe a special kernel from the distros is unavoidable but then they have 
done that in the past for us too. Certainly we do not want to have the 
kernel patches just for HPC apps. This is an option after all and not a 
default. Mike Travis is working on reducing the per cpu overhead in the 
x86_64 arch code. So we should be getting to a pretty good situation even 
if we have to leave the cpumasks alone.

> > > So I'm wobbly.  Could we please examine the alternatives before proceeding?
> > 
> > This works fine with a 32k stack on IA64 with 4k processors.
> 
> yeah, but that's an order-1 allocation on ia64, not an order-3.

Well the default is also an order-1 allocation on x86_64. The order-3 
alloc is not going to be that much of a problem if you have a system with 
several terabytes of RAM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
