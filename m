Date: Tue, 19 Feb 2002 15:57:06 -0800
From: Larry McVoy <lm@bitmover.com>
Subject: Re: [PATCH] struct page, new bk tree
Message-ID: <20020219155706.H26350@work.bitmover.com>
References: <Pine.LNX.4.33L.0202192044140.7820-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0202192044140.7820-100000@imladris.surriel.com>; from riel@conectiva.com.br on Tue, Feb 19, 2002 at 08:47:17PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Larry McVoy <lm@bitmover.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2002 at 08:47:17PM -0300, Rik van Riel wrote:
> I've removed the old (broken) bitkeeper tree with the
> struct page changes and have put a new one in the same
> place ... with the struct page changes in one changeset
> with ready checkin comment.
> 
> You can resync from bk://linuxvm.bkbits.net/linux-2.5-struct_page
> and you'll see that the stupid etc/config change is no longer there.

Since you two are doing the BK dance, here's a question for you: 
I can imagine that this sort of back and forth will happen quite a bit,
someone makes a change, then Linus (or whoever) says "no way", and the
developer goes back, cleans up the change, and repeats.  That's fine for
Linus & Rik because Linus tosses the changeset and Rik tosses it, but
what about the other people who have pulled?  Those changesets are now
wandering around in the network, just waiting to pop back into a tree.

This is at the core of my objections to the "reorder the events" theme
which we had a while back.  You can reorder all you want, but if there
are other copies of the events floating around out there, they may come
back.

A long time ago, there was some discussion of a changeset blacklist.
The idea being that if you want to reorder/rewrite/whatever, and your
changes have been pulled/pushed/whatever, then it would be good to be
able to state that in the form of some list which may be used to see 
if you have garbage changesets.

We could have a --blacklist option to undo which says "undo these
changes but remember their "names" in the BitKeeper/etc/blacklist file.
The next changeset you make will check in that file.  Note that each
changeset has a unique name which is used internally, somewhat like a
file has an inode number.  So we can save those names.  Then if you do
a pull or someone does a push, the incoming csets can be compared with
the blacklist and rejected if found.

Do you think this would be useful?  Would you use it if we made it?
-- 
---
Larry McVoy            	 lm at bitmover.com           http://www.bitmover.com/lm 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
