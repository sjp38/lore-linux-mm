Date: Sun, 29 Jul 2001 21:19:49 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
In-Reply-To: <Pine.LNX.4.33.0107290902060.7119-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0107292116530.1014-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@zip.com.au>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Jul 2001, Linus Torvalds wrote:
> 
> Removed. Which makes all the "age_page_up*()" functions go away entirely.
> They were mostly gone already.

Applause!  And for your encore... see how many age_page_down*()s
there are (3), and how many uses (1).  Same fate, please!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
