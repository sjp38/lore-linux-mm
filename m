Received: from bolivar.varner.com (root@bolivar.varner.com [208.236.160.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA01542
	for <linux-mm@kvack.org>; Thu, 2 Jul 1998 11:36:05 -0400
Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by bolivar.varner.com (8.8.5/8.8.5) with ESMTP id KAA06475
	for <linux-mm@kvack.org>; Thu, 2 Jul 1998 10:36:20 -0500 (CDT)
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
	<m13ecl7m25.fsf@flinx.npwt.net>
	<199807012007.VAA04529@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 02 Jul 1998 10:17:56 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Wed, 1 Jul 1998 21:07:32 +0100
Message-ID: <m1lnqc5ljv.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Hans Reiser <reiser@ricochet.net>, Shawn Leas <sleas@ixion.honeywell.com>, Reiserfs <reiserfs@devlinux.com>, Ken Tetrick <ktetrick@ixion.honeywell.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:
>> I just took the time and looked.  

>> And in buffer.c in get_hash_table if we are returning a locked buffer,
>> we always wait on that buffer until it is unlocked.  So to date we I
>> don't see us tempting fate, with writing to locked buffers.

ST> Whoops, yes, we do currently do copies for msync().  It's been too long
ST> since I was digging in that code...

Well I asked on Linux kernel and talked a little bit about this with Alan Cox.
He figures if we try and stop something like DMA half way through we
are in trouble but otherwise we should be o.k.

So for the next round I'll implement the cheap clear the dirty bit, on
the page tables trick.

Eric
