From: Oliver Neukum <oliver@neukum.org>
Subject: Re: mlock: Make the mlock system call interruptible by fatal
Date: Wed, 24 Sep 2008 13:49:40 +0200
References: <20080923224751.GA2790@google.com> <20080924112255.64304a64@lxorguk.ukuu.org.uk>
In-Reply-To: <20080924112255.64304a64@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809241349.42103.oliver@neukum.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Salman Qazi <sqazi@google.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Am Mittwoch, 24. September 2008 12:22:55 schrieb Alan Cox:
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

ptrace?

	Regards
		Oliver


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
