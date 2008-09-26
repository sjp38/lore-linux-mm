Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m8QAhEWg083172
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 10:43:14 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8QAhE0l3387602
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 12:43:14 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8QAhEpd001799
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 12:43:14 +0200
Subject: Re: Populating multiple ptes at fault time
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <48DBD94A.50905@goop.org>
References: <48D142B2.3040607@goop.org> <48D17E75.80807@redhat.com>
	 <48D1851B.70703@goop.org> <48D18919.9060808@redhat.com>
	 <48D18C6B.5010407@goop.org> <48D2B970.7040903@redhat.com>
	 <48D2D3B2.10503@goop.org> <48D2E65A.6020004@redhat.com>
	 <48D2EBBB.205@goop.org> <48D2F05C.4040000@redhat.com>
	 <48D2F571.4010504@goop.org> <48DA333C.2050900@redhat.com>
	 <48DBD94A.50905@goop.org>
Content-Type: text/plain
Date: Fri, 26 Sep 2008 12:26:27 +0200
Message-Id: <1222424787.22679.17.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Avi Kivity <avi@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-09-25 at 11:32 -0700, Jeremy Fitzhardinge wrote:
> Very few places actually care about the state of the A/D bits; would it
> be expensive to make those places explicitly ask for synchronization
> before testing the bits (or alternatively, have an explicit query
> operation rather than just poking about in the ptes).  Martin, does this
> help with s390's per-page (vs per-pte) A/D state?

With the kvm support the situation on s390 recently has grown a tad more
complicated. We now have dirty bits in the per-page storage key and in
the pgste (page table entry extension) for the kvm guests. For the A/D
bits in the storage key the new pte operations won't help, for the kvm
related bits they could make a difference.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
