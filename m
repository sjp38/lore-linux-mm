Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA19547
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 19:28:24 -0400
Date: Wed, 7 Apr 1999 00:27:21 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <14090.32072.214506.83641@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.05.9904070007330.1141-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Doug Ledford <dledford@redhat.com>, Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Mark Hemment <markhe@sco.COM>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 1999, Stephen C. Tweedie wrote:

>Trees are bad for this sort of thing in general: they can be as fast as
>hashing for lookup, but are much slower for insert and delete
>operations.  Insert and delete for the page cache _must_ be fast.

It's not so obvious to me. I sure agree that an O(n) insertion/deletion is
far too slow but a O(log(n)) for everything could be rasonable to me. And
trees don't worry about unluky hash behavior.

And for the record my plan would be to put the top of the tree directly in
the inode struct. And then to queue all cached pages that belongs to such
inode in the per-inode cache-tree. So there would be no need to always
check also the inode field in find_inode() and reading small files would
be _drammatically_ fast and immediate even if there are 5giga of cache
allocated. I think this behavior will become interesting.

Maybe you are 100% right in telling me that RB-trees will lose, but I
would like to try it out someday...

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
