Date: Mon, 7 Aug 2000 14:37:20 -0400
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: RFC: design for new VM
Message-ID: <20000807143720.E10538@vodka.thepuffingroup.com>
References: <8725692F.0079E22B.00@d53mta03h.boulder.ibm.com> <200008071740.KAA25895@eng2.sequent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200008071740.KAA25895@eng2.sequent.com>; from Gerrit.Huizenga@us.ibm.com on Mon, Aug 07, 2000 at 10:40:52AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit.Huizenga@us.ibm.com
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 07, 2000 at 10:40:52AM -0700, Gerrit.Huizenga@us.ibm.com wrote:
> Also, I note that your filesys->flush() mechanism utilizes a call
> per page.  This is an interesting capability, although I'd question
> the processor efficiency of a page granularity here.  On large memory
> systems, with large processes starting (e.g. Netscape, StarOffice, or
> possible a database client), it seems like a callback to a filesystem
> which said something like flush("I must have at least 10 pages from
> you", "and I'd really like 100 pages") might be a better way to
> use this advisory capability.  You've already pointed out that you
> may request that a specific page might be requested but other pages
> may be freed; this may be a more explicit way to code the policy
> you really want.

i had a little argument with Rik about this.  his PoV is that the
filesystem should know nothing about which pages are aged and are ready
to be sent to disc.  so what he wants is the filesystem to be able to say
`no, you can't flush that page'.

-- 
Revolutions do not require corporate support.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
