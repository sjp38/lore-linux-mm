Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2B36C6B00C1
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:00:28 -0400 (EDT)
Date: Mon, 27 Apr 2009 12:58:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] MM: Rewrite some tests with is_power_of_2() for
 clarity.
Message-Id: <20090427125839.19d23850.akpm@linux-foundation.org>
In-Reply-To: <20090427170428.GA1890@cmpxchg.org>
References: <alpine.LFD.2.00.0904240834270.22152@localhost.localdomain>
	<20090427170428.GA1890@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: rpjday@crashcourse.ca, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009 19:04:28 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> > @@ -438,7 +439,7 @@ static void * __init alloc_bootmem_core(struct bootmem_data *bdata,
> >  		align, goal, limit);
> > 
> >  	BUG_ON(!size);
> > -	BUG_ON(align & (align - 1));
> > +	BUG_ON(!is_power_of_2(align));
> 
> Note that this is no 1:1 translation.  align could be zero before but
> not anymore.  Have you checked whether all callsites are ready for
> this?  The common bootmem macros use alignment to cacheline or page
> boundary.  I haven't checked all callsites that might use __api,
> though.
> 
> OTOH, it's doubtful that 'no alignment' should be expressed as 0
> instead of 1.
> 
> Still, it probably makes sense to express this change in semantics in
> the changelog.

ooh, yeah, well spotted.  There may well be code out there which sets
align=0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
