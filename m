Received: from toomuch.toronto.redhat.com (toomuch.toronto.redhat.com [172.16.14.22])
	by lacrosse.corp.redhat.com (8.9.3/8.9.3) with ESMTP id WAA11342
	for <linux-mm@kvack.org>; Sun, 8 Jul 2001 22:45:43 -0400
Date: Thu, 5 Jul 2001 22:11:30 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.33.0107051613540.1702-100000@toomuch.toronto.redhat.com>
Message-ID: <Pine.LNX.4.33.0107052209540.29892-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: <linux-mm@kvack.org>
ReSent-Message-ID: <Pine.LNX.4.33.0107082244290.30164@toomuch.toronto.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Jul 2001, Ben LaHaise wrote:
>
> ps, would you mind if I forward the messages in this thread to linux-mm so
> that other people can see the discussion?

Go ahead..

Btw, I wouldn't worry too much about the false sharing on a 128-byte
cache-line. Let's face it, we're unlikely to see many P4+ class machines
with less than 128MB of memory, at which time it starts to get unlikely
that we'll see all that many horrible ping-pong schenarios between CPU's -
touching alternate physical pages simply isn't all that likely.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
