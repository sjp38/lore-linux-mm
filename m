Date: Wed, 17 Jan 2001 18:16:28 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <87bstahwum.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.4.31.0101171816070.30841-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14 Jan 2001, Zlatko Calusic wrote:

> Memory hogger's behaviour haven't changed at all, for that
> problem to solve we will need some major changes in the
> swap_out() and functions it calls, I'm afraid.

RSS limits for single big memory hogs?

(I'll clean up the patch and send it)

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
