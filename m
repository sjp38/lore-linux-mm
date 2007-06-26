Date: Tue, 26 Jun 2007 11:38:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 12/26] SLUB: Slab defragmentation core
Message-Id: <20070626113823.d78d8c0c.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0706261114320.18010@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com>
	<20070618095916.297690463@sgi.com>
	<20070626011831.181d7a6a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0706261114320.18010@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2007 11:19:26 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

>  
> > But slab_lock() isn't taken for slabs whose objects are larger than 
> > PAGE_SIZE. How's that handled?
> 
> slab lock is always taken. How did you get that idea?

Damned if I know.  Perhaps by reading slob.c instead of slub.c.  When can
we start deleting some slab implementations?

> > How much testing has been done on this code, and of what form, and with
> > what results?
> 
> I posted them in the intro of the last full post and then Michael 
> Piotrowski did some stress tests.
> 
> See http://marc.info/?l=linux-mm&m=118125373320855&w=2

hm, OK, thin.

I think we'll need to come up with a better-than-usual test plan for this
change.  One starting point might be to ask what in-the-field problem
you're trying to address here, and what the results were.


Also, what are the risks of meltdowns in this code?  For example, it
reaches the magical 30% ratio, tries to do defrag, but the defrag is for
some reason unsuccessful and it then tries to run defrag again, etc.

And that was "for example"!  Are there other such potential problems in
there?  There usually are, with memory reclaim.


(Should slab_defrag_ratio be per-slab rather than global?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
