Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id E8F8F6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 05:53:11 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id c4so4474039eek.1
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 02:53:10 -0700 (PDT)
Date: Tue, 23 Jul 2013 11:53:06 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
Message-ID: <20130723095306.GA26174@gmail.com>
References: <1372366385.22432.185.camel@schen9-DESK>
 <1372375873.22432.200.camel@schen9-DESK>
 <20130628093809.GB29205@gmail.com>
 <1372453461.22432.216.camel@schen9-DESK>
 <20130629071245.GA5084@gmail.com>
 <1372710497.22432.224.camel@schen9-DESK>
 <20130702064538.GB3143@gmail.com>
 <1373997195.22432.297.camel@schen9-DESK>
 <20130723094513.GA24522@gmail.com>
 <20130723095124.GW27075@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130723095124.GW27075@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Jul 23, 2013 at 11:45:13AM +0200, Ingo Molnar wrote:
>
> > Why not just try the delayed addition approach first? The spinning is 
> > time limited AFAICS, so we don't _have to_ recognize those as writers 
> > per se, only if the spinning fails and it wants to go on the waitlist. 
> > Am I missing something?
> > 
> > It will change patterns, it might even change the fairness balance - 
> > but is a legit change otherwise, especially if it helps performance.
> 
> Be very careful here. Some people (XFS) have very specific needs. Walken 
> and dchinner had a longish discussion on this a while back.

Agreed - yet it's worth at least trying it out the quick way, to see the 
main effect and to see whether that explains the performance assymetry and 
invest more effort into it.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
