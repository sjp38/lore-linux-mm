Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id A631638CED
	for <linux-mm@kvack.org>; Mon, 24 Sep 2001 17:39:01 -0300 (EST)
Date: Mon, 24 Sep 2001 17:38:45 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] minor page aging update
Message-ID: <Pine.LNX.4.33L.0109241734490.1864-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Alan,

here is the promised minor page aging update to 2.4.9-ac15:

1) use min()/max() for age_page_{up,down}, now the
   thing is resistant to people changing PAGE_AGE_DECL ;)

2) in try_to_swap_out(), still adjust the page age even if
   the zone does have enough inactive pages ... this is a
   very cheap operation and will keep the page aging info
   in zones better up to date

3) only call do_try_to_free_pages() when we have a free
   shortage, this means kswapd() won't waste CPU time on
   working sets which fit in memory, but "spill over"
   into the inactive list ... also update comments a bit

4) remove run_task_queue(&tq_disk) from kswapd() since
   page_launder() will already have done this if needed

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
