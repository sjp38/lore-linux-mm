Date: Mon, 5 Mar 2001 06:36:14 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] ac7: page_launder() & refill_inactive() changes
In-Reply-To: <3AA15E3C.39BD9A82@ucla.edu>
Message-ID: <Pine.LNX.4.21.0103050634470.1884-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 3 Mar 2001, Benjamin Redelings I wrote:

>  
> Content-Type: text/plain; charset=big5
> Content-Transfer-Encoding: 7bit
> 
> Hi Marcelo:
> 	In the patch you provided, have you perhaps reverse the sense of this
> test:
> 
> +                       if (try_to_free_buffers(page, wait))
> +                               flushed_pages++;
> 
> Should this have a NOT (!) instead?

No. 

I changed try_to_free_buffers() to return true if it did IO. 

> 
> +                       if (!try_to_free_buffers(page, wait))
> +                               flushed_pages++;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
