Date: Fri, 12 May 2000 12:57:00 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005120113520.10596-200000@elte.hu>
Message-ID: <Pine.LNX.4.21.0005121246410.6487-100000@inspiron>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Fri, 12 May 2000, Ingo Molnar wrote:

>IMO high memory should not be balanced. Stock pre7-9 tried to balance high
>memory once it got below the treshold (causing very bad VM behavior and
>high kswapd usage) - this is incorrect because there is nothing special
>about the highmem zone, it's more like an 'extension' of the normal zone,
>from which specific caches can turn. (patch attached)

IMHO that is an hack to workaround the currently broken design of the MM.
And it will also produce bad effect since you won't age the recycle the
cache in the highmem zone correctly.

Without classzone design you will always have kswapd and the page
allocator that shrink memory even if not necessary. Please check as
reference the very detailed explanation I posted around two weeks ago on
linux-mm in reply to Linus.

What you're trying to workaround on the highmem part is exactly the same
problem you also have between the normal zone and the dma zone. Why don't
you also just take 3mbyte always free from the dma zone and you never
shrink the normal zone?

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
