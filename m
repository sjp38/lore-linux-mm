Date: Sun, 7 Jul 2002 12:02:51 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
In-Reply-To: <Pine.LNX.4.44.0207071146070.3344-100000@home.transmeta.com>
Message-ID: <Pine.LNX.4.44.0207071200510.3344-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "Martin J. Bligh" <fletch@aracnet.com>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Sun, 7 Jul 2002, Linus Torvalds wrote:
>
> We do actually have an alternate approach: get rid of the "kmap()" in
> file_send_actor() altogether, and require targets of sendfile() to always
> support the sendpage() interface (which can do a kmap at a lower level if
> they need to - it's not even guaranteed that they do need to).

Ok, I'm going to just check that in to 2.5.x, and see who (if anybody)
screams.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
