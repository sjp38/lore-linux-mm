Date: Tue, 3 Apr 2001 22:08:41 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Count swap faults which need to read data from the swap area as
 major faults
In-Reply-To: <Pine.LNX.4.21.0104032010010.7175-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0104032208210.14090-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Apr 2001, Marcelo Tosatti wrote:

> Right now we are not accounting faults which nee to read data from
> swap as major faults.
> 
> The following patch should fix that. 

Looks good....

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
