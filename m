Date: Tue, 19 Feb 2002 11:32:17 -0800
From: Larry McVoy <lm@bitmover.com>
Subject: Re: [PATCH *] new struct page shrinkage
Message-ID: <20020219113217.P26350@work.bitmover.com>
References: <Pine.LNX.4.33L.0202191131050.1930-100000@imladris.surriel.com> <Pine.LNX.4.33.0202191116470.27806-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0202191116470.27806-100000@home.transmeta.com>; from torvalds@transmeta.com on Tue, Feb 19, 2002 at 11:21:34AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2002 at 11:21:34AM -0800, Linus Torvalds wrote:
> > The patch has been changed like you wanted, with page->zone
> > shoved into page->flags. I've also pulled the thing up to
> > your latest changes from linux.bkbits.net so you should be
> > able to just pull it into your tree from:
> >
> > bk://linuxvm.bkbits.net/linux-2.5-struct_page
> 
> Btw, _please_ don't do things like changing the bitkeeper etc/config file.
> Right now your very first changesets is something that I definitely do not
> want in my tree.

This is really a problem for bkbits to solve if I understand it correctly.
Rik wants to "name" his tree.  If we the bkbits admin interface have a 
"desc" command which changes the description listed on the web pages, then
I think he'll be happy, right?  We had the same problem with the PPC tree,
people do this without realizing the implications.

I'd suggest a changeset to the config file which says 

# Don't change the description unless you are Linus.
-- 
---
Larry McVoy            	 lm at bitmover.com           http://www.bitmover.com/lm 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
