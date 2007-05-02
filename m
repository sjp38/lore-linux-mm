Date: Wed, 2 May 2007 11:42:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22 -mm merge plans: slub
Message-Id: <20070502114233.30143b0b.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705021124040.646@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
	<20070501125559.9ab42896.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0705020955550.32271@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0705021903320.20615@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0705021124040.646@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007 11:28:26 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 2 May 2007, Hugh Dickins wrote:
> 
> > On Wed, 2 May 2007, Christoph Lameter wrote:
> > > 
> > > But these are arch specific problems. We could use 
> > > ARCH_USES_SLAB_PAGE_STRUCT to disable SLUB on these platforms.
> > 
> > As a quick hack, sure.  But every ARCH_USES_SLAB_PAGE_STRUCT
> > diminishes the testing SLUB will get.  If the idea is that we're
> > going to support both SLAB and SLUB, some arches with one, some
> > with another, some with either, for more than a single release,
> > then I'm back to saying SLUB is being pushed in too early.
> > I can understand people wanting pluggable schedulers,
> > but pluggable slab allocators?
> 
> This is a sensitive piece of the kernel as you say and we better allow the 
> running of two allocator for some time to make sure that it behaves in all 
> load situations. The design is fundamentally different so its performance 
> characteristics may diverge significantly and perhaps there will be corner 
> cases for each where they do the best job.

eek.  We'd need to fix those corner cases then.  Our endgame
here really must be rm mm/slab.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
