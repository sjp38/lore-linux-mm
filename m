Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 97A546B0255
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 17:35:47 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l68so127467076wml.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 14:35:47 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id o8si21847357wjo.165.2016.03.07.14.35.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Mar 2016 14:35:46 -0800 (PST)
From: Kamal Mostafa <kamal@canonical.com>
Subject: [4.2.y-ckt stable] Patch "x86/mm: Fix vmalloc_fault() to handle large pages properly" has been added to the 4.2.y-ckt tree
Date: Mon,  7 Mar 2016 14:34:26 -0800
Message-Id: <1457390066-32641-1-git-send-email-kamal@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Henning Schild <henning.schild@siemens.com>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Luis R . Rodriguez" <mcgrof@suse.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Ingo Molnar <mingo@kernel.org>, Kamal Mostafa <kamal@canonical.com>, kernel-team@lists.ubuntu.com

This is a note to let you know that I have just added a patch titled

    x86/mm: Fix vmalloc_fault() to handle large pages properly

to the linux-4.2.y-queue branch of the 4.2.y-ckt extended stable tree 
which can be found at:

    http://kernel.ubuntu.com/git/ubuntu/linux.git/log/?h=linux-4.2.y-queue

This patch is scheduled to be released in version 4.2.8-ckt5.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 4.2.y-ckt tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Kamal

---8<------------------------------------------------------------
