Message-ID: <3912522E.7D1212C8@sgi.com>
Date: Thu, 04 May 2000 21:46:38 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
References: <Pine.LNX.4.10.10005032108080.765-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Wed, 3 May 2000, Rajagopal Ananthanarayanan wrote:
> >
> > One other problem with having the page locked in
> > try_to_swapout() is in the call to
> > prepare_highmem_swapout() when the incoming
> > page is in highmem.
> 
> Look at how I handled this in pre7-4.
> 
> Just unlocking the old page and returning with the new page locked is
> quite acceptable. The "prepare_highmem_swapout()" thing breaks the
> association with the pages anyway, and as such there is no race (and this
> is allowable only exactly because of the anonymous and non-shared nature
> of a private COW-mapping - which is the only thing we accept in that
> code-path anyway).
> 
> Doing it that way means that there are no special cases in vmscan.c.

Yep, now I see it after having actually applied the patch ;-)
I missed it in the original patch file with just the diffs, sorry.

ananth.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
