Date: Tue, 19 Feb 2002 11:54:52 -0800
From: Larry McVoy <lm@bitmover.com>
Subject: Re: [PATCH *] new struct page shrinkage
Message-ID: <20020219115452.S26350@work.bitmover.com>
References: <20020219113217.P26350@work.bitmover.com> <Pine.LNX.4.33L.0202191634290.7820-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0202191634290.7820-100000@imladris.surriel.com>; from riel@conectiva.com.br on Tue, Feb 19, 2002 at 04:35:26PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Larry McVoy <lm@bitmover.com>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Amy Graf <amy@bitmover.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2002 at 04:35:26PM -0300, Rik van Riel wrote:
> On Tue, 19 Feb 2002, Larry McVoy wrote:
> > This is really a problem for bkbits to solve if I understand it
> > correctly. Rik wants to "name" his tree.  If we the bkbits admin
> > interface have a "desc" command which changes the description listed
> > on the web pages, then I think he'll be happy, right?
> 
> Indeed.  The problem was that I was getting too many trees
> on linuxvm.bkbits.net and would only end up confusing people
> what was what...

I've got Amy working on a change so you can do a 

admin shell>> desc [-rrepo] whatever you want

and it will change the description to "whatever you want" on repo if specified,
or all if not.
-- 
---
Larry McVoy            	 lm at bitmover.com           http://www.bitmover.com/lm 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
