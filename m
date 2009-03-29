Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 95A376B003D
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 10:23:21 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id n2TENen0010140
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 14:23:40 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2TENe9s3702892
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 16:23:40 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2TENej5020970
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 16:23:40 +0200
Date: Sun, 29 Mar 2009 16:23:36 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [patch 0/6] Guest page hinting version 7.
Message-ID: <20090329162336.7c0700e9@skybase>
In-Reply-To: <200903281705.29798.rusty@rustcorp.com.au>
References: <20090327150905.819861420@de.ibm.com>
	<200903281705.29798.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, akpm@osdl.org, nickpiggin@yahoo.com.au, frankeh@watson.ibm.com, riel@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Sat, 28 Mar 2009 17:05:28 +1030
Rusty Russell <rusty@rustcorp.com.au> wrote:

> On Saturday 28 March 2009 01:39:05 Martin Schwidefsky wrote:
> > Greetings,
> > the circus is back in town -- another version of the guest page hinting
> > patches. The patches differ from version 6 only in the kernel version,
> > they apply against 2.6.29. My short sniff test showed that the code
> > is still working as expected.
> > 
> > To recap (you can skip this if you read the boiler plate of the last
> > version of the patches):
> > The main benefit for guest page hinting vs. the ballooner is that there
> > is no need for a monitor that keeps track of the memory usage of all the
> > guests, a complex algorithm that calculates the working set sizes and for
> > the calls into the guest kernel to control the size of the balloons.
> 
> I thought you weren't convinced of the concrete benefits over ballooning,
> or am I misremembering?

The performance test I have seen so far show that the benefits of
ballooning vs. guest page hinting are about the same. I am still
convinced that the guest page hinting is the way to go because you do
not need an external monitor. Calculating the working set size for a
guest is a challenge. With guest page hinting there is no need for a
working set size calculation.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
