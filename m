Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA18423
	for <linux-mm@kvack.org>; Mon, 8 Feb 1999 11:39:51 -0500
Date: Mon, 8 Feb 1999 16:39:20 GMT
Message-Id: <199902081639.QAA03290@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: [PATCH] Re: swapcache bug?
In-Reply-To: <36BDD9B2.8718B21@stud.uni-sb.de>
References: <36BDD9B2.8718B21@stud.uni-sb.de>
Sender: owner-linux-mm@kvack.org
To: masp0008@stud.uni-sb.de, Linus Torvalds <torvalds@transmeta.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 07 Feb 1999 19:21:38 +0100, Manfred Spraul
<masp0008@stud.uni-sb.de> said:

> I'm currently debugging my physical memory ramdisk, and I see lots of
> entries in the page cache that have 'page->offset' which aren't
> multiples of 4096. (they are multiples of 256)
> All of them belong to swapper_inode.

That is normal.

> If this is the intended behaviour, then page_hash() should be changed:
> it assumes that 'page->offset' is a multiple of 4096.

Good point, the line include/linux/pagemap.h:39,

	return s(i+o) & (PAGE_HASH_SIZE-1);

should probably be 

	return s(i+o+offset) & (PAGE_HASH_SIZE-1);

to mix in the low order bits for swap entries.  Well spotted.  Anyone
see anything wrong with this one-liner change?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
