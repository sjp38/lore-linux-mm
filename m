Message-ID: <3D485775.14A8B483@zip.com.au>
Date: Wed, 31 Jul 2002 14:32:37 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: throttling dirtiers
References: <20020731171456.S10270@redhat.com> <Pine.LNX.4.44L.0207311824450.23404-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Benjamin LaHaise <bcrl@redhat.com>, William Lee Irwin III <wli@holomorphy.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Wed, 31 Jul 2002, Benjamin LaHaise wrote:
> > On Wed, Jul 31, 2002 at 02:02:03PM -0700, Andrew Morton wrote:
> > > But let's back off a bit.   The problem is that a process
> > > doing a large write() can penalise innocent processes which
> > > want to allocate memory.
> > >
> > > How to fix that?
> >
> > First off, make it obvious where we block in the allocation path (pawning
> > off all memory reaping to kswapd et al is an easy first step here).  Then
> > make allocators cycle through on a FIFO basis by using something like the
> > page reservation patch I came up with a while ago.  That'll give us an
> > easy place to change scheduling behaviour.
> 
> These ingredients are already in 2.4-rmap.

It doesn't seem to work.  The -ac kernel has weird stalls on storms
of ext3 writeback.  It's quite irritating, although probably not to
do with the VM.

The scheduler in the -ac kernel is also bad.  Start a kernel build
and things like X apps and gdb become hugely slow.  2.5 is like that
too.  I'll be going back to Marcelo.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
