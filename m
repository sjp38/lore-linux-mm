Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA23174
	for <linux-mm@kvack.org>; Tue, 30 Jun 1998 15:09:05 -0400
Date: Tue, 30 Jun 1998 17:10:46 +0100
Message-Id: <199806301610.RAA00957@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: (reiserfs) Re: More on Re: (reiserfs) Reiserfs and ext2fs (was Re: (reiserfs) Sum Benchmarks (these look typical?))
In-Reply-To: <m1u354dlna.fsf@flinx.npwt.net>
References: <Pine.HPP.3.96.980617035608.29950A-100000@ixion.honeywell.com>
	<199806221138.MAA00852@dax.dcs.ed.ac.uk>
	<358F4FBE.821B333C@ricochet.net>
	<m11zsgrvnf.fsf@flinx.npwt.net>
	<199806241154.MAA03544@dax.dcs.ed.ac.uk>
	<m11zse6ecw.fsf@flinx.npwt.net>
	<199806251100.MAA00835@dax.dcs.ed.ac.uk>
	<m1emwcf97d.fsf@flinx.npwt.net>
	<199806291035.LAA00733@dax.dcs.ed.ac.uk>
	<m1u354dlna.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Hans Reiser <reiser@ricochet.net>, Shawn Leas <sleas@ixion.honeywell.com>, Reiserfs <reiserfs@devlinux.com>, Ken Tetrick <ktetrick@ixion.honeywell.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 29 Jun 1998 14:59:37 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

> There are two problems I see.  

> 1) A DMA controller actively access the same memory the CPU is
> accessing could be a problem.  Recall video flicker on old video
> cards.

Shouldn't be a problem.

> 2) More importantly the cpu writes to the _cache_, and the DMA
> controller reads from the RAM.  I don't see any consistency garnatees
> there.  We may be able solve these problems on a per architecture or
> device basis however.

Again, not important.  If we ever modify a page which is already being
written out to a device, then we mark that page dirty.  On write, we
mark it clean (but locked) _before_ starting the IO, not after.  So, if
there is ever an overlap of a filesystem/mmap write with an IO to disk,
we will always schedule another IO later to clean the re-dirtied
buffers.

--Stephen
