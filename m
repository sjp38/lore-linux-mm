Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA18621
	for <linux-mm@kvack.org>; Fri, 28 May 1999 21:25:09 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14159.16854.992122.731801@dukat.scot.redhat.com>
Date: Sat, 29 May 1999 02:24:38 +0100 (BST)
Subject: Re: [PATCHES]
In-Reply-To: <Pine.BSF.4.03.9905280125360.18892-100000@funky.monkey.org>
References: <14157.55202.444836.684237@dukat.scot.redhat.com>
	<Pine.BSF.4.03.9905280125360.18892-100000@funky.monkey.org>
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 28 May 1999 01:30:58 -0400 (EDT), Chuck Lever <cel@monkey.org> said:

> On Fri, 28 May 1999, Stephen C. Tweedie wrote:
>> Fixed patch for 2.2.9 is at
>> 
>> ftp://ftp.uk.linux.org/pub/linux/sct/fs/misc/fsync-2.2.9-a.diff

> oops... one more thing.  invalidate_buffers() and set_blocksize() both
> need to call remove_inode_queue() for each reclaimed buffer, 

Quite right --- done.  I've now checked that there aren't any other
places where we clear BH_Dirty.  Updated patch in the usual place.

> and create_buffers() should set b_inode to NULL on all the new buffers
> on a page, for cleanliness.  IMHO.

New buffer_heads are preinitialised to all-zeros anyway (search buffer.c
for "memset").

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
