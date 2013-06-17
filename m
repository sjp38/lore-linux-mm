Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 7EEC96B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 19:35:23 -0400 (EDT)
Message-ID: <1371512120.1778.40.camel@buesod1.americas.hpqcorp.net>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Mon, 17 Jun 2013 16:35:20 -0700
In-Reply-To: <51BF99B0.4040509@intel.com>
References: <1371165333.27102.568.camel@schen9-DESK>
	  <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
	  <51BD8A77.2080201@intel.com>
	 <1371486122.1778.14.camel@buesod1.americas.hpqcorp.net>
	 <51BF99B0.4040509@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 2013-06-18 at 07:20 +0800, Alex Shi wrote:
> On 06/18/2013 12:22 AM, Davidlohr Bueso wrote:
> > After a lot of benchmarking, I finally got the ideal results for aim7,
> > so far: this patch + optimistic spinning with preemption disabled. Just
> > like optimistic spinning, this patch by itself makes little to no
> > difference, yet combined is where we actually outperform 3.10-rc5. In
> > addition, I noticed extra throughput when disabling preemption in
> > try_optimistic_spin().
> > 
> > With i_mmap as a rwsem and these changes I could see performance
> > benefits for alltests (+14.5%), custom (+17%), disk (+11%), high_systime
> > (+5%), shared (+15%) and short (+4%), most of them after around 500
> > users, for fewer users, it made little to no difference.
> 
> A pretty good number. what's the cpu number in your machine? :)

8-socket, 80 cores (ht off)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
