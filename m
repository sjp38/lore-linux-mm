Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA28234
	for <linux-mm@kvack.org>; Wed, 1 Jul 1998 10:31:58 -0400
Subject: Re: (reiserfs) Re: More on Re: (reiserfs) Reiserfs and ext2fs (was Re: (reiserfs) Sum Benchmarks (these look typical?))
References: <Pine.HPP.3.96.980617035608.29950A-100000@ixion.honeywell.com>
	<199806221138.MAA00852@dax.dcs.ed.ac.uk>
	<358F4FBE.821B333C@ricochet.net> <m11zsgrvnf.fsf@flinx.npwt.net>
	<199806241154.MAA03544@dax.dcs.ed.ac.uk>
	<m11zse6ecw.fsf@flinx.npwt.net>
	<199806251100.MAA00835@dax.dcs.ed.ac.uk>
	<m1emwcf97d.fsf@flinx.npwt.net>
	<199806291035.LAA00733@dax.dcs.ed.ac.uk>
	<m1u354dlna.fsf@flinx.npwt.net>
	<199806301610.RAA00957@dax.dcs.ed.ac.uk>
	<m1n2au77ck.fsf@flinx.npwt.net>
	<199807010912.KAA00789@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 01 Jul 1998 07:45:47 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Wed, 1 Jul 1998 10:12:40 +0100
Message-ID: <m14sx17n9g.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Hans Reiser <reiser@ricochet.net>, Shawn Leas <sleas@ixion.honeywell.com>, Reiserfs <reiserfs@devlinux.com>, Ken Tetrick <ktetrick@ixion.honeywell.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi,
ST> On 30 Jun 1998 19:17:15 -0500, ebiederm+eric@npwt.net (Eric
ST> W. Biederman) said:

>> When either I trace through the code, or a hardware guy convinces me,
>> that it is safe to both write to a page, and do DMA from a page
>> simultaneously I'll believe it.

ST> Read the source code!  We already do this.  If one process or thread
ST> msync()s a mapped file, its dirty pages get written to disk,
ST> independently of any other processes on the same or other CPUs which
ST> may still have the pages mapped and may still be writing to them.  We
ST> don't unmap pages for write; we just mark them non-dirty around all
ST> ptes.

Which is fine but, it still (currently) gets copied to the buffer cache.
As the buffer cache leaves the picture...

Eric
