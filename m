Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA12991
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 10:03:19 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14090.5138.562574.858572@dukat.scot.redhat.com>
Date: Tue, 6 Apr 1999 15:02:58 +0100 (BST)
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.BSF.4.03.9904051658150.25730-100000@funky.monkey.org>
References: <Pine.LNX.4.05.9904050033340.779-100000@laser.random>
	<Pine.BSF.4.03.9904051658150.25730-100000@funky.monkey.org>
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: Andrea Arcangeli <andrea@e-mind.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi, 

On Mon, 5 Apr 1999 17:31:43 -0400 (EDT), Chuck Lever <cel@monkey.org>
said:

> hmmm.  wouldn't you think that hashing with the low order bits in the
> offset would cause two different offsets against the same page to result
> in the hash function generating different output?  

We always, always use page-aligned lookups for the page cache.
(Actually there is one exception: certain obsolete a.out binaries, which
are demand paged with the pages beginning at offset 1K into the binary.
We don't support cache coherency for those and we don't support them at
all on filesystems with a >1k block size.  It doesn't impact on the hash
issue.)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
