Received: from funky.monkey.org (smtp@funky.monkey.org [152.160.231.196])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA07879
	for <linux-mm@kvack.org>; Fri, 28 May 1999 01:31:06 -0400
Date: Fri, 28 May 1999 01:30:58 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [PATCHES]
In-Reply-To: <14157.55202.444836.684237@dukat.scot.redhat.com>
Message-ID: <Pine.BSF.4.03.9905280125360.18892-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 May 1999, Stephen C. Tweedie wrote:
> Fixed patch for 2.2.9 is at
> 
> ftp://ftp.uk.linux.org/pub/linux/sct/fs/misc/fsync-2.2.9-a.diff

oops... one more thing.  invalidate_buffers() and set_blocksize() both
need to call remove_inode_queue() for each reclaimed buffer, and
create_buffers() should set b_inode to NULL on all the new buffers on a
page, for cleanliness.  IMHO.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
