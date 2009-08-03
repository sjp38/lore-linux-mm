Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0847F6B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 12:32:20 -0400 (EDT)
Date: Mon, 3 Aug 2009 18:53:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/12] ksm: move pages_sharing updates
Message-ID: <20090803165315.GH23385@random.random>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031310060.16754@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908031310060.16754@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 03, 2009 at 01:11:00PM +0100, Hugh Dickins wrote:
> The pages_shared count is incremented and decremented when adding a node
> to and removing a node from the stable tree: easy to understand.  But the
> pages_sharing count was hard to follow, being adjusted in various places:
> increment and decrement it when adding to and removing from the stable tree.
> 
> And the pages_sharing variable used to include the pages_shared, then those
> were subtracted when shown in the pages_sharing sysfs file: now keep it as
> an exclusive count of leaves hanging off the stable tree nodes, throughout.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

If we stick to the subtraction semantics (that I think for users is
less intuitive as they need to understand more of the ksm code to
figure out what it means) sure ack...

I don't see the big deal of just printing total number of ksm pages in
stable tree, and the actual _total_ number of userland mappings that
are mapping those. The subtraction to see the actual sharing that is
the difference between the two numbers, can be done by the user
itself.

But then I'm fine if we stick to the substraction logic, this is a
minor detail, I just usually prefer "raw" values. (if removing the
inc/dec is beneficial at runtime as it seems then doing an addition
will provide the info I would find more intuitive in  a more efficient
way than before)

Acked-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
