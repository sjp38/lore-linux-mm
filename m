Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
References: <Pine.LNX.4.21.0006050716160.31069-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 07 Jun 2000 12:23:36 +0200
In-Reply-To: Rik van Riel's message of "Mon, 5 Jun 2000 07:16:50 -0300 (BRST)"
Message-ID: <qww1z29ssbb.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christoph Rohland <cr@sap.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> Awaiting your promised integration of SHM with the shrink_mmap
> queue...

Sorry Rik, there was a misunderstanding here. I would really like to
have this integration. But AFAICS this is a major task. shrink_mmap
relies on the pages to be in the page cache and the pagecache does not
handle shared anonymous pages.

Thus shm does it's own page handling and swap out mechanism. Since I
do not know enough about the page cache I will not do this before
2.5. If you think it can be easily done, feel free to do it yourself
or show me the way to go (But I will be on vacation the next two
weeks).

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
