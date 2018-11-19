Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9BBE66B1B00
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:22:05 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m1-v6so23678108plb.13
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 07:22:05 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y188si24144395pfb.59.2018.11.19.07.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 07:22:04 -0800 (PST)
Subject: Patch "printk: Never set console_may_schedule in console_trylock()" has been added to the 4.14-stable tree
From: <gregkh@linuxfoundation.org>
Date: Mon, 19 Nov 2018 16:21:46 +0100
Message-ID: <154264090622177@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, gregkh@linuxfoundation.org, hannes@cmpxchg.org, jack@suse.cz, linux-mm@kvack.org, mathieu.desnoyers@efficios.com, mgorman@suse.de, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@I-love.SAKURA.ne.jp, peterz@infradead.org, pmladek@suse.com, rostedt@goodmis.org, sergey.senozhatsky.work@gmail.com, sergey.senozhatsky@gmail.com, sudipm.mukherjee@gmail.com, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, xiyou.wangcong@gmail.com
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    printk: Never set console_may_schedule in console_trylock()

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     printk-never-set-console_may_schedule-in-console_trylock.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.
