Date: Tue, 19 Feb 2002 11:21:34 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH *] new struct page shrinkage
In-Reply-To: <Pine.LNX.4.33L.0202191131050.1930-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.33.0202191116470.27806-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 19 Feb 2002, Rik van Riel wrote:
>
> The patch has been changed like you wanted, with page->zone
> shoved into page->flags. I've also pulled the thing up to
> your latest changes from linux.bkbits.net so you should be
> able to just pull it into your tree from:
>
> bk://linuxvm.bkbits.net/linux-2.5-struct_page

Btw, _please_ don't do things like changing the bitkeeper etc/config file.
Right now your very first changesets is something that I definitely do not
want in my tree.

Sure, I can do "bk cset -x" on the damn thing, but the fact is, I don't
want to have totally unnecessary undo's in my tree on things like this.
That's just stupid, and only makes the revision history look even less
readable than it already is..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
