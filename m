Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA14344
	for <linux-mm@kvack.org>; Sat, 16 Jan 1999 15:37:24 -0500
Date: Sat, 16 Jan 1999 18:35:29 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.2.0-pre[56] swap performance poor with > 1 thrashing task
In-Reply-To: <Pine.LNX.3.95.990108223729.3436D-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990116183023.449B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jan 1999, Linus Torvalds wrote:

> As a no-op, it can now randomly and unprectably result in even worthwhile
> buffers just being thrown out - possibly quite soon after they've been
> loaded in. I happen to believe that it doesn't actually matter (and I'm

I think it doesn't matter because the buffer_under_min() check just
protect the buffer cache enough. In arca-vm-22 I removed the specific
buffer and cache min limitis so I applyed Zlatko patch ;).

Basically arca-vm-22 take the sum of the buffermem+page_cache_size always
close to a percentage tunable via sysctl (10% as default) when _low_ on
memory. So the buffer aging now make sense to me (not benchmarked though
;).

Somebody in the list asked for an algorithm that doens't work with magic
but it's tunable. Having a constant cache+buffermem memory size under
swapping seems to work very well and even if it doesn't work with magic I
like it right now.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
