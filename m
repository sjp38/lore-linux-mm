Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id EA1C338CE5
	for <linux-mm@kvack.org>; Wed, 22 Aug 2001 18:28:26 -0300 (EST)
Date: Wed, 22 Aug 2001 18:28:15 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
In-Reply-To: <E15ZfK9-0002I3-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.33L.0108221827330.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>, Jari Ruusu <jari.ruusu@pp.inet.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2001, Alan Cox wrote:

> > Suspect code would be:
> > - tlb optimisations in recent -ac    (tasks dying with segfault)
>
> Um the tlb optimisations go back to about 2.4.1-ac 8)
> My guess would be the vm changes you and marcelo did

The strange thing is that the recent vm tweaks don't
have any influence on the code paths which could cause
tasks segfaulting ...

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
