Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA21326
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 13:26:27 -0500
Date: Sun, 10 Jan 1999 19:13:04 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901101659.QAA00922@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990110191237.327G-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Jan 1999, Stephen C. Tweedie wrote:

> dies if we make that change.  This does somewhat imply that we may need
> to make a distinction between reentrant and non-reentrant semaphores if
> we go down this route.

Agreed.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
