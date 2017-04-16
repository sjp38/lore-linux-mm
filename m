Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 274376B0038
	for <linux-mm@kvack.org>; Sun, 16 Apr 2017 02:31:08 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p33so10645266qte.6
        for <linux-mm@kvack.org>; Sat, 15 Apr 2017 23:31:08 -0700 (PDT)
Received: from mail-qk0-x235.google.com (mail-qk0-x235.google.com. [2607:f8b0:400d:c09::235])
        by mx.google.com with ESMTPS id r2si7084160qtc.138.2017.04.15.23.31.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Apr 2017 23:31:07 -0700 (PDT)
Received: by mail-qk0-x235.google.com with SMTP id f133so88469157qke.2
        for <linux-mm@kvack.org>; Sat, 15 Apr 2017 23:31:06 -0700 (PDT)
MIME-Version: 1.0
From: Pavel Roskin <plroskin@gmail.com>
Date: Sat, 15 Apr 2017 23:31:06 -0700
Message-ID: <CAN_72e3WpZXP3kGPeWjEpsfigGjnURLFTVsUf_P7ozzT8cN+bA@mail.gmail.com>
Subject: Allocating mock memory resources
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello!

I'm working on a device driver for hardware that is being developed.
I'm coding against the specification and hoping for the best. It would
be very handy to have a mock implementation of the hardware so I could
test the driver against it. In the end, it would be an integration
test for the driver, which could be useful even after the hardware
arrives. For example, I could emulate hardware failures and see how
the driver reacts. Moreover, a driver test framework would be useful
for others.

One issue I'm facing is creating resources for the device. Luckily,
the driver only needs memory resources. It should be simple to
allocate such resources in system RAM, but I could not find a good way
to do it. Either the resource allocation fails, or the kernel panics
right away, or it panics when I run "cat /proc/iomem"

I ended up limiting the memory available to the kernel using the
"mem=" directive and hardcoding the address pointing to RAM beyond
what the kernel uses. I would prefer to have an approach that doesn't
require changes to the kernel command line. It there a safe way to
allocate a memory resource in system RAM?

-- 
Regards,
Pavel Roskin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
