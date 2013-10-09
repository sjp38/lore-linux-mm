Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 303E76B0039
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 13:18:56 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so1243610pdj.40
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 10:18:55 -0700 (PDT)
Date: Wed, 9 Oct 2013 19:18:49 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/63] Basic scheduler support for automatic NUMA
 balancing V9
Message-ID: <20131009171849.GH13848@laptop.programming.kicks-ass.net>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131009162801.GA10452@gmail.com>
 <20131009170837.GF13848@laptop.programming.kicks-ass.net>
 <20131009171537.GA12575@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131009171537.GA12575@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 09, 2013 at 07:15:37PM +0200, Ingo Molnar wrote:
> > It looks like -march=geode generates similar borkage to the
> > -march=winchip2 like we found earlier today.
> > 
> > Must be randconfig luck to only hit it now.
> 
> Yes, very weird but such is life :-)
> 
> Also note that this reproduces with GCC 4.7 ...

Yes, it does so too for me, I tried both 4.7 and 4.8; they generate
different but similarly broken code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
