Date: Tue, 13 Feb 2001 00:05:50 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] guard mm->rss with page_table_lock (241p11)
In-Reply-To: <3A88A6ED.6B51BCA9@mvista.com>
Message-ID: <Pine.LNX.4.21.0102122334240.29855-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: george anzinger <george@mvista.com>
Cc: Rasmus Andersen <rasmus@jaquet.dk>, Rik van Riel <riel@conectiva.com.br>, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 12 Feb 2001, george anzinger wrote:

> Excuse me if I am off base here, but wouldn't an atomic operation be
> better here.  There are atomic inc/dec and add/sub macros for this.  It
> just seems that that is all that is needed here (from inspection of the
> patch).

Most functions which touch mm->rss already hold mm->page_table_lock (also
this functions are called more often and they use more CPU).

Making those functions use an atomic instruction just to optimize the
functions which do not lock mm->page_table_lock is not a good tradeoff.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
