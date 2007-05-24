Date: Thu, 24 May 2007 06:24:31 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524042431.GA12121@wotan.suse.de>
References: <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com> <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com> <20070523061702.GA9449@wotan.suse.de> <20070523074636.GA10070@wotan.suse.de> <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com> <20070524032417.GC14349@wotan.suse.de> <Pine.LNX.4.64.0705232048120.24352@schroedinger.engr.sgi.com> <20070524040149.GB20252@wotan.suse.de> <Pine.LNX.4.64.0705232103260.24495@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705232103260.24495@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 09:05:20PM -0700, Christoph Lameter wrote:
> On Thu, 24 May 2007, Nick Piggin wrote:
> 
> > > Well as far as I understand Matt it seems that you still need 2 bytes per 
> > > alloc. That is still more than 0 that SLUB needs.
> > 
> > That's true, but I think the more relevant number is that SLUB needs
> > 400K more memory to boot into /bin/bash.
> 
> I am bit amazed by that. Where is that memory going to?

Well, you tell me, you're the SLUB guy ;)


> What page size 
> does the system have?
> 
> If we have 4k pages there then this boils down to 100 pages.

Yep, 4K pages.

 
> Does booting with
> 
> slub_max_order=0
> 
> change things?

With that, `free` alternates between telling me 764 and 768K free
(without the parameter, it would alternate between 756 and 760). So
yes, marginally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
