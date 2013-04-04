Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A7C406B00A4
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 02:11:11 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 16:00:09 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id B6DEF2BB0050
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 17:11:07 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345vuXJ63832218
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 16:57:56 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r346B7dS003112
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 17:11:07 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 00/25] THP support for PPC64
In-Reply-To: <515D16E4.8020207@gmail.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <515D16E4.8020207@gmail.com>
Date: Thu, 04 Apr 2013 11:40:54 +0530
Message-ID: <87bo9u4yhd.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Simon Jeons <simon.jeons@gmail.com> writes:

> Hi Aneesh,
> On 04/04/2013 01:57 PM, Aneesh Kumar K.V wrote:
>> Hi,
>>
>> This patchset adds transparent hugepage support for PPC64.
>>
>> TODO:
>> * hash preload support in update_mmu_cache_pmd (we don't do that for hugetlb)
>>
>> Some numbers:
>>
>> The latency measurements code from Anton  found at
>> http://ozlabs.org/~anton/junkcode/latency2001.c
>
> Is there test case against x86?
>

That test should work even with x86

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
