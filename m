Date: Fri, 6 Aug 1999 16:18:50 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Fix sys_mount not to free_page(0)
In-Reply-To: <199908062312.QAA00496@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9908061618260.1889-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 6 Aug 1999, Kanoj Sarcar wrote:
> 
> Could you please take this patch into the 2.2 and 2.3 streams? It
> basically prevents sys_mount() from trying to invoke free_page(0).

Hmm..

free_page(0) is actually supposed to work. Doesn't it?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
