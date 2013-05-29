Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 3AC816B013A
	for <linux-mm@kvack.org>; Wed, 29 May 2013 10:53:16 -0400 (EDT)
Date: Wed, 29 May 2013 16:53:12 +0200
From: Andres Freund <andres@2ndquadrant.com>
Subject: Re: [patch 1/2] mm: fincore()
Message-ID: <20130529145312.GE3955@alap2.anarazel.de>
References: <87a9rbh7b4.fsf@rustcorp.com.au>
 <20130211162701.GB13218@cmpxchg.org>
 <20130211141239.f4decf03.akpm@linux-foundation.org>
 <20130215063450.GA24047@cmpxchg.org>
 <20130215132738.c85c9eda.akpm@linux-foundation.org>
 <20130215231304.GB23930@cmpxchg.org>
 <20130215154235.0fb36f53.akpm@linux-foundation.org>
 <87621skhtc.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87621skhtc.fsf@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Stewart Smith <stewart@flamingspork.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org

On 2013-02-16 14:53:43 +1030, Rusty Russell wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
> > On Fri, 15 Feb 2013 18:13:04 -0500
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> >> I dunno.  The byte vector might not be optimal but its worst cases
> >> seem more attractive, is just as extensible, and dead simple to use.
> >
> > But I think "which pages from this 4TB file are in core" will not be an
> > uncommon usage, and writing a gig of memory to find three pages is just
> > awful.
> 
> Actually, I don't know of any usage for this call.

[months later, catching up]

I do. Postgres' could really use something like that for making saner
assumptions about the cost of doing an index/heap scan. postgres doesn't
use mmap() and mmaping larger files into memory isn't all that cheap
(32bit...) so having fincore would be nice.

Greetings,

Andres Freund

-- 
 Andres Freund	                   http://www.2ndQuadrant.com/
 PostgreSQL Development, 24x7 Support, Training & Services

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
