Date: Mon, 25 Sep 2000 19:27:45 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VMt
Message-ID: <20000925192745.I27677@athlon.random>
References: <20000925191703.G27677@athlon.random> <Pine.LNX.4.21.0009251407020.20061-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251407020.20061-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Sep 25, 2000 at 02:10:07PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Andi Kleen <ak@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 02:10:07PM -0300, Rik van Riel wrote:
> Not really. We could fix this by making the page freeing
> functions smarter and only free the pages we need.

That's what I proposed in first place infact.

To free large chunk of memory you may have to throw away lots of cache. We're
not freeing contigous cache as we do in 2.2.x.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
