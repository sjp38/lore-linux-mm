Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA27310
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 09:42:49 -0400
Date: Wed, 7 Apr 1999 15:42:28 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] only-one-cache-query [was Re: [patch] arca-vm-2.2.5]
In-Reply-To: <Pine.LNX.4.05.9904070243310.222-100000@laser.random>
Message-ID: <Pine.LNX.4.05.9904071540010.265-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mark Hemment <markhe@sco.COM>, Chuck Lever <cel@monkey.org>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Apr 1999, Andrea Arcangeli wrote:

>I would ask Chuck to bench this my new code (it should be an obvious
>improvement).

Don't try it!! I have a bug in the code that is corrupting the cache
(noticed now).

I am working on a fix now.

I just noticed that kmem_cache_reap can theorically sleep in down() so
here I moved the cookie++ in do_try_to_free_pages(), it will be less
finegrined but safer... But I still have corruption so I am looking at
filemap.c now...

BTW, why kmem_cache_reap() need a serializing semaphore?

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
