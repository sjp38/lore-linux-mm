Date: Tue, 15 Jun 2004 17:12:17 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-usb-devel] Patch for UHCI driver (from kernel 2.6.6).
In-Reply-To: <40CF5D1B.6000302@pacbell.net>
Message-ID: <Pine.LNX.4.44L0.0406151710070.658-100000@ida.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Brownell <david-b@pacbell.net>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Nicolas DET <nd@bplan-gmbh.de>, USB development list <linux-usb-devel@lists.sourceforge.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2004, David Brownell wrote:

> > 	... a write by either the device or the processor
> > 	can immediately be read by the processor or device 
> > 	without having to worry about caching effects.
> > 
> > This means that when you read _the data that was written_ you don't have 
> > to worry about caching effects.
> 
> It doesn't limit the "without having to worry" to just the bytes
> written.

It's hard to say exactly what it means because it's ungrammatical.  "A 
write ... can immediately be read..." -- what does it mean to read a 
write?

>  And the rest of that API spec doesn't even suggest that
> there might be an issue there.  I think you're trying to read
> things into that text that aren't there.

Maybe so.  It's not worth spending more time on this point, anyhow.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
