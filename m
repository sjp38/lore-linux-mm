Subject: Re: the new VMt
Date: Mon, 25 Sep 2000 20:09:31 +0100 (BST)
In-Reply-To: <20000925192114.Q2615@redhat.com> from "Stephen C. Tweedie" at Sep 25, 2000 07:21:14 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13ddd7-0005SN-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > Indeed. But we wont fail the kmalloc with a NULL return
> 
> Isn't that the preferred behaviour, though?  If we are completely out
> of VM on a no-swap machine, we should be killing one of the existing
> processes rather than preventing any progress and keeping all of the
> old tasks alive but deadlocked.

Unless Im missing something we wont kill any task in that condition - even
a SIGKILL will make no odds as everyone is asleep in kmalloc


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
