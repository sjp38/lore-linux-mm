Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 6654216B15
	for <linux-mm@kvack.org>; Sat, 24 Mar 2001 22:27:59 -0300 (EST)
Date: Sat, 24 Mar 2001 22:05:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Fix races in 2.4.2-ac22 SysV shared memory
In-Reply-To: <20010325001338.C11686@redhat.com>
Message-ID: <Pine.LNX.4.21.0103242203290.1863-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ben LaHaise <bcrl@redhat.com>, Christoph Rohland <cr@sap.com>
List-ID: <linux-mm.kvack.org>

On Sun, 25 Mar 2001, Stephen C. Tweedie wrote:

> Rik, do you think it is really necessary to take the page lock and
> release it inside lookup_swap_cache?  I may be overlooking something,
> but I can't see the benefit of it ---

I don't think we need to do this, except to protect us from
using a page which isn't up-to-date yet and locked because
of disk IO.

Reclaim_page() takes the pagecache_lock before trying to
free anything, so there's no reason to lock against that.

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
