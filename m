Message-ID: <3A0B7829.B9F33ACA@cse.iitkgp.ernet.in>
Date: Thu, 09 Nov 2000 23:23:05 -0500
From: Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
MIME-Version: 1.0
Subject: Re: Question about swap_in() in 2.2.16 ....
References: <3A08F37A.38C156C1@cse.iitkgp.ernet.in> <20001108100533.C11411@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>, linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:

> Hi,
>
> On Wed, Nov 08, 2000 at 01:32:26AM -0500, Shuvabrata Ganguly wrote:
> >
> > after the missing page has been swapped in this bit of code is
> > executed:-
> >
> > if (!write_access || is_page_shared(page_map)) {
> >       set_pte(page_table, mk_pte(page, vma->vm_page_prot));
> >       return 1;
> >  }
> >
> > Now this creates a read-only mapping  even if the access was a "write
> > acess"  ( if the page is shared ). Doesnt this mean that an additional
> > "write-protect" fault will be taken immediately when the process tries
> > to write again ?
>
> Yes.
>

Then why dont we give it a private page in the first place ?

Cheers
Joy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
