Date: Tue, 9 Jan 2001 15:58:59 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.21.0101091929140.7500-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101091557460.2815-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 9 Jan 2001, Marcelo Tosatti wrote:
> 
> > > The second problem is that background scanning is being done
> > > unconditionally, and it should not. You end up getting all pages with the
> > > same age if the system is idle. Look at this example (2.4.1-pre1):
> > 
> > I agree. However, I think that we do want to do some background scanning
> > to push out dirty pages in the background, kind of like bdflush. It just
> > shouldn't age the pages (and thus not move them to the inactive list).
> 
> Actually it must age the pages, but aging should not be unconditional. 

No, I'm saying that "the background scanning" should not do the page
aging.

Obviously "refill_inactive()" needs to do the page aging. I'm just not at
all convinced that "background scanning" == "refill_inactive()". 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
