Message-ID: <3D48504B.9520455D@zip.com.au>
Date: Wed, 31 Jul 2002 14:02:03 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: throttling dirtiers
References: <3D479F21.F08C406C@zip.com.au> <20020731200612.GJ29537@holomorphy.com> <20020731162357.Q10270@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:
> 
> On Wed, Jul 31, 2002 at 01:06:12PM -0700, William Lee Irwin III wrote:
> > I'm not a fan of this kind of global decision. For example, I/O devices
> > may be fast enough and memory small enough to dump all memory in < 1s,
> > in which case dirtying most or all of memory is okay from a latency
> > standpoint, or it may take hours to finish dumping out 40% of memory,
> > in which case it should be far more eager about writeback.
> 
> Why?  Filling the entire ram with dirty pages is okay, and in fact you
> want to support that behaviour for apps that "just fit" (think big
> scientific apps).  The only interesting point is that when you hit the
> limit of available memory, the system needs to block on *any* io
> completing and resulting in clean memory (which is reasonably low
> latency), not a specific io which may have very high latency.
> 

I hear what you say.  Sometimes we want to allow a lot of
writeback buffering.  But sometimes we don't.

But let's back off a bit.   The problem is that a process
doing a large write() can penalise innocent processes which
want to allocate memory.

How to fix that?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
