Received: from funky.monkey.org (smtp@funky.monkey.org [152.160.231.196])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA02088
	for <linux-mm@kvack.org>; Thu, 27 May 1999 15:55:48 -0400
Date: Thu, 27 May 1999 15:55:37 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [PATCHES]
In-Reply-To: <14156.58667.141026.238904@dukat.scot.redhat.com>
Message-ID: <Pine.BSF.4.03.9905271552420.16505-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 May 1999, Stephen C. Tweedie wrote:
> However, this brings up another point: 
> 
> 	ftp://ftp.uk.linux.org/pub/linux/sct/fs/misc/fsync-2.2.8-v5.diff
> 
> is a set of diffs to fix fsync performance on 2.2.  It fully implements
> fsync and fdatasync, and applies the same optimisations to O_SYNC.  It
> uses per-inode dirty buffer lists.

stephen -

this patch appears to combine the "block allocation deadlock" patch with
the original fsync reimplementation... correct?

have you experienced and/or fixed the 5-second self-destruct problem i
mentioned to you?

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
