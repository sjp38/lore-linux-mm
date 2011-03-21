Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 78C658D0039
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 22:37:24 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p2L2bH5c012059
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 19:37:17 -0700
Received: from iwr19 (iwr19.prod.google.com [10.241.69.83])
	by kpbe20.cbf.corp.google.com with ESMTP id p2L2bBrA025720
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 19:37:16 -0700
Received: by iwr19 with SMTP id 19so7988719iwr.35
        for <linux-mm@kvack.org>; Sun, 20 Mar 2011 19:37:11 -0700 (PDT)
Date: Sun, 20 Mar 2011 19:37:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: compaction beware writeback
In-Reply-To: <20110320174750.GA5653@random.random>
Message-ID: <alpine.LSU.2.00.1103201927420.7353@sister.anvils>
References: <alpine.LSU.2.00.1103192318100.1877@sister.anvils> <20110320174750.GA5653@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sun, 20 Mar 2011, Andrea Arcangeli wrote:
> 
> Interesting that slab allocates with order > 0 an object that is <4096
> bytes. Is this related to slab_break_gfp_order?

No, it's SLUB I'm using (partly for its excellent debugging, partly
to trigger issues like this).  Remember, that's SLUB's great weakness,
that for optimal efficiency it relies upon higher order pages than you'd
expect.  It's much better since Christoph put in the ORDER_FALLBACK, but
still makes a first attempt for a higher order page, which is liable to
stir up page_alloc more than we'd like.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
