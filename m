Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA04511
	for <linux-mm@kvack.org>; Thu, 27 May 1999 19:39:26 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14157.55202.444836.684237@dukat.scot.redhat.com>
Date: Fri, 28 May 1999 00:39:14 +0100 (BST)
Subject: Re: [PATCHES]
In-Reply-To: <Pine.BSF.4.03.9905271552420.16505-100000@funky.monkey.org>
References: <14156.58667.141026.238904@dukat.scot.redhat.com>
	<Pine.BSF.4.03.9905271552420.16505-100000@funky.monkey.org>
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 27 May 1999 15:55:37 -0400 (EDT), Chuck Lever <cel@monkey.org> said:

> this patch appears to combine the "block allocation deadlock" patch with
> the original fsync reimplementation... correct?

Yep, and that was unintentional.  Fixed.

> have you experienced and/or fixed the 5-second self-destruct problem i
> mentioned to you?

No, and yes --- I needed to add an invalidate_inode_buffers() during
inode invalidation.  Unmounting with writes pending appears to work fine
now.

Fixed patch for 2.2.9 is at

ftp://ftp.uk.linux.org/pub/linux/sct/fs/misc/fsync-2.2.9-a.diff

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
