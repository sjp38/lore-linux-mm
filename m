Date: Sun, 7 Jan 2001 22:37:38 -0800
Message-Id: <200101080637.WAA07361@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <Pine.LNX.4.10.10101072242340.29065-100000@penguin.transmeta.com>
	(message from Linus Torvalds on Sun, 7 Jan 2001 22:51:04 -0800 (PST))
Subject: Re: Call me crazy..
References: <Pine.LNX.4.10.10101072242340.29065-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org, alan@redhat.com, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

   Does anybody see why this wouldn't be required?

One day long ago fork() and vmscan both ran under the
big lock.

Those days are no more, and this now needs locking.

Later,
David S. Miller
davem@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
