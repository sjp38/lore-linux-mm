From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <Pine.LNX.4.21.0105150134190.32493-100000@freak.distro.conectiva> 
References: <Pine.LNX.4.21.0105150134190.32493-100000@freak.distro.conectiva> 
Subject: Re: [PATCH] remove page_launder() from bdflush 
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Tue, 15 May 2001 11:05:50 +0100
Message-ID: <8889.989921150@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


marcelo@conectiva.com.br said:
>  There is no reason why bdflush should call page_launder().
> Its pretty obvious that bdflush's job is to only write out _buffers_. 
> Under my tests this patch makes things faster. 

Oh good. ISTR last time I looked at implementing CONFIG_BLK_DEV I got as far
as trying to remove bdflush() before getting confused at finding
page_launder() in it, and going on to more important things.

--
dwmw2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
