Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 583778D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 08:32:44 -0400 (EDT)
Date: Mon, 21 Mar 2011 13:32:17 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction beware writeback
Message-ID: <20110321123217.GA5719@random.random>
References: <alpine.LSU.2.00.1103192318100.1877@sister.anvils>
 <20110320174750.GA5653@random.random>
 <alpine.LSU.2.00.1103201927420.7353@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1103201927420.7353@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sun, Mar 20, 2011 at 07:37:02PM -0700, Hugh Dickins wrote:
> On Sun, 20 Mar 2011, Andrea Arcangeli wrote:
> > 
> > Interesting that slab allocates with order > 0 an object that is <4096
> > bytes. Is this related to slab_break_gfp_order?
> 
> No, it's SLUB I'm using (partly for its excellent debugging, partly
> to trigger issues like this).  Remember, that's SLUB's great weakness,
> that for optimal efficiency it relies upon higher order pages than you'd
> expect.  It's much better since Christoph put in the ORDER_FALLBACK, but
> still makes a first attempt for a higher order page, which is liable to
> stir up page_alloc more than we'd like.

Ah ok, that explains it... I didn't realize you used SLUB sorry.

I use SLAB as it's measurably faster in most workloads even on larger
servers (but it will consume more memory on with an huge number of
cpus, up to 128 CPUs it's no big deal). My cellphone uses SLUB though
(kabi issues with evil rfs.ko or I would have switched already).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
