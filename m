Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id D055F6B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 18:27:43 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <CANN689GtHw6dDeMd+2fuUz_dv_Z44XndVj2u-TNy70qkZWkpDw@mail.gmail.com>
References: <1371165333.27102.568.camel@schen9-DESK>
	 <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
	 <1371226197.27102.594.camel@schen9-DESK>
	 <1371249104.1758.20.camel@buesod1.americas.hpqcorp.net>
	 <CANN689GtHw6dDeMd+2fuUz_dv_Z44XndVj2u-TNy70qkZWkpDw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 17 Jun 2013 15:27:46 -0700
Message-ID: <1371508066.27102.639.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi,
 Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2013-06-14 at 15:47 -0700, Michel Lespinasse wrote:
> On Fri, Jun 14, 2013 at 3:31 PM, Davidlohr Bueso <davidlohr.bueso@hp.com> wrote:
> > A few ideas that come to mind are avoiding taking the ->wait_lock and
> > avoid dealing with waiters when doing the optimistic spinning (just like
> > mutexes do).
> >
> > I agree that we should first deal with the optimistic spinning before
> > adding the MCS complexity.
> 
> Maybe it would be worth disabling the MCS patch in mutex and comparing
> that to the rwsem patches ? Just to make sure the rwsem performance
> delta isn't related to that.
> 

I've tried to back out the MCS patch.  In fact, for exim, it is about 1%
faster without MCS.  So the better performance of mutex I saw was not
due to MCS.  Thanks for the suggestion.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
