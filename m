Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 31D0D38C85
	for <linux-mm@kvack.org>; Mon, 20 Aug 2001 18:35:06 -0300 (EST)
Date: Mon, 20 Aug 2001 18:34:51 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 
In-Reply-To: <Pine.LNX.4.21.0108201640010.538-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.33L.0108201834080.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Aug 2001, Marcelo Tosatti wrote:

> Think about a thread blocked on ->writepage() called from
> page_launder(), which has gotten an additional reference on the
> page.
>
> Any other thread looping on page_launder() will move the given
> page being written to the active list, even if we should just
> drop the page as soon as its writeout is finished.

You're right, we need to add one more check, for PageLocked(page).

If the page is locked, we should not reactivate it...

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
