Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA30895
	for <linux-mm@kvack.org>; Thu, 17 Dec 1998 09:20:22 -0500
Date: Thu, 17 Dec 1998 15:20:06 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: do_try_to_free_pages should avoid the mm cycle now
Message-ID: <Pine.LNX.3.96.981217151701.755A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I seen the changes to the do_try_to_free_pages and to shrink_mmap and I
agree with it completly. The old way was completly unbalanced.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
