Date: Fri, 13 Oct 2000 15:56:34 -0700
From: Richard Henderson <rth@twiddle.net>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
Message-ID: <20001013155634.A29761@twiddle.net>
References: <20001013171950.Y6207@devserv.devel.redhat.com> <Pine.LNX.4.10.10010131424140.14888-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10010131424140.14888-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Jakub Jelinek <jakub@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "David S. Miller" <davem@redhat.com>, davej@suse.de, tytso@mit.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 13, 2000 at 02:25:45PM -0700, Linus Torvalds wrote:
> And even on alpha, a 32-bit atomic_t means we cover 45 bits of virtual
> address space, which, btw, is more than you can cram into the current
> three-level page tables, I think.

While that's true of Alpha, it's not true of Ultra III, in which
all 64-bits are in theory available to the user.  Dave hasn't
implemented that yet, AFAIK.


r~
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
