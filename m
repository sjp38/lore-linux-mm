Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA17402
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 17:05:57 -0400
Date: Tue, 6 Apr 1999 23:04:58 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.BSF.4.03.9904061644370.3406-100000@funky.monkey.org>
Message-ID: <Pine.LNX.4.05.9904062259110.430-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 1999, Chuck Lever wrote:

>but still, why does it help to add the unshifted "offset"?  doesn't seem
>like there's any new information in that.

The unshifted offset is useful for swap cache pages. When the page is a
swap cache page the page->offset really is the swap entry that tell us
where the page is been swapped out. And in such case page->offset is not
page aligned.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
