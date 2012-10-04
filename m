Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 013D76B0122
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 12:31:02 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 5 Oct 2012 02:27:42 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q94GLLcJ27459698
	for <linux-mm@kvack.org>; Fri, 5 Oct 2012 02:21:21 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q94GUtic029662
	for <linux-mm@kvack.org>; Fri, 5 Oct 2012 02:30:55 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/8] sparc64: Eliminate PTE table memory wastage.
In-Reply-To: <20121002.182642.49574627747120711.davem@davemloft.net>
References: <20121002.182642.49574627747120711.davem@davemloft.net>
Date: Thu, 04 Oct 2012 22:00:48 +0530
Message-ID: <87y5jmfbd3.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org

David Miller <davem@davemloft.net> writes:

> We've split up the PTE tables so that they take up half a page instead
> of a full page.  This is in order to facilitate transparent huge page
> support, which works much better if our PMDs cover 4MB instead of 8MB.
>
> What we do is have a one-behind cache for PTE table allocations in the
> mm struct.
>
> This logic triggers only on allocations.  For example, we don't try to
> keep track of free'd up page table blocks in the style that the s390
> port does.

I am also implementing a similar change for powerpc. We have a 64K page
size, and want to make sure PMD cover 16MB, which is the huge page size
supported by the hardware. I was looking at using the s390 logic,
considering we have 16 PMDs mapping to same PTE page. Should we look at
generalizing the case so that other architectures can start using the
same code ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
