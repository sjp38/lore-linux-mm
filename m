Date: Mon, 25 Sep 2000 18:42:31 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VMt
Message-ID: <20000925184231.D27677@athlon.random>
References: <20000925180500.B26719@athlon.random> <Pine.LNX.4.21.0009251321360.14614-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251321360.14614-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Sep 25, 2000 at 01:22:40PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 01:22:40PM -0300, Rik van Riel wrote:
> whereas the old allocator could break down even when
> we still had enough swap free....

As far I can see that's a bug that you hided introducing a deadlock.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
