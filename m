Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 844926B0037
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 16:32:47 -0400 (EDT)
Date: Thu, 14 Mar 2013 16:32:46 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] USB: EHCI: fix for leaking isochronous data
In-Reply-To: <51421B89.6020308@web.de>
Message-ID: <Pine.LNX.4.44L0.1303141630550.1194-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>
Cc: Arnd Bergmann <arnd@arndb.de>, USB list <linux-usb@vger.kernel.org>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org

On Thu, 14 Mar 2013, Soeren Moch wrote:

> >> I added a debug message to
> >> drivers/usb/host/ehci-sched.c:itd_urb_transaction() to log the
> >> allocation flags, see log below.
> >
> > But it looks like you didn't add a message to end_free_itds(), so we
> > don't know when the memory gets deallocated.  And you didn't print out
> > the values of urb, num_itds, and i, or the value of itd (so we can
> > match up allocations against deallocations).
> 
> OK, I will implement this more detailed logging. But with several 
> allocations per second and runtime of several hours this will result in 
> a very long logfile.

If the memory really is being leaked here in some sort of systematic
way, we may be able to see it in your debugging output after a few
seconds.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
