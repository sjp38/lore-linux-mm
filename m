Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 06DEC38D5F
	for <linux-mm@kvack.org>; Fri, 24 Aug 2001 17:11:18 -0300 (EST)
Date: Fri, 24 Aug 2001 17:11:08 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
In-Reply-To: <Pine.LNX.4.21.0108241538380.4787-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.33L.0108241710040.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jari Ruusu <jari.ruusu@pp.inet.fi>, Hugh Dickins <hugh@veritas.com>, Jeremy Linton <jlinton@interactivesi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Aug 2001, Marcelo Tosatti wrote:

> I do not feel comfortable with random SIGSEGV messages.

You wuss ;)

> If we are getting those, I suspect there is still some broken
> thing in do_swap_page().

True, but note that even while Hugh's stuff doesn't fix
everything, it sure seems to do away with some bugs.
The code looks fine to me...

regards,

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
