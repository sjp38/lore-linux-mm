Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65B6D280749
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 20:25:03 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id q72so3857471ywg.15
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 17:25:03 -0700 (PDT)
Received: from mail-yw0-x232.google.com (mail-yw0-x232.google.com. [2607:f8b0:4002:c05::232])
        by mx.google.com with ESMTPS id f5si62177ybk.750.2017.08.22.17.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 17:25:01 -0700 (PDT)
Received: by mail-yw0-x232.google.com with SMTP id s143so1474518ywg.1
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 17:25:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALvZod6q=6vVOjsKNX9ktpRpcv_Dhj=Zo3L8SPVvRW2SrgfCDw@mail.gmail.com>
References: <20170818011023.181465-1-shakeelb@google.com> <CALvZod444NZaw9wcdSMs5Y60a0cV4j9SEt-TLBJT34OJ_yg3CQ@mail.gmail.com>
 <20170818143450.7584a3f86abf96f4c43fccd0@linux-foundation.org> <CALvZod6q=6vVOjsKNX9ktpRpcv_Dhj=Zo3L8SPVvRW2SrgfCDw@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 22 Aug 2017 17:25:00 -0700
Message-ID: <CALvZod73huYukNBUvn3XS40V4SQYk4H5_Jhv4Qp0446-d4P0rg@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: fadvise: avoid fadvise for fs without backing device
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

>> It doesn't sound like a risky change to me, although perhaps someone is
>> depending on the current behaviour for obscure reasons, who knows.
>>
>> What are the reasons for this change?  Is the current behaviour causing
>> some sort of problem for someone?
>
> Yes, one of our generic library does fadvise(FADV_DONTNEED). Recently
> we observed high latency in fadvise() and notice that the users have
> started using tmpfs files and the latency was due to expensive remote
> LRU cache draining. For normal tmpfs files (have data written on
> them), fadvise(FADV_DONTNEED) will always trigger the un-needed remote
> cache draining.
>

Hi Andrew, do you have more comments or concerns?

>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
