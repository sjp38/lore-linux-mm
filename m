Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 13BE16B01F1
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 08:38:16 -0400 (EDT)
Received: by pvg11 with SMTP id 11so3653376pvg.14
        for <linux-mm@kvack.org>; Tue, 20 Apr 2010 05:38:15 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 20 Apr 2010 18:08:14 +0530
Message-ID: <y2t448a67a1004200538l45d46338vcd77b63a0e53d54e@mail.gmail.com>
Subject: accessing stack of non-current task
From: Uma shankar <shankar.vk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Is it possible for the kernel to access the user-stack data of a
task different from "current" ? ( This is needed for stack-dump as
well as backtrace. )

I thought the answer is "no". ( Kernel sees memory through the
page-table of "current" )

But I found few places in kernel where this is done. ( eg:
debug_rt_mutex_print_deadlock() in rtmutex-debug.c )

What is the explanation ?

                                        thanks
                                        shankar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
