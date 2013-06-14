Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 7EE626B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 18:47:14 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id x12so2671303ief.12
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 15:47:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1371249104.1758.20.camel@buesod1.americas.hpqcorp.net>
References: <1371165333.27102.568.camel@schen9-DESK>
	<1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
	<1371226197.27102.594.camel@schen9-DESK>
	<1371249104.1758.20.camel@buesod1.americas.hpqcorp.net>
Date: Fri, 14 Jun 2013 15:47:13 -0700
Message-ID: <CANN689GtHw6dDeMd+2fuUz_dv_Z44XndVj2u-TNy70qkZWkpDw@mail.gmail.com>
Subject: Re: Performance regression from switching lock to rw-sem for anon-vma tree
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, Jun 14, 2013 at 3:31 PM, Davidlohr Bueso <davidlohr.bueso@hp.com> wrote:
> A few ideas that come to mind are avoiding taking the ->wait_lock and
> avoid dealing with waiters when doing the optimistic spinning (just like
> mutexes do).
>
> I agree that we should first deal with the optimistic spinning before
> adding the MCS complexity.

Maybe it would be worth disabling the MCS patch in mutex and comparing
that to the rwsem patches ? Just to make sure the rwsem performance
delta isn't related to that.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
