Date: Wed, 24 Sep 2008 09:20:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mlock: Make the mlock system call interruptible by fatal
Message-Id: <20080924092040.d8407311.akpm@linux-foundation.org>
In-Reply-To: <20080924112255.64304a64@lxorguk.ukuu.org.uk>
References: <20080923224751.GA2790@google.com>
	<20080924112255.64304a64@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Salman Qazi <sqazi@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Sep 2008 11:22:55 +0100 Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > > Can we do
> > >
> > >        return i ? i : -EINTR;
> > >
> > > in the usual fashion?
> > 
> > Fixed.
> 
> If its only interruptible by fatal signals why do we care what the return
> is ?
> 

For the immediate in-kernel caller.  __get_user_pages() took a ref on a
few pages which the caller needs to undo before doing anything else
(like processing the signal).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
