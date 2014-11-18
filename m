Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id CCA186B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 11:56:51 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so2760057pdb.18
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 08:56:51 -0800 (PST)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id dr2si38647127pdb.66.2014.11.18.08.56.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 08:56:50 -0800 (PST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 18 Nov 2014 22:26:47 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 1BF19E004C
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 22:27:01 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAIGuwDt38011000
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 22:26:58 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAIGugPP006759
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 22:26:42 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/7] Replace _PAGE_NUMA with PAGE_NONE protections
In-Reply-To: <546B74F5.10004@oracle.com>
References: <1415971986-16143-1-git-send-email-mgorman@suse.de> <5466C8A5.3000402@oracle.com> <20141118154246.GB2725@suse.de> <546B74F5.10004@oracle.com>
Date: Tue, 18 Nov 2014 22:26:41 +0530
Message-ID: <87tx1w78hi.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

Sasha Levin <sasha.levin@oracle.com> writes:

> On 11/18/2014 10:42 AM, Mel Gorman wrote:
>> 1. I'm assuming this is a KVM setup but can you confirm?
>
> Yes.
>
>> 2. Are you using numa=fake=N?
>
> Yes. numa=fake=24, which is probably way more nodes on any physical machine
> than the new code was tested on?
>
>> 3. If you are using fake NUMA, what happens if you boot without it as
>>    that should make the patches a no-op?
>
> Nope, still seeing it without fake numa.
>
>> 4. Similarly, does the kernel boot properly without without patches?
>
> Yes, the kernel works fine without the patches both with and without fake
> numa.


Hmm that is interesting. I am not sure how writeback_fid can be
related. We use writeback fid to enable client side caching with 9p
(cache=loose). We use this fid to write back dirty pages later. Can you
share the qemu command line used, 9p mount options and the test details ? 


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
