Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 2332E38CF0
	for <linux-mm@kvack.org>; Wed, 22 Aug 2001 18:34:41 -0300 (EST)
Date: Wed, 22 Aug 2001 18:34:34 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
In-Reply-To: <E15ZfdG-0002M4-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.33L.0108221833470.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>, Jari Ruusu <jari.ruusu@pp.inet.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2001, Alan Cox wrote:

> > The strange thing is that the recent vm tweaks don't
> > have any influence on the code paths which could cause
> > tasks segfaulting ...
>
> They change reuse and timing patterns. I can believe we may have
> bugs left over from before that are now showing up.

The swap code is my usual suspect in this case, since
I'm still not sure how the locking in that part of the
VM is supposed to work. :|

cheers,

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
