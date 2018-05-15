Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFC3A6B02AE
	for <linux-mm@kvack.org>; Tue, 15 May 2018 10:37:21 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f35-v6so190109plb.10
        for <linux-mm@kvack.org>; Tue, 15 May 2018 07:37:21 -0700 (PDT)
Received: from mx143.netapp.com (mx143.netapp.com. [2620:10a:4005:8000:2306::c])
        by mx.google.com with ESMTPS id l186-v6si191851pfl.155.2018.05.15.07.37.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 07:37:20 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514144901.0fe99d240ff8a53047dd512e@linux-foundation.org>
 <20180515004406.GB5168@bombadil.infradead.org>
 <cff721c3-65e8-c1e8-9f6d-c37ce6e56416@netapp.com>
 <20180515141721.GF12217@hirez.programming.kicks-ass.net>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <99bd469f-5cec-c537-ba3e-738956070a8f@netapp.com>
Date: Tue, 15 May 2018 17:36:44 +0300
MIME-Version: 1.0
In-Reply-To: <20180515141721.GF12217@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Boaz Harrosh <boazh@netapp.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jeff Moyer <jmoyer@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 15/05/18 17:17, Peter Zijlstra wrote:
<>
>>
>> So I would love some mm guy to explain where are those bits collected?
> 
> Depends on the architecture, some architectures only ever set bits,
> some, like x86, clear bits again. You want to look at switch_mm().
> 
> Basically x86 clears the bit again when we switch away from the mm and
> have/will invalidate TLBs for it in doing so.
> 

Ha, OK I am starting to get a picture.

>> Which brings me to another question. How can I find from
>> within a thread Say at the file_operations->mmap() call that the thread
>> is indeed core-pinned. What mm_cpumask should I inspect?
> 
> is_percpu_thread().

Right thank you a lot Peter. this helps.

Boaz
> .
> 
