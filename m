Subject: Re: the new VMt
Date: Mon, 25 Sep 2000 21:46:35 +0100 (BST)
In-Reply-To: <20000925143523.B19257@hq.fsmlabs.com> from "yodaiken@fsmlabs.com" at Sep 25, 2000 02:35:23 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13df92-0005Zp-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yodaiken@fsmlabs.com
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Jamie Lokier <lk@tantalophile.demon.co.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I'm not too sure of what you have in mind, but if it is
>      "process creates vast virtual space to generate many page table
>       entries -- using mmap"
> the answer is, virtual address space quotas and mmap should kill 
> the process on low mem for page tables.

Those quotas being exactly what beancounter is

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
