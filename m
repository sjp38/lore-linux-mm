Date: Tue, 27 Feb 2001 01:41:51 +0100
From: Christoph Hellwig <hch@caldera.de>
Subject: Re: 2.5 page cache improvement idea
Message-ID: <20010227014150.A5426@caldera.de>
References: <Pine.LNX.4.30.0102261829330.5576-100000@today.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.30.0102261829330.5576-100000@today.toronto.redhat.com>; from bcrl@redhat.com on Mon, Feb 26, 2001 at 06:46:24PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 26, 2001 at 06:46:24PM -0500, Ben LaHaise wrote:
> Hey folks,
> 
> Here's an idea I just bounced off of Rik that seems like it would be
> pretty useful.  Currently the page cache hash is system wide.  For 2.5,
> I'm suggesting that we make the page cache hash a per-inode structure and
> possibly move the page index and mapping into the structure's information.
> Also, for dealing with hash collisions (which are going to happen under
> certain well known circumstances), we could move to a b*tree structure
> hanging off of the hashes.  So we'd have a data structure that looks like
> the following:
> 
> 
> inode

Shouldn't this be address_space instead?

>
> 	-> hash table
> 		-> struct page, index, mapping
> 		-> head of b*tree for overflow
> 
> page
> 	-> pointer back to hash bucket/b*tree entry
> 
> These changes would replace ~20 bytes in struct page with one pointer.

Looks sane - the elimination of a systemwide resource should improve
scalability a lot - if it comes together with size reduction of major
structure only the side effects need some thoughs :P

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
