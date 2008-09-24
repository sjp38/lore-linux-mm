Date: Wed, 24 Sep 2008 11:22:55 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: mlock: Make the mlock system call interruptible by fatal
Message-ID: <20080924112255.64304a64@lxorguk.ukuu.org.uk>
In-Reply-To: <20080923224751.GA2790@google.com>
References: <20080923224751.GA2790@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Salman Qazi <sqazi@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > Can we do
> >
> >        return i ? i : -EINTR;
> >
> > in the usual fashion?
> 
> Fixed.

If its only interruptible by fatal signals why do we care what the return
is ?

Alan (confused)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
