Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA31317
	for <linux-mm@kvack.org>; Mon, 27 Jul 1998 15:48:51 -0400
Date: Mon, 27 Jul 1998 12:02:02 +0100
Message-Id: <199807271102.MAA00713@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <Pine.LNX.4.02.9807260941230.276-100000@iddi.npwt.net>
References: <87iukovq42.fsf@atlas.CARNet.hr>
	<Pine.LNX.4.02.9807260941230.276-100000@iddi.npwt.net>
Sender: owner-linux-mm@kvack.org
To: ebiederm+eric@npwt.net
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 26 Jul 1998 09:49:02 -0500 (CDT), Eric W Biederman
<eric@flinx.npwt.net> said:

> From where I sit it looks completly possible to give the buffer cache a
> fake inode, and have it use the same mechanisms that I have developed for
> handling other dirty data in the page cache.  It should also be possible
> in this effort to simplify the buffer_head structure as well.

> As time permits I'll move in that direction.

You'd still have to persuade people that it's a good idea.  I'm not
convinced.

The reason for having things in the page cache is for fast lookup.
For this to make sense for the buffer cache, you'd have to align the
buffer cache on page boundaries, but buffers on disk are not naturally
aligned this way.  You'd end up wasting a lot of space as perhaps only
a few of the buffers in any page were useful, and you'd also have to
keep track of which buffers within the page were valid/dirty.

We *need* a mechanism which is block-aligned, not page-aligned.  The
buffer cache is a good way of doing it.  Forcing block device caching
into a page-aligned cache is not necessarily going to simplify things.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
