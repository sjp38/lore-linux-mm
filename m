Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC8F6B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:50:13 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n2CFoAEG008358
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:50:10 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CFo9Fj2621612
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 16:50:09 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2CFo9Uj014296
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 16:50:09 +0100
Date: Thu, 12 Mar 2009 16:46:34 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] acquire mmap semaphore in pagemap_read.
Message-ID: <20090312164634.6f2027ac@skybase>
In-Reply-To: <49B92D2B.2090100@ens-lyon.org>
References: <20090312113308.6fe18a93@skybase>
	<20090312114533.GA2407@x200.localdomain>
	<20090312125410.25400d18@skybase>
	<1236871414.3213.50.camel@calx>
	<20090312162733.4e8fd197@skybase>
	<49B92D2B.2090100@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Brice Goglin <Brice.Goglin@ens-lyon.org>
Cc: Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 16:41:31 +0100
Brice Goglin <Brice.Goglin@ens-lyon.org> wrote:

> > Which would be really ugly. I still have not grasped why this will
> > introduce a deadlock though. The worst the put_user can do is to cause
> > a page fault, no? I do not see where the fault handler acquires the
> > mmap_sem as writer. It takes the mmap_sem as reader and two readers
> > should be fine.
> 
> Somebody else can acquire for write in the meantime, for instance
> another thread doing mprotect. This writer is blocked by the first
> reader, and the second reader is blocked by the writer. So both
> tasks are blocked.

I see, fair r/w locks. So nested down_read is a no-no.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
