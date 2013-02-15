Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id C00806B0085
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:34:31 -0500 (EST)
Date: Fri, 15 Feb 2013 14:34:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] mm: fincore()
Message-Id: <20130215143430.958b78ab.akpm@linux-foundation.org>
In-Reply-To: <20130215222803.GA23930@cmpxchg.org>
References: <87a9rbh7b4.fsf@rustcorp.com.au>
	<20130211162701.GB13218@cmpxchg.org>
	<20130211141239.f4decf03.akpm@linux-foundation.org>
	<20130215063450.GA24047@cmpxchg.org>
	<20130215131451.138e83ce.akpm@linux-foundation.org>
	<20130215222803.GA23930@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Stewart Smith <stewart@flamingspork.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Fri, 15 Feb 2013 17:28:03 -0500
Johannes Weiner <hannes@cmpxchg.org> wrote:

> > Yes, and there will be immediate calmour to add more goodies to the
> > other seven bits.  PageDirty, referenced state, etc.  We should think
> > about this now, at the design stage rather than grafting things on
> > later.
> 
> I'm interested in your "etc.".  PG_error, PG_active, PG_writeback,
> page huge?

Gawd knows.  How many crazy people are there out there?

If we adopt my use-runlength-encoding suggestion then things get
easier.  We add an extra arg to the syscall which selects which
particular per-page boolean we're looking for and can gather up to 4
billion different PageFoo()s.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
