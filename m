Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA12287
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 09:09:40 -0400
Date: Tue, 6 Apr 1999 15:04:36 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <37096E02.C9E53CE2@redhat.com>
Message-ID: <Pine.LNX.4.05.9904061459330.437-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Doug Ledford <dledford@redhat.com>
Cc: Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Apr 1999, Doug Ledford wrote:

>Hmmm...I've talked about this a few times to Alan Cox and Stephen
>Tweedie.  I didn't bother to instrument the hash function because in
>this case I knew it was tuned to the size of the inode structs.  But, I
>did implement a variable sized page cache hash table array.  I did this

Well it's strightforward. I just did the same some time ago for the buffer
hash table. But I agree with Chuck that enlarging the hash size could harm
the hash function distrubution (I should think about it some more though).

I also think that I'll implement the cookie thing suggested by Mark since
I am too much courious to see how much it will help (even if my mind is
driven by RB-trees ;).

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
