Message-ID: <39F1D06E.5327CCB9@norran.net>
Date: Sat, 21 Oct 2000 19:20:46 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [BUG?] kflushd launders without washing powder ???
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I am still experimenting with the VM code.
During this exploration I stumbled into this code,
from kflushd in fs/buffer.c

		flushed = flush_dirty_buffers(0);
		if (free_shortage())
			flushed += page_launder(GFP_BUFFER, 0);

a) GFP_BUFFER is __GFP_HIGH and __GFP_WAIT but not __GFP_IO
   Trying to launder without washing powder???
   Or is it somehow guaranteed that flushed buffers are from
   the same pages?
   Should a GFP_KFLUSHD be introduced - like GFP_KSWAPD ?

b) Where is no_of_inactive_dirty pages balanced against inactive_clean?
   (I have to look some more at this - remove my own patches first...)


/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
