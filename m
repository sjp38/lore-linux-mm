Date: Mon, 7 Feb 2000 17:09:09 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: Kernel page count management
In-Reply-To: <XFMail.000207103614.mathias@atoll-net.de>
Message-ID: <Pine.LNX.4.10.10002071707110.9296-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathias Waack <mathias@atoll-net.de>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Feb 2000, Mathias Waack wrote:

> If I request a page by calling get_free_page, the kernel 
> sets the usage count for this page to 1. So far so good, but if
> I request more pages by calling __get_free_pages(GFP...,order) 
> it sets only the usage count of the first returned page. 

Higher-order pages are "special".

They are used for special-purpose things and they are not
freeable by kswapd or anything else except the code that
requested the pages in the first place.

There is no real need to mark the other pages as used
since they've been removed from the free list and nobody
will see those pages (except the code that has allocated
them).

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
