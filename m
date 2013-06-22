Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 17F7A6B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 20:15:34 -0400 (EDT)
Message-ID: <1371860128.13136.14.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 1/2] rwsem: check the lock before cpmxchg in
 down_write_trylock and rwsem_do_wake
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Fri, 21 Jun 2013 17:15:28 -0700
In-Reply-To: <51C4EB63.2000104@intel.com>
References: <cover.1371855277.git.tim.c.chen@linux.intel.com>
	 <1371858695.22432.4.camel@schen9-DESK> <51C4EB63.2000104@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Sat, 2013-06-22 at 08:10 +0800, Alex Shi wrote:
> On 06/22/2013 07:51 AM, Tim Chen wrote:
> > Doing cmpxchg will cause cache bouncing when checking
> > sem->count. This could cause scalability issue
> > in a large machine (e.g. a 80 cores box).
> > 
> > A pre-read of sem->count can mitigate this.
> > 
> > Signed-off-by: Alex Shi <alex.shi@intel.com>
> > Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> 
> Hi Tim,
> there is a technical error in this patch.
> the "From: " line should be 'Alex Shi', since he made the most input of
> this patch.
> 
> And I still think split this patch to 4 smaller will make it more simple
> to review, that I had sent you and Davidlohr.

Yep, and you had updated the changelog for 1/4: rwsem: check the lock
before cpmxchg in down_write_trylock to:

"cmpxchg will cause cache bouncing when do the value checking, that
cause scalability issue in a large machine (like a 80 cores box).

A lock status pre-read can relief this."

> 
> could you like to re-send with my 4 patch version? :)

For those 4 patches:
Acked-by: Davidlohr Bueso <davidlohr.bueso@hp.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
