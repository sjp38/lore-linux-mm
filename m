From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14301.15443.303167.898233@dukat.scot.redhat.com>
Date: Mon, 13 Sep 1999 19:02:59 +0100 (BST)
Subject: Re: bdflush defaults bugreport
In-Reply-To: <Pine.LNX.4.10.9909050953540.247-100000@mirkwood.dummy.home>
References: <Pine.LNX.4.10.9909050953540.247-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@humbolt.geo.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 5 Sep 1999 09:58:56 +0200 (CEST), Rik van Riel
<riel@humbolt.geo.uu.nl> said:

> yesterday evening I've seen a 32MB machine failing to install because
> mke2fs was killed due to memory shortage -- memory shortage due to
> a too large number of dirty blocks (max 40% by default).

In the past, such problems were mainly due to the refile_buffer() code
not limiting the write rate of heavy buffer cache writes more than
anything else.

> Lowering the number to 1% solved all problems, so I guess we should
> lower the number in the kernel to something like 10%, which should
> be _more_ than enough since the page cache can now be dirty too...

That is not a clean solution: it's just imposing an unnecessary
performance on the whole cache when the problem probably lies
elsewhere.  

> Btw, the problem happened on a 2.2.10 machine

In 2.2, the page cache cannot be dirty in this sense.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
