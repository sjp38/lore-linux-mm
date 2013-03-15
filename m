Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id EACA36B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 10:30:38 -0400 (EDT)
Date: Fri, 15 Mar 2013 10:30:37 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] USB: EHCI: fix for leaking isochronous data
In-Reply-To: <51426484.3000609@web.de>
Message-ID: <Pine.LNX.4.44L0.1303151028100.1414-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>
Cc: Arnd Bergmann <arnd@arndb.de>, USB list <linux-usb@vger.kernel.org>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org

On Fri, 15 Mar 2013, Soeren Moch wrote:

> > The log shows a 1-1 match between allocations and deallocations, except
> > for three excess allocations about 45 lines before the end.  I have no
> > idea what's up with those.  They may be an artifact arising from where
> > you stopped copying the log data.
> >
> > There are as many as 400 iTDs being allocated before any are freed.
> > That seems like a lot.  Are they all for the same isochronous endpoint?
> > What's the endpoint's period?  How often are URBs submitted?
> 
> I use 2 dvb sticks, capturing digital TV. For each stick 5 URBs on a 
> single endpoint are used, I think. I'm not sure, which endpoint in which 
> alternateSetting is active. I attached the output of 'lsusb -v' for the 
> sticks.
> How can I track down the other information you need?

Use usbmon (see Documentation/usb/usbmon.txt).

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
