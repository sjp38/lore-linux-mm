Date: Mon, 25 Sep 2000 11:26:48 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: the new VM
In-Reply-To: <20000925160412.G22882@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251115150.2518-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

<snip>

> I talked with Alexey about this and it seems the best way is to have a
> per-socket reservation of clean cache in function of the receive window.  So we
> don't need an huge atomic pool but we can have a special lru with an irq
> spinlock that is able to shrink cache from irq as well.

In the current 2.4 VM code, there is a kernel thread called
"kreclaimd".

This thread keeps freeing pages from the inactive clean list when needed
(when zone->free_pages < zone->pages_low), making them available for
atomic allocations.

Do you consider pages_low pages as a "huge atomic pool" ? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
