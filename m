Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id B6AEF6B0151
	for <linux-mm@kvack.org>; Wed, 29 May 2013 13:32:36 -0400 (EDT)
Date: Wed, 29 May 2013 13:32:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm: fincore()
Message-ID: <20130529173223.GE15721@cmpxchg.org>
References: <87a9rbh7b4.fsf@rustcorp.com.au>
 <20130211162701.GB13218@cmpxchg.org>
 <20130211141239.f4decf03.akpm@linux-foundation.org>
 <20130215063450.GA24047@cmpxchg.org>
 <20130215132738.c85c9eda.akpm@linux-foundation.org>
 <20130215231304.GB23930@cmpxchg.org>
 <20130215154235.0fb36f53.akpm@linux-foundation.org>
 <87621skhtc.fsf@rustcorp.com.au>
 <20130529145312.GE3955@alap2.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130529145312.GE3955@alap2.anarazel.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@2ndquadrant.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Stewart Smith <stewart@flamingspork.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Wed, May 29, 2013 at 04:53:12PM +0200, Andres Freund wrote:
> On 2013-02-16 14:53:43 +1030, Rusty Russell wrote:
> > Andrew Morton <akpm@linux-foundation.org> writes:
> > > On Fri, 15 Feb 2013 18:13:04 -0500
> > > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > >> I dunno.  The byte vector might not be optimal but its worst cases
> > >> seem more attractive, is just as extensible, and dead simple to use.
> > >
> > > But I think "which pages from this 4TB file are in core" will not be an
> > > uncommon usage, and writing a gig of memory to find three pages is just
> > > awful.
> > 
> > Actually, I don't know of any usage for this call.
> 
> [months later, catching up]
> 
> I do. Postgres' could really use something like that for making saner
> assumptions about the cost of doing an index/heap scan. postgres doesn't
> use mmap() and mmaping larger files into memory isn't all that cheap
> (32bit...) so having fincore would be nice.

How much of the areas you want to use it against is usually cached?
I.e. are those 4TB files with 3 cached pages?

I do wonder if we should just have two separate interfaces.  Ugly, but
I don't really see how the two requirements (dense but many holes
vs. huge sparse areas) could be acceptably met with one interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
