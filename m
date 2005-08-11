Received: from mail.sisk.pl ([127.0.0.1])
 by localhost (grendel [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07012-09 for <linux-mm@kvack.org>; Thu, 11 Aug 2005 12:32:26 +0200 (CEST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
Date: Thu, 11 Aug 2005 12:36:24 +0200
References: <42F57FCA.9040805@yahoo.com.au> <20050810215022.GA2465@elf.ucw.cz> <1256640000.1123711001@flay>
In-Reply-To: <1256640000.1123711001@flay>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508111236.25576.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Pavel Machek <pavel@suse.cz>, Daniel Phillips <phillips@arcor.de>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

Hi,

On Wednesday, 10 of August 2005 23:56, Martin J. Bligh wrote:
> --On Wednesday, August 10, 2005 23:50:22 +0200 Pavel Machek <pavel@suse.cz> wrote:
> 
> > Hi!
> > 
> >> > Swsusp is the main "is valid ram" user I have in mind here. It
> >> > wants to know whether or not it should save and restore the
> >> > memory of a given `struct page`.
> >> 
> >> Why can't it follow the rmap chain?
> > 
> > It is walking physical memory, not memory managment chains. I need
> > something like:
> 
> Can you not use page_is_ram(pfn) ?

IMHO it would be inefficient.

There obviously are some non-RAM pages that should not be saved and there are
some that are not worthy of saving, although they are RAM (eg because they never
change), but this is very archtecture-dependent.  The arch code should mark them
as PageNosave for swsusp, and that's enough.

Greets,
Rafael


-- 
- Would you tell me, please, which way I ought to go from here?
- That depends a good deal on where you want to get to.
		-- Lewis Carroll "Alice's Adventures in Wonderland"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
