Date: Mon, 6 Nov 2000 15:05:39 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
Message-ID: <20001106150539.A19112@redhat.com>
References: <20001102134021.B1876@redhat.com> <20001103232721.D27034@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001103232721.D27034@athlon.random>; from andrea@suse.de on Fri, Nov 03, 2000 at 11:27:21PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Nov 03, 2000 at 11:27:21PM +0100, Andrea Arcangeli wrote:
> On Thu, Nov 02, 2000 at 01:40:21PM +0000, Stephen C. Tweedie wrote:
> > +			if (!write || pte_write(*pte))
> 
> You should check pte is dirty, not only writeable.

Why?

> > -		map = follow_page(ptr);
> > +		map = follow_page(ptr, datain);
> 
> Here you should _first_ follow_page and do handle_mm_fault _only_ if the pte is
> not ok.

Agreed --- I'll push that as a performace diff to Linus once the
essential bug-fixes are in.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
