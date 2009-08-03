Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 832FF6B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 13:13:55 -0400 (EDT)
Date: Mon, 3 Aug 2009 18:34:57 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/12] ksm: move pages_sharing updates
In-Reply-To: <20090803165315.GH23385@random.random>
Message-ID: <Pine.LNX.4.64.0908031821040.6178@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031310060.16754@sister.anvils> <20090803165315.GH23385@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Aug 2009, Andrea Arcangeli wrote:
> 
> If we stick to the subtraction semantics (that I think for users is
> less intuitive as they need to understand more of the ksm code to
> figure out what it means) sure ack...
> 
> I don't see the big deal of just printing total number of ksm pages in
> stable tree, and the actual _total_ number of userland mappings that
> are mapping those. The subtraction to see the actual sharing that is
> the difference between the two numbers, can be done by the user
> itself.

Yes, I know just what you mean.  When I first came to this, I rather
disliked that subtraction (though with this patch we have no actual
subtraction - but as you indicate, yes, that's an accident of the
internal implementation).  And it gets in the way of calculating
the ratio of ptes serviced to pages used.

But something I always find bothersome with /proc/meminfo is the
uncertainty about which numbers are included in which other numbers,
and which are exclusive.

So once I'd come to add the pages_unshared and pages_volatile,
I was really appreciating that these numbers are all simply
exclusive.

> 
> But then I'm fine if we stick to the substraction logic, this is a
> minor detail, I just usually prefer "raw" values. (if removing the
> inc/dec is beneficial at runtime as it seems then doing an addition
> will provide the info I would find more intuitive in  a more efficient
> way than before)

If you're also okay to stick with the subtraction logic, I think
let's continue to stick with it; but certainly it's something we
can easily change before 2.6.32, if people keep questioning it.

(I've tried to make it clear in ksm.txt, but people are likely
to question which way it is, whichever way it is - but it's
easier to say "they're all exclusive" than "this includes that,
but the others are exclusive").

> 
> Acked-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
