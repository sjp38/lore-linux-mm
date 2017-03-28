Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B32606B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 19:41:27 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g124so39210pgc.1
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 16:41:27 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 1si5394934pgs.96.2017.03.28.16.41.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 16:41:26 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id o123so6494pga.1
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 16:41:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170328130128.101773-1-dvyukov@google.com>
References: <20170328130128.101773-1-dvyukov@google.com>
From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Wed, 29 Mar 2017 08:41:06 +0900
Message-ID: <CAC5umyhYbez6bpM0QnS3icuRCq2g-=0Yf-pj4+kxedmrp6hnwA@mail.gmail.com>
Subject: Re: [PATCH v2] fault-inject: support systematic fault injection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

2017-03-28 22:01 GMT+09:00 Dmitry Vyukov <dvyukov@google.com>:
> Add /proc/self/task/<current-tid>/fail-nth file that allows failing
> 0-th, 1-st, 2-nd and so on calls systematically.
> Excerpt from the added documentation:
>
> ===
> Write to this file of integer N makes N-th call in the current task fail
> (N is 0-based). Read from this file returns a single char 'Y' or 'N'
> that says if the fault setup with a previous write to this file was
> injected or not, and disables the fault if it wasn't yet injected.
> Note that this file enables all types of faults (slab, futex, etc).
> This setting takes precedence over all other generic settings like
> probability, interval, times, etc. But per-capability settings
> (e.g. fail_futex/ignore-private) take precedence over it.
> This feature is intended for systematic testing of faults in a single
> system call. See an example below.
> ===

This asymmetric read/write interface looks a bit odd. (write a string
representation of integer, but read Y or N).

How about just return the string representation of task->fail_nth for
read and let the user space tools check if it is zero or not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
