Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD3066B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 11:14:25 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id e2so56022441ybi.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 08:14:25 -0700 (PDT)
Received: from mail-vk0-x236.google.com (mail-vk0-x236.google.com. [2607:f8b0:400c:c05::236])
        by mx.google.com with ESMTPS id t68si7574532vke.133.2016.09.13.08.14.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 08:14:25 -0700 (PDT)
Received: by mail-vk0-x236.google.com with SMTP id 16so162979652vko.2
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 08:14:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160913100520.GA5035@twins.programming.kicks-ass.net>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-8-git-send-email-byungchul.park@lge.com> <20160913100520.GA5035@twins.programming.kicks-ass.net>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Wed, 14 Sep 2016 00:14:22 +0900
Message-ID: <CANrsvRPQ=7ryYkYQpHUzK3Yzs_Yf-VH=1c6g=QnqqEP1WTJ5Xg@mail.gmail.com>
Subject: Re: [PATCH v3 07/15] lockdep: Implement crossrelease feature
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Sep 13, 2016 at 7:05 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, Sep 13, 2016 at 06:45:06PM +0900, Byungchul Park wrote:
>> Crossrelease feature calls a lock 'crosslock' if it is releasable
>> in any context. For crosslock, all locks having been held in the
>> release context of the crosslock, until eventually the crosslock
>> will be released, have dependency with the crosslock.
>>
>> Using crossrelease feature, we can detect deadlock possibility even
>> for lock_page(), wait_for_complete() and so on.
>>
>
> Completely inadequate.
>
> Please explain how cross-release does what it does. Talk about lock
> graphs and such.

Hello,

Could you tell me about what you intend, in detail?
I'm now asking you since I really don't know it.

The reason I reworked on documentation was to
answer your requests like "explain mathematically",
"tell how it works with graph" and so on. Should I
do anything else? I really don't know it.

If I missed something, please let me know. Then I
can do whatever you want if it's necessary.

> I do not have time to reverse engineer this stuff.

Why don't you read the document in the last patch
first? The document is my answer for your requests
you asked in version 1 thread. Insufficient?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
