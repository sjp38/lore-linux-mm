Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id A1B176B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 05:51:47 -0400 (EDT)
Date: Tue, 23 Jul 2013 11:51:24 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
Message-ID: <20130723095124.GW27075@twins.programming.kicks-ass.net>
References: <20130627083651.GA3730@gmail.com>
 <1372366385.22432.185.camel@schen9-DESK>
 <1372375873.22432.200.camel@schen9-DESK>
 <20130628093809.GB29205@gmail.com>
 <1372453461.22432.216.camel@schen9-DESK>
 <20130629071245.GA5084@gmail.com>
 <1372710497.22432.224.camel@schen9-DESK>
 <20130702064538.GB3143@gmail.com>
 <1373997195.22432.297.camel@schen9-DESK>
 <20130723094513.GA24522@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130723094513.GA24522@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Tue, Jul 23, 2013 at 11:45:13AM +0200, Ingo Molnar wrote:
> Why not just try the delayed addition approach first? The spinning is time 
> limited AFAICS, so we don't _have to_ recognize those as writers per se, 
> only if the spinning fails and it wants to go on the waitlist. Am I 
> missing something?
> 
> It will change patterns, it might even change the fairness balance - but 
> is a legit change otherwise, especially if it helps performance.

Be very careful here. Some people (XFS) have very specific needs. Walken
and dchinner had a longish discussion on this a while back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
