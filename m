Received: from firewall.aavid.com (firewall.aavid.com [199.92.156.104])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA12887
	for <linux-mm@kvack.org>; Thu, 9 Jul 1998 09:03:47 -0400
Message-ID: <005f01bdab39$abfe57a0$f80010ac@pc0411.aavid.com>
From: "Zachary Amsden" <amsdenz@aavid.com>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
Date: Thu, 9 Jul 1998 09:01:21 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="x-user-defined"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>


-----Original Message-----
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
To: Stephen C. Tweedie <sct@redhat.com>
Cc: Andrea Arcangeli <arcangeli@mbox.queen.it>; Linux MM
<linux-mm@kvack.org>; Linux Kernel <linux-kernel@vger.rutgers.edu>
Date: Thursday, July 09, 1998 3:50 AM
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]


>On Wed, 8 Jul 1998, Stephen C. Tweedie wrote:
>> <H.H.vanRiel@phys.uu.nl> said:
>>
>> > When my zone allocator is finished, it'll be a piece of
>> > cake to implement lazy page reclamation.
>>
>> I've already got a working implementation.  The issue of lazy
>> reclamation is pretty much independent of the allocator underneath; I
>> don't see it being at all hard to run the lazy reclamation stuff on
>top
>> of any form of zoned allocation.
>
>The problem with the current allocator is that it stores
>the pointers to available blocks in the blocks themselves.
>This means we can't wait till the last moment with lazy
>reclamation.


Presumably to reduce memory use, but at what cost?  It prevents
lazy reclamation and makes locating available blocks a major
headache.  It only takes 4k of memory to store a bitmap of free
blocks in a 128 Meg system.  Storing the free list in free space is
an admirable hack, but maybe outdated.

Zach Amsden
amsden@andrew.cmu.edu

P.S. I'm new to this discussion, so please don't flay me if
everything I said is in gross violation of the truth.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
