Date: Mon, 25 Sep 2000 16:50:30 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925165030.R22882@athlon.random>
References: <20000925160412.G22882@athlon.random> <Pine.LNX.4.21.0009251115150.2518-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251115150.2518-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Mon, Sep 25, 2000 at 11:26:48AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 11:26:48AM -0300, Marcelo Tosatti wrote:
> This thread keeps freeing pages from the inactive clean list when needed
> (when zone->free_pages < zone->pages_low), making them available for
> atomic allocations.

This is flawed. It's the irq that have to shrink the memory itself. It can't
certainly reschedule kreclaimd and wait it to do the work.

Increasing the free_pages_min limit is the _only_ alternative to having
irqs that are able to shrink clean cache (and hopefully that "feature"
will be resurrected soon since it's the only way to go right now). 

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
