Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA11379
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 11:25:24 -0500
Date: Sat, 19 Dec 1998 17:23:13 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: PG_clean for shared mapping smart syncing
In-Reply-To: <Pine.LNX.3.96.981219165802.208A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.981219171852.506A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

I've put a new patch with as difference only a bit of credits added ;) at:

ftp://e-mind.com/pub/linux/kernel-patches/pgclean-0-2.1.132-2.diff.gz

All tests I done here are been succesfully (and I am using huge size of
memory just to be sure to notice any kind of mm corruption). Does somebody
has some test suite for shared mappings or could suggest me a proggy that
uses heavly shared mappings?

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
