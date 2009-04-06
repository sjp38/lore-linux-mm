Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 04C5A5F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 03:32:41 -0400 (EDT)
Message-ID: <49D9B031.2090209@redhat.com>
Date: Mon, 06 Apr 2009 10:33:05 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux v2
References: <1238855722-32606-1-git-send-email-ieidus@redhat.com> <200904061704.50052.nickpiggin@yahoo.com.au>
In-Reply-To: <200904061704.50052.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Sunday 05 April 2009 01:35:18 Izik Eidus wrote:
>
>   
>> This driver is very useful for KVM as in cases of runing multiple guests
>> operation system of the same type.
>> (For desktop work loads we have achived more than x2 memory overcommit
>> (more like x3))
>>     
>
> Interesting that it is a desirable workload to have multiple guests each
> running MS office.
>
> I wonder, can windows enter a paravirtualised guest mode for KVM?

Windows has some support for paravirtualization, for example it can use 
hypercalls instead of tlb flush IPIs.

>  And can
> you detect page allocation/freeing events?
>   

Not that I know of.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
