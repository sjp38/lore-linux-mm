From: Duncan Sands <baldrick@free.fr>
Subject: Re: [linux-usb-devel] Patch for UHCI driver (from kernel 2.6.6).
Date: Tue, 15 Jun 2004 19:23:52 +0200
References: <Pine.LNX.4.44L0.0406151221220.1960-100000@ida.rowland.org> <40CF2CF5.5000209@pacbell.net>
In-Reply-To: <40CF2CF5.5000209@pacbell.net>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200406151923.52709.baldrick@free.fr>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-usb-devel@lists.sourceforge.net
Cc: David Brownell <david-b@pacbell.net>, Alan Stern <stern@rowland.harvard.edu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Nicolas DET <nd@bplan-gmbh.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Actually I thought it was quite explicit:  "without having
> to worry about caching effects".  What you described is
> clearly a caching effect:  caused by caching.

Is it really a cache effect?  Isn't it caused by the hc writing
more bytes to memory than you expected?  Now, it so
happens that the number of bytes it writes is equal to the
cache line size (or so it seems), but isn't that irrelevant?

Ciao,

Duncan.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
