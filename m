Date: Tue, 5 Jun 2001 15:21:16 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Comment on patch to remove nr_async_pages limit
In-Reply-To: <Pine.LNX.4.33.0106051140270.1227-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.3.96.1010605151500.25725C-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Zlatko Calusic <zlatko.calusic@iskon.hr>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Jun 2001, Mike Galbraith wrote:

> Yes.  If we start writing out sooner, we aren't stuck with pushing a
> ton of IO all at once and can use prudent limits.  Not only because of
> potential allocation problems, but because our situation is changing
> rapidly so small corrections done often is more precise than whopping
> big ones can be.

Hold on there big boy, writing out sooner is not better.  What if the
memory shortage is because real data is being written out to disk?
Swapping early causes many more problems than swapping late as extraneous
seeks to the swap partiton severely degrade performance.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
