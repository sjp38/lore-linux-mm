Date: Mon, 9 Oct 2006 12:15:50 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: mm section mismatches
Message-Id: <20061009121550.f251efff.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0610091104530.27654@schroedinger.engr.sgi.com>
References: <20061006184930.855d0f0b.akpm@google.com>
	<20061006211005.56d412f1.rdunlap@xenotime.net>
	<20061006234609.641f42f4.akpm@osdl.org>
	<20061007105859.70e2f44d.rdunlap@xenotime.net>
	<Pine.LNX.4.64.0610091104530.27654@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2006 11:06:00 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Sat, 7 Oct 2006, Randy Dunlap wrote:
> 
> > > > > WARNING: vmlinux - Section mismatch: reference to .init.data:initkmem_list3 from .text between 'set_up_list3s' (at offset 0xc016ba8e) and 'kmem_flagcheck'
> > > 
> > > This is non-init set_up_list3s() referring to __initdata initkmem_list3[]
> > > (Hi, Pekka and Christoph!)
> > 
> > I can't repro that one either, so I'll let one of (...) fix it.
> 
> 
> set_up_list3s is only called during the bootstrap of the slab allocator. 
> So this is fine.

Except it'll generate a scary warning for evermore.

It'd be nice to find some hack to make the warning go away, but I can't
think of one.

Maybe create a new section just for this purpose, put the function in that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
