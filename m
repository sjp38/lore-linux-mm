Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 779846B01BA
	for <linux-mm@kvack.org>; Tue, 25 May 2010 11:44:25 -0400 (EDT)
Date: Wed, 26 May 2010 01:43:52 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525154352.GB20853@laptop>
References: <AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
 <20100525070734.GC5087@laptop>
 <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
 <20100525081634.GE5087@laptop>
 <AANLkTilJBY0sinB365lIZFUaMgMCZ1xyhMdXRTJTVDSV@mail.gmail.com>
 <20100525093410.GH5087@laptop>
 <AANLkTikXp5LlKLK1deKOQpciUFNugjlQah5QpNcImf39@mail.gmail.com>
 <20100525101924.GJ5087@laptop>
 <AANLkTimazVL8G-XQURiQ1s0M3NKa2ndXNceSaw9sADRQ@mail.gmail.com>
 <alpine.LFD.2.00.1005250812100.3689@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005250812100.3689@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 08:13:50AM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 25 May 2010, Pekka Enberg wrote:
> > 
> > I would have liked to see SLQB merged as well but it just didn't happen.
> 
> And it's not going to. I'm not going to merge YASA that will stay around 
> for years, not improve on anything, and will just mean that there are some 
> bugs that developers don't see because they depend on some subtle 
> interaction with the sl*b allocator.
> 
> We've got three. That's at least one too many. We're not adding any new 
> ones until we've gotten rid of at least one old one.

No agree and realized that a while back (hence stop pushing SLQB).
SLAB is simply a good allocator that is very very hard to beat. The
fact that a lot of places are still using SLAB despite the real
secondary advantages of SLUB (cleaner code, better debugging support)
indicate to me that we should go back and start from there.

What is sad is all this duplicate (and unsynchronized and not always
complete) work implementing things in both the allocators[*] and
split testing base.

As far as I can see, there was never a good reason to replace SLAB
rather than clean up its code and make incremental improvements.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
