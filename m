Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id CFB2A6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:55:23 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 13:19:53 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 65A141258052
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 13:26:44 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3A7tGCl7668076
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 13:25:16 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3A7tHpR020149
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:55:18 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 06/25] powerpc: Reduce PTE table memory wastage
In-Reply-To: <20130410071453.GB24786@concordia>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1365055083-31956-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130410071453.GB24786@concordia>
Date: Wed, 10 Apr 2013 13:24:59 +0530
Message-ID: <87obdmom5o.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <michael@ellerman.id.au>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Michael Ellerman <michael@ellerman.id.au> writes:

> On Thu, Apr 04, 2013 at 11:27:44AM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> We allocate one page for the last level of linux page table. With THP and
>> large page size of 16MB, that would mean we are wasting large part
>> of that page. To map 16MB area, we only need a PTE space of 2K with 64K
>> page size. This patch reduce the space wastage by sharing the page
>> allocated for the last level of linux page table with multiple pmd
>> entries. We call these smaller chunks PTE page fragments and allocated
>> page, PTE page.
>
> This is not compiling for me:
>
> arch/powerpc/mm/mmu_context_hash64.c:118:3: error: implicit declaration of function 'reset_page_mapcount'
>

can you share the .config ? I have the git tree at 

git://github.com/kvaneesh/linux.git ppc64-thp-7

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
