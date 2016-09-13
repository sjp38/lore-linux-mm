Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B6CF26B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 10:54:18 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t7so49508341qkh.1
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 07:54:18 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id h10si1153973uaa.153.2016.09.13.07.54.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 07:54:18 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id m62so127805615vkd.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 07:54:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160913131802.oiwxgpmccn7uufef@treble>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-2-git-send-email-byungchul.park@lge.com> <20160913131802.oiwxgpmccn7uufef@treble>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Tue, 13 Sep 2016 23:54:17 +0900
Message-ID: <CANrsvRMvk_SdaqN-8cr4VJNd=CCrGv__36KwcpdjTUczm=Y0nA@mail.gmail.com>
Subject: Re: [PATCH v3 01/15] x86/dumpstack: Optimize save_stack_trace
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Byungchul Park <byungchul.park@lge.com>, peterz@infradead.org, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Sep 13, 2016 at 10:18 PM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> On Tue, Sep 13, 2016 at 06:45:00PM +0900, Byungchul Park wrote:
>> Currently, x86 implementation of save_stack_trace() is walking all stack
>> region word by word regardless of what the trace->max_entries is.
>> However, it's unnecessary to walk after already fulfilling caller's
>> requirement, say, if trace->nr_entries >= trace->max_entries is true.
>>
>> I measured its overhead and printed its difference of sched_clock() with
>> my QEMU x86 machine. The latency was improved over 70% when
>> trace->max_entries = 5.
>
> This code will (probably) be obsoleted soon with my new unwinder.

Hello,

You are right.

I also think this will probably be obsoleted with yours.
So I didn't modify any details of the patch.
I will take your comment into account if it becomes necessary.

Anyway, crossrelease needs this patch to work smoothly.
That's only reason why I included this patch in the thread.

Thank you,
Byungchul

> Also, my previous comment was ignored:
>
>   Instead of adding a new callback, why not just check the ops->address()
>   return value?  It already returns an error if the array is full.
>
>   I think that would be cleaner and would help prevent more callback
>   sprawl.
>
> --
> Josh



-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
