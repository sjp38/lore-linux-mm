Message-Id: <200105071452.f47Eq2jn008611@pincoya.inf.utfsm.cl>
Subject: Re: page_launder() bug 
In-Reply-To: Message from "David S. Miller" <davem@redhat.com>
   of "Sun, 06 May 2001 21:55:26 MST." <15094.10942.592911.70443@pizda.ninka.net>
Date: Mon, 07 May 2001 10:52:02 -0400
From: Horst von Brand <vonbrand@inf.utfsm.cl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Jonathan Morton <chromi@cyberspace.org>, BERECZ Szabolcs <szabi@inf.elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"David S. Miller" <davem@redhat.com> said:
> Jonathan Morton writes:
>  > >-			 page_count(page) == (1 + !!page->buffers));
>  > 
>  > Two inversions in a row?
> 
> It is the most straightforward way to make a '1' or '0'
> integer from the NULL state of a pointer.

IMVHO, it is clearer to write:

  page_count(page) == 1 + (page->buffers != NULL)

At least, the original poster wouldn't have wondered, and I wouldn't have
had to think a bit to find out what it meant... If gcc generates worse code
for this, it should be fixed.
-- 
Dr. Horst H. von Brand                       mailto:vonbrand@inf.utfsm.cl
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
