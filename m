Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA19523
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 19:27:53 -0400
Date: Wed, 7 Apr 1999 00:31:55 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <14090.31508.740918.361855@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.05.9904070028180.1211-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 1999, Stephen C. Tweedie wrote:

>> -#define i (((unsigned long) inode)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
>> +#define i (((unsigned long) inode-PAGE_OFFSET)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
>
>This just ends up adding or subtracting a constant to the hash function,
>so won't have any effect at all on the occupancy distribution of the
>hash buckets.

My point is that PAGE_HASH_BITS is < of 32/2.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
