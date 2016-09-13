Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 89BD36B025E
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 09:41:03 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l64so347765907oif.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 06:41:03 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id b192si14133113oih.274.2016.09.13.06.40.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Sep 2016 06:40:50 -0700 (PDT)
Message-ID: <57D8012F.7080508@huawei.com>
Date: Tue, 13 Sep 2016 21:37:51 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Qustion::  hungtask will come up when ksm enable.
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, kirill.shutemov@linux.intel.com, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

I hit a following problem when run a oom case in ltp.  The kernel version is 4.1 stable.

[  601.937145] Call trace:
[  601.939600] [<ffffffc000086a88>] __switch_to+0x74/0x8c
[  601.944760] [<ffffffc000a1bae0>] __schedule+0x23c/0x7bc
[  601.950007] [<ffffffc000a1c09c>] schedule+0x3c/0x94
[  601.954907] [<ffffffc000a1eb84>] rwsem_down_write_failed+0x214/0x350
[  601.961289] [<ffffffc000a1e32c>] down_write+0x64/0x80
[  601.966363] [<ffffffc00021f794>] __ksm_exit+0x90/0x19c
[  601.971523] [<ffffffc0000be650>] mmput+0x118/0x11c
[  601.976335] [<ffffffc0000c3ec4>] do_exit+0x2dc/0xa74
[  601.981321] [<ffffffc0000c46f8>] do_group_exit+0x4c/0xe4
[  601.986656] [<ffffffc0000d0f34>] get_signal+0x444/0x5e0
[  601.991904] [<ffffffc000089fcc>] do_signal+0x1d8/0x450
[  601.997065] [<ffffffc00008a35c>] do_notify_resume+0x70/0x78

ksm_exit should take the write lock and wait all read lock is released. in fact,  but I find
ksmd still hold a read lock in scan_get_next_rmap_item.  thefefore, it will lead to hungtask.

Any suggestion will be appreciated.

Thanks
zhongjiang



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
