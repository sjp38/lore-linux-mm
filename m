Date: Wed, 27 Sep 2000 16:08:46 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000927160846.E27898@athlon.random>
References: <20000926211016.A416@bug.ucw.cz> <Pine.LNX.4.21.0009270935380.993-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009270935380.993-100000@elte.hu>; from mingo@elte.hu on Wed, Sep 27, 2000 at 09:42:45AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Pavel Machek <pavel@suse.cz>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 27, 2000 at 09:42:45AM +0200, Ingo Molnar wrote:
> such screwups by checking for NULL and trying to handle it. I suggest to
> rather fix those screwups.

How do you know which is the minimal amount of RAM that allows you not to be in
the screwedup state?

We for sure need a kind of counter for the special dynamic structures but I'm
not sure if that should account the static stuff as well.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
