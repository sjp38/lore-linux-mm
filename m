Received: from mea.tmt.tele.fi (mea.tmt.tele.fi [194.252.70.162])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA06598
	for <linux-mm@kvack.org>; Tue, 25 May 1999 18:18:44 -0400
Subject: Re: Q: PAGE_CACHE_SIZE?
In-Reply-To: <Pine.LNX.4.03.9905252213400.25857-100000@mirkwood.nl.linux.org> from Rik van Riel at "May 25, 99 10:16:34 pm"
Date: Wed, 26 May 1999 01:17:53 +0300 (EEST)
From: Matti Aarnio <matti.aarnio@sonera.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <19990525221804Z92392-10847+102@mea.tmt.tele.fi>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@nl.linux.org>
Cc: alan@lxorguk.ukuu.org.uk, ak@muc.de, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@nl.linux.org> wrote:
...
> This sounds suspiciously like the 'larger-blocks-for-larger-FSes'
> tactic other systems have been using to hide the bad scalability
> of their algorithms.
... (read-ahead comments cut away) ...

I have this following table about EXT2 (and UFS, and SysVfs, and..)
filesystem maximum supported file size.  These limits stem from block
addressability limitations in the classical tripply-indirection schemes:

	Block Size   File Size

	512        2 GB + epsilon
	1k        16 GB + epsilon
	2k       128 GB + epsilon
	4k      1024 GB + epsilon
	8k      8192 GB + epsilon  ( not without PAGE_SIZE >= 8 kB )

And of course any single partition filesystem in Linux (all of the
'local devices' filesystems right now) can't exceed  4G blocks of
512 bytes which limit is at the block device layer.
(This gives maximum physical filesystem size of 2 TB for EXT2.)


So, in my opinnion any triply-indirected filesystem is at the end
of its life when it comes to truly massive datasets.


The EXT2FS family will soon get new ways to extend its life by having
alternate block addressing structure to that of the classical triply-
indirection scheme it now uses.  (Ted Ts'o is working at it.)

> Rik -- Open Source: you deserve to be in control of your data.

/Matti Aarnio <matti.aarnio@sonera.fi>
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
