Date: Mon, 25 Sep 2000 20:21:43 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: the new VMt
Message-ID: <20000925202143.U2615@redhat.com>
References: <20000925192114.Q2615@redhat.com> <E13ddd7-0005SN-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E13ddd7-0005SN-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Mon, Sep 25, 2000 at 08:09:31PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 08:09:31PM +0100, Alan Cox wrote:
> > > Indeed. But we wont fail the kmalloc with a NULL return
> > 
> > Isn't that the preferred behaviour, though?  If we are completely out
> > of VM on a no-swap machine, we should be killing one of the existing
> > processes rather than preventing any progress and keeping all of the
> > old tasks alive but deadlocked.
> 
> Unless Im missing something we wont kill any task in that condition - even
> a SIGKILL will make no odds as everyone is asleep in kmalloc

Right.  Eeek.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
