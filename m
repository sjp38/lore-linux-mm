Date: Mon, 25 Sep 2000 16:23:11 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925162311.L22882@athlon.random>
References: <20000925160412.G22882@athlon.random> <Pine.LNX.4.21.0009251603180.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251603180.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 04:04:14PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 04:04:14PM +0200, Ingo Molnar wrote:
> exactly, and this is why if a higher level lets through a GFP_KERNEL, then
> it *must* succeed. Otherwise either the higher level code is buggy, or the
> VM balance is buggy, but we want to have clear signs of it.

I'm not sure if we should restrict the limiting only to the cases that needs
them. For example do_anonymous_page looks a place that could rely on the
GFP retval.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
