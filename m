From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200006212037.NAA59219@google.engr.sgi.com>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Date: Wed, 21 Jun 2000 13:37:14 -0700 (PDT)
In-Reply-To: <20000621200418Z131176-21004+46@kanga.kvack.org> from "Timur Tabi" at Jun 21, 2000 02:57:52 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> ** Reply to message from Kanoj Sarcar <kanoj@google.engr.sgi.com> on Wed, 21
> Jun 2000 12:56:12 -0700 (PDT)
> 
> 
> > This is a left over from the days when we had a few more __GFP_ flags,
> > but that has been cleaned up now, so NR_GFPINDEX can go down. 
> 
> Cool.  I'm glad to see that my questions wasn't stupid :-)

Best way to verify this is change NR_GFPINDEX to whatever you think
is right, then see whether the resulting kernel comes up fine in
multiuser mode with networking and X.

> 
> >Be aware 
> > of any cache footprint issues though.
> 
> Ok, you just lost me.  What's a "cache footprint"?
>

Even though there is unused space, that might be padding out certain
data structures to cache line aligned sizes, causing lesser cache
line eviction etc, at the cost of few more bytes of unused space. On
certain applications, this can cause a noticeable improvement.

Kanoj 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
