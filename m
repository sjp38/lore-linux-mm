Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A44636B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 01:15:37 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id l68so291326lfb.1
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 22:15:37 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id s20si14970414lfe.167.2016.11.06.22.12.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 06 Nov 2016 22:15:36 -0800 (PST)
From: "Chenjie (K)" <chenjie6@huawei.com>
Subject: arm: why set MIN_GAP to 128M size
Message-ID: <58201A93.70309@huawei.com>
Date: Mon, 7 Nov 2016 14:09:23 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, panxuesong@huawei.com, caojiayin@huawei.com

Hi everyone
     arm:

/* gap between mmap and stack */
#define MIN_GAP (128*1024*1024UL)

The min_gap is 128M,
in the mmap_base function
unsigned long gap = rlimit(RLIMIT_STACK);

     if (gap < MIN_GAP)
         gap = MIN_GAP;
     else if (gap > MAX_GAP)
         gap = MAX_GAP;

I can not use the "128-stack_size"(M)

can i modify it to 64M?


Thanks,
jie chen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
