Date: Mon, 25 Sep 2000 17:16:06 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VM
In-Reply-To: <E13dZX7-00055f-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Alan Cox wrote:

> GFP_KERNEL has to be able to fail for 2.4. Otherwise you can get
> everything jammed in kernel space waiting on GFP_KERNEL and if the
> swapper cannot make space you die.

if one can get everything jammed waiting for GFP_KERNEL, and not being
able to deallocate anything, thats a VM or resource-limit bug. This
situation is just 1% RAM away from the 'root cannot log in', situation.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
