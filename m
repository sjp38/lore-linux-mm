From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
Date: Sat, 13 Aug 2005 05:56:10 +1000
References: <42F57FCA.9040805@yahoo.com.au> <1256640000.1123711001@flay> <200508111236.25576.rjw@sisk.pl>
In-Reply-To: <200508111236.25576.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508130556.11215.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-kernel@vger.kernel.org, "Martin J. Bligh" <mbligh@mbligh.org>, Pavel Machek <pavel@suse.cz>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

On Thursday 11 August 2005 20:36, Rafael J. Wysocki wrote:
> > >> > Swsusp is the main "is valid ram" user I have in mind here. It
> > >> > wants to know whether or not it should save and restore the
> > >> > memory of a given `struct page`.
> > >>
> > >> Why can't it follow the rmap chain?
> > >
> > > It is walking physical memory, not memory managment chains. I need
> > > something like:
> >
> > Can you not use page_is_ram(pfn) ?
>
> IMHO it would be inefficient.
>
> There obviously are some non-RAM pages that should not be saved and there
> are some that are not worthy of saving, although they are RAM (eg because
> they never change), but this is very archtecture-dependent.  The arch code
> should mark them as PageNosave for swsusp, and that's enough.

I still don't see why you can't lift your flags up into the VMA.  The rmap 
mechanism is there precisely to let you get from the physical page to the 
users and user data, including VMAs.

I am also not sure why you are talking about efficiency here.  Did you measure 
the impact on suspend performance?

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
