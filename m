Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA30112
	for <linux-mm@kvack.org>; Wed, 1 Jul 1998 18:14:52 -0400
Date: Wed, 1 Jul 1998 21:07:32 +0100
Message-Id: <199807012007.VAA04529@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: (reiserfs) Re: More on Re: (reiserfs) Reiserfs and ext2fs (was Re: (reiserfs) Sum Benchmarks (these look typical?))
In-Reply-To: <m13ecl7m25.fsf@flinx.npwt.net>
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
	<199806301610.RAA00957@dax.dcs.ed.ac.uk>
	<m1n2au77ck.fsf@flinx.npwt.net>
	<199807010912.KAA00789@dax.dcs.ed.ac.uk>
	<m13ecl7m25.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Hans Reiser <reiser@ricochet.net>, Shawn Leas <sleas@ixion.honeywell.com>, Reiserfs <reiserfs@devlinux.com>, Ken Tetrick <ktetrick@ixion.honeywell.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 01 Jul 1998 08:11:46 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

ST> Read the source code!  We already do this.  If one process or thread
ST> msync()s a mapped file, its dirty pages get written to disk,
ST> independently of any other processes on the same or other CPUs which
ST> may still have the pages mapped and may still be writing to them.  We
ST> don't unmap pages for write; we just mark them non-dirty around all
ST> ptes.

> I just took the time and looked.  

> And in buffer.c in get_hash_table if we are returning a locked buffer,
> we always wait on that buffer until it is unlocked.  So to date we I
> don't see us tempting fate, with writing to locked buffers.

Whoops, yes, we do currently do copies for msync().  It's been too long
since I was digging in that code...

--Stephen
