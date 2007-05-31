Date: Wed, 30 May 2007 23:41:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <20070531061836.GL4715@minantech.com>
Message-ID: <Pine.LNX.4.64.0705302335050.6733@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
 <1180544104.5850.70.camel@localhost> <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com>
 <20070531061836.GL4715@minantech.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 31 May 2007, Gleb Natapov wrote:

> On Wed, May 30, 2007 at 10:56:17AM -0700, Christoph Lameter wrote:
> > > You don't get COW if it's a shared mapping.  You use the page cache
> > > pages which ignores my mbind().  That's my beef!  [;-)]
> > 
> > page cache pages are subject to a tasks memory policy regardless of how we 
> > get to the page cache page. I think that is pretty consistent.
> > 
> I am a little bit confused here. If two processes mmap some file with
> MAP_SHARED and each one marks different part of the file with
> numa_setlocal_memory() (and suppose that no pages were faulted in for

The numa_setlocal_memory() has no effect on ranges that map pagecache 
pages.

> this file yet). Now first process touches a part of the file that was
> marked local by second process. Will faulted page  be placed in first
> process' local memory or second? I surely expect later, but it seems I
> am wrong.

The faulted page will use the memory policy of the task that faulted it 
in. If that process has numa_set_localalloc() set then the page will be 
located as closely as possible to the allocating thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
