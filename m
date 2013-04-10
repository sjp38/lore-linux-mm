Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 532FF6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 04:52:40 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 18:45:09 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id B946D2BB0050
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 18:52:35 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3A8d86K4129042
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 18:39:08 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3A8qYub012984
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 18:52:35 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 06/25] powerpc: Reduce PTE table memory wastage
In-Reply-To: <87obdmom5o.fsf@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1365055083-31956-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130410071453.GB24786@concordia> <87obdmom5o.fsf@linux.vnet.ibm.com>
Date: Wed, 10 Apr 2013 14:22:31 +0530
Message-ID: <87ip3uojhs.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <michael@ellerman.id.au>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> Michael Ellerman <michael@ellerman.id.au> writes:
>
>> On Thu, Apr 04, 2013 at 11:27:44AM +0530, Aneesh Kumar K.V wrote:
>>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>> 
>>> We allocate one page for the last level of linux page table. With THP and
>>> large page size of 16MB, that would mean we are wasting large part
>>> of that page. To map 16MB area, we only need a PTE space of 2K with 64K
>>> page size. This patch reduce the space wastage by sharing the page
>>> allocated for the last level of linux page table with multiple pmd
>>> entries. We call these smaller chunks PTE page fragments and allocated
>>> page, PTE page.
>>
>> This is not compiling for me:
>>
>> arch/powerpc/mm/mmu_context_hash64.c:118:3: error: implicit declaration of function 'reset_page_mapcount'
>>
>
> can you share the .config ? I have the git tree at 
>
> git://github.com/kvaneesh/linux.git ppc64-thp-7

22b751c3d0376e86a377e3a0aa2ddbbe9d2eefc1 . Will rebase to latest linus tree.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
