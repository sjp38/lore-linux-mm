Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA21325
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 13:26:26 -0500
Date: Sun, 10 Jan 1999 19:11:01 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: tiny patch, reduces kernel memory usage (memory_save patch)
In-Reply-To: <Pine.LNX.3.96.990110174423.15469A-100000@Linuz.sns.it>
Message-ID: <Pine.LNX.3.96.990110190804.327F-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Max <max@Linuz.sns.it>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Jan 1999, Max wrote:

> This patch reduces kernel memory usage of 4kb for every 2Mb of physical RAM.
> On my 16Mb box this means the kernel uses 32kb less memory, and on a typical
> 64Mb Intel you save 128kb.

The unused field is been killed here since the first time it's appared
(when sct killed aging). Forget to remove map_nr though because it should
be a win in performances and is producing cleaner code. If you can show me
that it's not a win in performances I' ll produce a macro to still have
clean code.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
