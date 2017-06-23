Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36D156B0292
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 19:29:42 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u110so16474270wrb.14
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 16:29:42 -0700 (PDT)
Received: from mail-wr0-x236.google.com (mail-wr0-x236.google.com. [2a00:1450:400c:c0c::236])
        by mx.google.com with ESMTPS id l8si5315588wmg.133.2017.06.23.16.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 16:29:40 -0700 (PDT)
Received: by mail-wr0-x236.google.com with SMTP id c11so83983120wrc.3
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 16:29:40 -0700 (PDT)
MIME-Version: 1.0
From: Luigi Semenzato <semenzato@google.com>
Date: Fri, 23 Jun 2017 16:29:39 -0700
Message-ID: <CAA25o9T1WmkWJn1LA-vS=W_Qu8pBw3rfMtTreLNu8fLuZjTDsw@mail.gmail.com>
Subject: OOM kills with lots of free swap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>

It is fairly easy to trigger OOM-kills with almost empty swap, by
running several fast-allocating processes in parallel.  I can
reproduce this on many 3.x kernels (I think I tried also on 4.4 but am
not sure).  I am hoping this is a known problem.

I tried to debug this in the past, by backtracking from the call to
the OOM code, and adding instrumentation to understand why the task
failed to allocate (or even make progress, apparently), but my effort
did not yield results within reasonable time.

I believe that it is possible that one task succeeds in reclaiming
pages, and then another task takes those pages before the first task
has a chance to get them.  But in that case the first task should
still notice progress and should retry, correct?  Is it possible in
theory that one task fails to allocate AND fails to make progress
while other tasks succeed?

(I asked this question, in not so many words, in 2013, but received no answers.)

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
