Date: Sat, 12 May 2001 11:56:20 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] allocation looping + kswapd CPU cycles 
In-Reply-To: <15096.22053.524498.144383@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0105121155460.5468-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Mark Hemment <markhe@veritas.com>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 May 2001, David S. Miller wrote:

> So instead, you could test for the condition that prevents any
> possible forward progress, no?

	if (!order || free_shortage() > 0)
		goto try_again;

(which was the experimental patch I discussed with Marcelo)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
