Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA23924
	for <linux-mm@kvack.org>; Mon, 31 May 1999 20:02:08 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14163.8950.319558.793463@dukat.scot.redhat.com>
Date: Tue, 1 Jun 1999 01:01:58 +0100 (BST)
Subject: Re: Q: PAGE_CACHE_SIZE?
In-Reply-To: <Pine.LNX.4.05.9905310111460.7712-100000@laser.random>
References: <14159.18916.728327.550606@dukat.scot.redhat.com>
	<Pine.LNX.4.05.9905310111460.7712-100000@laser.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@nl.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, ak@muc.de, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 31 May 1999 01:12:43 +0200 (CEST), Andrea Arcangeli
<andrea@suse.de> said:

> I am just rewriting swapped-in pages to their previous location on
> swap to avoid swap fragmentation. No need to have dirty pages into the
> swap cache to handle that. We just have the information cached in the
> page-map-> offset field. We only need to know when it make sense to
> know if we should use it or not. To handle that I simply added a
> PG_swap_entry bitflag set at swapin time and cleared after swapout to
> the old entry or at free_page_and_swap_cache() time. The thing runs
> like a charm (the swapin performances definitely improves a lot).

Cute!  When, oh when, are you going to start releasing these things as
separate patches which I can look at?  This is one simple optimisation
that I'd really like to see in 2.3 asap.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
