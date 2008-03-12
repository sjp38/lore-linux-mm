Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2C8kjA4181708
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 08:46:45 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2C8kjqK1921146
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 09:46:45 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2C8kibg007622
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 09:46:45 +0100
Subject: Re: [patch 0/7] [rfc] VM_MIXEDMAP, pte_special, xip work
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <200803121633.34539.nickpiggin@yahoo.com.au>
References: <20080311104653.995564000@nick.local0.net>
	 <20080311213525.a5994894.akpm@linux-foundation.org>
	 <200803121633.34539.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 12 Mar 2008 09:46:42 +0100
Message-Id: <1205311602.28247.7.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@nick.local0.net, Linus Torvalds <torvalds@linux-foundation.org>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-03-12 at 16:33 +1100, Nick Piggin wrote:
> s390 is slightly different because it doesn't use a standard memory model
> but something more dynamic. It doesn't quite do the right thing here, so
> it uses pte_special. It could possibly tighten up pfn_valid, however I
> think there are various reasons why they don't want to (one is that they
> need to take a global lock in order to search their list of extents;
> which will suck for VM_MIXEDMAP performance).

Indeed. Under z/VM we have mappable memory segments named DCSS that can
have different types. Dependend on the type we either want to do
refcounting (exclusive write for memory hotplug) or not (read-only
shared for memory sharing). pfn_valid() would have to scan the list of
DCCSes to find out which type the segment has. That is way too
expensive.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
