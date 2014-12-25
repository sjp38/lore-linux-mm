Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 062306B0032
	for <linux-mm@kvack.org>; Thu, 25 Dec 2014 07:01:14 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so11797245pad.9
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 04:01:13 -0800 (PST)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id vj6si23803151pbc.115.2014.12.25.04.01.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Dec 2014 04:01:12 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id r10so11558724pdi.35
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 04:01:11 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 25 Dec 2014 16:01:11 +0400
Message-ID: <CAPAsAGwn=KcWOgrTHeWCS18jWq2wK0JGJxYDT1Y4RUpim6=OuQ@mail.gmail.com>
Subject: [LSF/MM TOPIC] The kernel address sanitizer
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>

Hello

I'm working on the kernel address sanitizer (KASan) -
http://thread.gmane.org/gmane.linux.kernel.mm/120041
KASan is runtime memory debugger designed to find use-after-free and
out-of-bounds accesses.

Seems we've come to agreement that KASan is useful and deserves to be
in mainline, yet the feedback on patches is poor.
It seems like they are stalled, so I would like to discuss the future
of it. I hope this will help in pushing it forward.

Besides we have ideas for further improvements, like:

 * Detecting reads of uninitialized memory.
 * Quarantine - delaying reallocation of freed memory to increase
chance of catching use after free bugs.
                    In combination with DEBUG_PAGEALLOC or slab
poisoning it's useful even without KASan.
 * and some more...

Perhaps it's worth to discuss them as well. I'll be able to come up
with some prototype until summit if needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
