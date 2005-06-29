Date: Wed, 29 Jun 2005 23:22:30 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch 2] mm: speculative get_page
Message-ID: <20050629212230.GB17462@atrey.karlin.mff.cuni.cz>
References: <42BF9CD1.2030102@yahoo.com.au> <42BF9D67.10509@yahoo.com.au> <42BF9D86.90204@yahoo.com.au> <42C14662.40809@shadowen.org> <42C14D93.7090303@yahoo.com.au> <1119974566.14830.111.camel@localhost> <20050629163132.GB13336@elf.ucw.cz> <1120070616.12143.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1120070616.12143.4.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andy Whitcroft <apw@shadowen.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!

> > > > I think there are a a few ways that bits can be reclaimed if we
> > > > start digging. swsusp uses 2 which seems excessive though may be
> > > > fully justified. 
> > > 
> > > They (swsusp) actually don't need the bits at all until suspend-time, at
> > > all.  Somebody coded up a "dynamic page flags" patch that let them kill
> > > the page->flags use, but it didn't really go anywhere.  Might be nice if
> > > someone dug it up.  I probably have a copy somewhere.
> > 
> > Unfortunately that patch was rather ugly :-(.
> 
> Do you think the idea was ugly, or just the implementation?  Is there
> something that you'd rather see?

Well, implementation was ugly and idea was unneccesary because we
still had bits left.

We could spare bits for swsusp by defining "PageReserved | PageLocked
=> PageNosave" etc.... simply by choosing some otherwise unused
combinations. swsusp is not performance critical...
								Pavel
-- 
Boycott Kodak -- for their patent abuse against Java.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
