Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3B3506B0110
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 09:06:23 -0400 (EDT)
Date: Wed, 22 Jul 2009 14:05:55 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 00/10] ksm resend
In-Reply-To: <20090721175909.GF2239@random.random>
Message-ID: <Pine.LNX.4.64.0907221359010.2482@sister.anvils>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <20090721175909.GF2239@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Tue, 21 Jul 2009, Andrea Arcangeli wrote:
> On Fri, Jul 17, 2009 at 08:30:40PM +0300, Izik Eidus wrote:
> > The code still need to get Andrea Arcangeli acks.
> > (he was busy and will ack it later).
> 
> Ack it all except that detail in 6/10

Thanks a lot, Andrea.

> as I'm unconvinced about ksm
> pages having to return 1 on PageAnon check. I believe they deserve a
> different bitflag in the mapping pointer. The smallest possible
> alignment for mapping pointer is 4 on 32bit archs so there is space
> for it

Yes, I believe they'll deserve that too, but set in addition to
PAGE_MAPPING_ANON.  And perhaps you or someone else will then have
another use for the new bit when PAGE_MAPPING_ANON is not set.

> and later it can be renamed EXTERNAL to generalize. We shall
> make good use of that bitflag as it's quite precious to introduce
> non-linearity in linear vmas, and not wire it to KSM only.

You have something in mind here...

> But in
> meantime we'll get better testing coverage by not having that PageKsm
> == PageAnon invariant I think that I doubt we're going to retain (at
> least with this implementation of PageKsm).

PageKsm subset of PageAnon: I expect to retain that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
