Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA17762
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 17:22:51 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14090.31508.740918.361855@dukat.scot.redhat.com>
Date: Tue, 6 Apr 1999 22:22:28 +0100 (BST)
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.LNX.4.05.9904061934380.1017-100000@laser.random>
References: <Pine.LNX.4.05.9904061831340.394-100000@laser.random>
	<Pine.LNX.4.05.9904061934380.1017-100000@laser.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Chuck Lever <cel@monkey.org>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 6 Apr 1999 20:07:57 +0200 (CEST), Andrea Arcangeli
<andrea@e-mind.com> said:

> I was looking at the inode pointer part of the hash function and I think
> something like this should be better.

> -#define i (((unsigned long) inode)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
> +#define i (((unsigned long) inode-PAGE_OFFSET)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))

This just ends up adding or subtracting a constant to the hash function,
so won't have any effect at all on the occupancy distribution of the
hash buckets.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
