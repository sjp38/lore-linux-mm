Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 24EF06B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 19:19:03 -0400 (EDT)
Message-ID: <51BF9960.904@intel.com>
Date: Tue, 18 Jun 2013 07:18:56 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: Performance regression from switching lock to rw-sem for anon-vma
 tree
References: <1371165333.27102.568.camel@schen9-DESK>  <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>  <51BD8A77.2080201@intel.com>  <1371486122.1778.14.camel@buesod1.americas.hpqcorp.net> <1371494746.27102.633.camel@schen9-DESK>
In-Reply-To: <1371494746.27102.633.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 06/18/2013 02:45 AM, Tim Chen wrote:
>>> +			if (unlikely(sem->count < RWSEM_WAITING_BIAS)) {
>>> > > +				cpu_relax();
>>> > > +				continue;
>>> > > +			}
> The above two if statements could be cleaned up as a single check:
> 		
> 			if (unlikely(sem->count < RWSEM_WAITING_BIAS))
> 				return sem;
> 	 
> This one statement is sufficient to check that we don't have a writer
> stolen the lock before we attempt to acquire the read lock by modifying
> sem->count.  
> 
> 

Thanks. I will send out the patchset base your suggestion.


-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
