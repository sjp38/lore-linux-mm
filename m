Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 0651838CD3
	for <linux-mm@kvack.org>; Wed, 20 Feb 2002 16:27:07 -0300 (EST)
Date: Wed, 20 Feb 2002 16:27:00 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] struct page, new bk tree
In-Reply-To: <20020220120751.B1506@lynx.adilger.int>
Message-ID: <Pine.LNX.4.44L.0202201625140.1413-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Dilger <adilger@turbolabs.com>
Cc: Larry McVoy <lm@work.bitmover.com>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Larry McVoy <lm@bitmover.com>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2002, Andreas Dilger wrote:
> On Feb 19, 2002  15:57 -0800, Larry McVoy wrote:
> > On Tue, Feb 19, 2002 at 08:47:17PM -0300, Rik van Riel wrote:
> > > I've removed the old (broken) bitkeeper tree with the
> > > struct page changes and have put a new one in the same
> > > place ... with the struct page changes in one changeset
> > > with ready checkin comment.

> > developer goes back, cleans up the change, and repeats.  That's fine for
> > Linus & Rik because Linus tosses the changeset and Rik tosses it, but
> > what about the other people who have pulled?  Those changesets are now
> > wandering around in the network, just waiting to pop back into a tree.

> > We could have a --blacklist option to undo which says "undo these
> > changes but remember their "names" in the BitKeeper/etc/blacklist file.

> So what happens to the person who pulled the (now-blacklited) CSET in
> the first place?  If they do a pull from the repository where the original
> CSET lived, will the blacklisted CSET be undone and the replacement CSET
> be used in its place?

That's a good question.  I hadn't answered Larry before because
I just couldn't come up with what the implications of a blacklist
would be or how it would ever work ...

regards,

Rik
-- 
Will hack the VM for food.

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
