Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id A9EBB6B0002
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 10:24:09 -0400 (EDT)
Date: Fri, 22 Mar 2013 10:24:08 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] USB: EHCI: fix for leaking isochronous data
In-Reply-To: <514B86A9.60401@web.de>
Message-ID: <Pine.LNX.4.44L0.1303221023310.1294-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>
Cc: Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, USB list <linux-usb@vger.kernel.org>, Jason Cooper <jason@lakedaemon.net>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, michael@amarulasolutions.com

On Thu, 21 Mar 2013, Soeren Moch wrote:

> > Hi Alan, Soeren
> >
> > Could you word the description a bit better. If Alan did not get it
> > without a bit of thought, few others are going to understand it
> > without a better explanation.
> >
> > Thanks
> > 	Andrew
> >
> 
> Alan,
> 
> can you come up with a better explanation, please? I think your 
> description how it is supposed to work from here
>     http://marc.info/?l=linux-usb&m=136345559432055&w=2
> is required to understand the problem and the fix.

Okay, I will rewrite your patch description.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
