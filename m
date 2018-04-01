Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA566B0003
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 03:01:15 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u9so5744334qtg.2
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 00:01:15 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 201sor7186919qkh.94.2018.04.01.00.01.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Apr 2018 00:01:14 -0700 (PDT)
MIME-Version: 1.0
From: Hao Lee <haolee.swjtu@gmail.com>
Date: Sun, 1 Apr 2018 15:01:13 +0800
Message-ID: <CA+PpKPnOn9GLSfHUCNPSqLQUs0ySN_oCLDmBA_KG59iEpcS71Q@mail.gmail.com>
Subject: Why the kernel needs `split_mem_range` to split the physical address range?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

I'm currently studying the memory management subsystem. When I read
the code of x86_64 memory mapping initialization, I encounter a
problem and can't find answers on Google.

I wonder why the kernel needs `split_mem_range()`[0] to split physical
address range. To make this question clear, I find an example from
dmesg. The arguments of `split_mem_range` are start=0x00100000,
end=0x80000000. The splitting result is:

[mem 0x00100000-0x001FFFFF] page 4k
[mem 0x00200000-0x7FFFFFFF] page 2M

I don't know why the first 1MiB range is separated out to use 4k page
frame. I think these two ranges can be merged and let the range
[0x00100000-0x7FFFFFFF] use 2M page frame completely. I can't
understand the purpose of this range splitting. Could someone please
explain this function to me? Many Thanks!

[0] https://github.com/torvalds/linux/blob/10b84daddbec72c6b440216a69de9a9605127f7a/arch/x86/mm/init.c#L325

Regards,
Hao Lee
