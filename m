Received: from flinx.npwt.net (inetnebr@oma-pm1-030.inetnebr.com [206.222.220.74])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA12907
	for <linux-mm@kvack.org>; Thu, 20 Aug 1998 10:30:47 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807271102.MAA00713@dax.dcs.ed.ac.uk>
	<Pine.LNX.4.02.9808020002110.424-100000@iddi.npwt.net>
	<199808171535.QAA03051@dax.dcs.ed.ac.uk>
From: ebiederm@inetnebr.com (Eric W. Biederman)
Date: 20 Aug 1998 07:40:13 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Mon, 17 Aug 1998 16:35:48 +0100
Message-ID: <m1soirj07m.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi,
ST> On Sun, 2 Aug 1998 00:19:52 -0500 (CDT), Eric W Biederman
ST> <eric@flinx.npwt.net> said:

>> What I was envisioning is using a single write-out daemon 
>> instead of 2 (one for buffer cache, one for page cache).  Using the same
>> tests in shrink_mmap.  Reducing the size of a buffer_head by a lot because
>> consolidating the two would reduce the number of lists needed.  
>> To sit the buffer cache upon a single pseudo inode, and keep it's current
>> hashing scheme.

ST> The only reason we currently have two daemons 
But I have 3.
One for writing dirty data in the buffer cache. bdflush
One for writing dirty data in the page cache.   pgflush
One for reclaiming clean memory                 kswapd

I would like to merge bdflush and pgflush in the long run if I can. 
Since pgflush is more generic than bdflush it should be doable.
This happens to give a degree of page cache and buffer cache unification
as a side effect, of setting up the buffer cache to use pgflush.

ST> is that we need one for
ST> writing dirty memory and another for reclaiming clean memory.  That way,
ST> even when we stall for disk writes, we are still able to reclaim free
ST> memory via shrink_mmap().  The kswapd daemon and the shrink_mmap() code
ST> already treat the page cache and buffer cache both the same.

I was talking of integrating my ``dirty data in the page cache'' code,
in with the rest of the kernel.  Hopefully for early 2.3.

My apologies for being so unclear  you totally missed what I was talking about.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
