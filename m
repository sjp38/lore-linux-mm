Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA12936
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 10:01:15 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14090.4979.543492.66003@dukat.scot.redhat.com>
Date: Tue, 6 Apr 1999 15:00:19 +0100 (BST)
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.LNX.4.05.9904050033340.779-100000@laser.random>
References: <Pine.BSF.4.03.9904041657210.15836-100000@funky.monkey.org>
	<Pine.LNX.4.05.9904050033340.779-100000@laser.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 5 Apr 1999 02:22:35 +0200 (CEST), Andrea Arcangeli
<andrea@e-mind.com> said:

> The page hash function change is from Stephen (I did it here too because I
> completly agreed with it). The point is that shm entries uses the lower
> bits of the pagemap->offset field.

_All_ swap entries do.  shm entries never enter the page cache so that's
not a problem, but the swap cache _is_ a problem.

> Eh, my shrink_mmap() is is a black magic and it's long to explain what I
> thought ;).

It is hard to have a meaningful discussion about it otherwise!

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
