Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 256D06B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 06:09:08 -0500 (EST)
Date: Thu, 26 Feb 2009 12:09:04 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
Message-ID: <20090226110904.GA32178@wotan.suse.de>
References: <20090225093629.GD22785@wotan.suse.de> <1235640018.4645.4692.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1235640018.4645.4692.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 26, 2009 at 10:20:18AM +0100, Peter Zijlstra wrote:
> On Wed, 2009-02-25 at 10:36 +0100, Nick Piggin wrote:
> > +               if (!page_mkwrite)
> > +                       wait_on_page_locked(dirty_page);
> >                 set_page_dirty_balance(dirty_page, page_mkwrite);
> >                 put_page(dirty_page);
> > +               if (page_mkwrite) {
> > +                       unlock_page(old_page);
> > +                       page_cache_release(old_page);
> > +               }
> 
> We're calling into the whole balance_dirty_pages() writeout path with a
> page locked.. is that sensible?

Yeah, probably should move the balance out of there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
