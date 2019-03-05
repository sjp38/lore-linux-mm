Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84F6BC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 03:09:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25659206B8
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 03:09:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25659206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E8588E0003; Mon,  4 Mar 2019 22:09:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8994E8E0001; Mon,  4 Mar 2019 22:09:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AF888E0003; Mon,  4 Mar 2019 22:09:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4BF8A8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 22:09:45 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id h131so4503445vke.22
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 19:09:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=Evv4LzV+fgVNCBQehdMnvBEKLIrUgGbKKphiK7z5Q74=;
        b=Z+sbV5+paUCDcL2CREOEX8wXmLNQXpY6QryA7nvRSuw7KS4oQ+7EWKrvntepAJQRVa
         3OWzzy0IOMnUfggC/9ix6WnLdjBSIpvIR7iSV56Kpv5g4PwKSDPa5gtIGRuBkGPXP7aI
         Q+dyPp4BL5qrs9ZgZQ1LWsoq7/rsumYIBak5bGtF+KHSIjtalUPClgU7g4tjR+Lv2a2m
         B3mA8MUYrVtZcKIG9OPWkovqNOMor/GXi/vUxY8LgVZrC7X0z+cIRhm5GALUYAnp5OXO
         5UT7ho/NRHMqYU0p6dLP8PcRfInAjcAd9sNtf/2qfaeSieNm/5Qm6aSz0jogo2UCsZJJ
         H4kA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAUuBI8SRYryp5id2S7aeP0pOSNfvaOrEoEjz45LdZp2PTzfQkuJ
	uKXqZYyfulmH+upqpA5yWfEf1WcgQKTxm0/A6rWhFaVXaeq0OcgDJzpc6LSPVF0F5IsMWVh3J73
	5EOuxuP26R0hZU8KNbV1wpSkbMl5RAr9Bb5TBcvKzpMbgEI09DRtmEvBQD9XFXlsifQ==
X-Received: by 2002:a67:7ec7:: with SMTP id z190mr29317vsc.86.1551755384923;
        Mon, 04 Mar 2019 19:09:44 -0800 (PST)
X-Google-Smtp-Source: APXvYqy0lYEzdKg6WGYuy6+6n/O6r4Y2G28KD+9FGltJsz7Pgtyxh9Gn2dX4YuZMAHfIKFZNDzQP
X-Received: by 2002:a67:7ec7:: with SMTP id z190mr29276vsc.86.1551755383768;
        Mon, 04 Mar 2019 19:09:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551755383; cv=none;
        d=google.com; s=arc-20160816;
        b=lnolSubgvtXK1kZicdXB9FRDy9DpICZo2mjLN2iaL8wUjSm5GHaNzeptTufB+wTs1b
         aKkAYQYCFjJBIiLkUwVHjwrEdf1yv/eJTmY2R5JBX24vD4xJ8cb7PcwzKJpi7mkiAuCE
         eePdpU6tCNi+qyQYvP8y/EQYzpIFSCkfJ0zJgRBtRXg3IetdWq/0YMPmDaheSxHOfZWB
         FfnGeB/Ynx+mqxkPNDEn6zmk1ZgVQ5vmkDt4LBfet5LrWVC9AyIrvh3zfUUCvf1O8PLc
         8IqSEWn2DBFOoPHbT66GIfjx0hWVzaZWIOMRyuLi7pG1z3sodOoPbsi66jBWqwLUr5GD
         p3qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=Evv4LzV+fgVNCBQehdMnvBEKLIrUgGbKKphiK7z5Q74=;
        b=NWG1KC5muu7PbbJuMh1sZ1+UHq88rR3Jmb0JjahKuW/TJ8o63j+tLUFEvR8WRjjHaV
         YN1VvmKhUGHB4rd7SNPWoeJapRfzQG9/uC7WZ6ujOj0Cqzimxm+arvejGs2u1+RF0yAB
         QIuN4j83e3CYYWDtFnc9Km/zD4INRBS6Hy4jw3ByEqB3JqnOTFxf2FnEzpd2IUrm+jQF
         OKSGDXo527AY8QOcX0w5vdDTQHliz7/uceNk52N1JdSuaYsYA4bv0pgzIECafMk9v/u1
         LNzKtkoiaFmK4NuZV2dlW0F+G/8Piwd2fI4Ukc2j9OPnI0kcysSAqfXOBm6JMRd+xhxP
         spwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id n132si1558066vkc.65.2019.03.04.19.09.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 19:09:43 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id E6E5A78FC08EBD592D31;
	Tue,  5 Mar 2019 11:09:39 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.408.0; Tue, 5 Mar 2019
 11:09:36 +0800
Message-ID: <5C7DE86F.1000702@huawei.com>
Date: Tue, 5 Mar 2019 11:09:35 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Matthew Wilcox <willy@infradead.org>, Andrea Arcangeli
	<aarcange@redhat.com>
CC: syzbot <syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>,
	<mhocko@kernel.org>, <cgroups@vger.kernel.org>, <hannes@cmpxchg.org>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<syzkaller-bugs@googlegroups.com>, <vdavydov.dev@gmail.com>, David Rientjes
	<rientjes@google.com>, Hugh Dickins <hughd@google.com>, Mel Gorman
	<mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
References: <00000000000006457e057c341ff8@google.com> <5C7BFE94.6070500@huawei.com> <20190304215111.GA13380@bombadil.infradead.org>
In-Reply-To: <20190304215111.GA13380@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/3/5 5:51, Matthew Wilcox wrote:
> On Mon, Mar 04, 2019 at 12:19:32AM +0800, zhong jiang wrote:
>> I also hit the following issue. but it fails to reproduce the issue by the log.
>>
>> it seems to the case that we access the mm->owner and deference it will result in the UAF.
>> But it should not be possible that we specify the incomplete process to be the mm->owner.
> OK, so we've got thread 9325 calling fork() and failing due to the PID
> controller saying "no".  9325 calls free_task(), but somehow thread 9332
> has a reference to the struct task_struct.  There are two possibilities
> here: one is that 9332 really did manage to get a reference to the larval
> child of 9325, and the other is that 9332 has a stale reference to some
> memory which was reallocated to 9325's child.

Good guess and analysis.   IMO,   9332 can not handle the task_struct directly in the code flow.
But It can get a reference of mm_struct.  Maybe I miss something important.

> Andrea, is there any way for a UFFD thread to get access to the child's
> task_struct during the copy_process() call?  If so, I think copy_process()
> needs to call mm_update_next_owner().

Yep,  Hope andrea  have time to  look at this. 

Thanks,
zhong jiang
> If there's no way for that to happen, then we have quite a bug-hunt ahead
> of us looking for who is missing a call to mm_update_next_owner().

>> On 2018/12/4 23:43, syzbot wrote:
>>> syzbot has found a reproducer for the following crash on:
>>>
>>> HEAD commit:    0072a0c14d5b Merge tag 'media/v4.20-4' of git://git.kernel..
>>> git tree:       upstream
>>> console output: https://syzkaller.appspot.com/x/log.txt?x=11c885a3400000
>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=b9cc5a440391cbfd
>>> dashboard link: https://syzkaller.appspot.com/bug?extid=cbb52e396df3e565ab02
>>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12835e25400000
>>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=172fa5a3400000
>>>
>>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>>> Reported-by: syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com
>>>
>>> cgroup: fork rejected by pids controller in /syz2
>>> ==================================================================
>>> BUG: KASAN: use-after-free in __read_once_size include/linux/compiler.h:182 [inline]
>>> BUG: KASAN: use-after-free in task_css include/linux/cgroup.h:477 [inline]
>>> BUG: KASAN: use-after-free in mem_cgroup_from_task mm/memcontrol.c:815 [inline]
>>> BUG: KASAN: use-after-free in get_mem_cgroup_from_mm.part.62+0x6d7/0x880 mm/memcontrol.c:844
>>> Read of size 8 at addr ffff8881b72af310 by task syz-executor198/9332
>>>
>>> CPU: 0 PID: 9332 Comm: syz-executor198 Not tainted 4.20.0-rc5+ #142
>>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
>>> Call Trace:
>>>  __dump_stack lib/dump_stack.c:77 [inline]
>>>  dump_stack+0x244/0x39d lib/dump_stack.c:113
>>>  print_address_description.cold.7+0x9/0x1ff mm/kasan/report.c:256
>>>  kasan_report_error mm/kasan/report.c:354 [inline]
>>>  kasan_report.cold.8+0x242/0x309 mm/kasan/report.c:412
>>>  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
>>>  __read_once_size include/linux/compiler.h:182 [inline]
>>>  task_css include/linux/cgroup.h:477 [inline]
>>>  mem_cgroup_from_task mm/memcontrol.c:815 [inline]
>>>  get_mem_cgroup_from_mm.part.62+0x6d7/0x880 mm/memcontrol.c:844
>>>  get_mem_cgroup_from_mm mm/memcontrol.c:834 [inline]
>>>  mem_cgroup_try_charge+0x608/0xe20 mm/memcontrol.c:5888
>>>  mcopy_atomic_pte mm/userfaultfd.c:71 [inline]
>>>  mfill_atomic_pte mm/userfaultfd.c:418 [inline]
>>>  __mcopy_atomic mm/userfaultfd.c:559 [inline]
>>>  mcopy_atomic+0xb08/0x2c70 mm/userfaultfd.c:609
>>>  userfaultfd_copy fs/userfaultfd.c:1705 [inline]
>>>  userfaultfd_ioctl+0x29fb/0x5610 fs/userfaultfd.c:1851
>>>  vfs_ioctl fs/ioctl.c:46 [inline]
>>>  file_ioctl fs/ioctl.c:509 [inline]
>>>  do_vfs_ioctl+0x1de/0x1790 fs/ioctl.c:696
>>>  ksys_ioctl+0xa9/0xd0 fs/ioctl.c:713
>>>  __do_sys_ioctl fs/ioctl.c:720 [inline]
>>>  __se_sys_ioctl fs/ioctl.c:718 [inline]
>>>  __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:718
>>>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>>>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>> RIP: 0033:0x44c7e9
>>> Code: 5d c5 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 2b c5 fb ff c3 66 2e 0f 1f 84 00 00 00 00
>>> RSP: 002b:00007f906b69fdb8 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
>>> RAX: ffffffffffffffda RBX: 00000000006e4a08 RCX: 000000000044c7e9
>>> RDX: 0000000020000100 RSI: 00000000c028aa03 RDI: 0000000000000004
>>> RBP: 00000000006e4a00 R08: 0000000000000000 R09: 0000000000000000
>>> R10: 0000000000000000 R11: 0000000000000246 R12: 00000000006e4a0c
>>> R13: 00007ffdfd47813f R14: 00007f906b6a09c0 R15: 000000000000002d
>>>
>>> Allocated by task 9325:
>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
>>>  set_track mm/kasan/kasan.c:460 [inline]
>>>  kasan_kmalloc+0xc7/0xe0 mm/kasan/kasan.c:553
>>>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:490
>>>  kmem_cache_alloc_node+0x144/0x730 mm/slab.c:3644
>>>  alloc_task_struct_node kernel/fork.c:158 [inline]
>>>  dup_task_struct kernel/fork.c:843 [inline]
>>>  copy_process+0x2026/0x87a0 kernel/fork.c:1751
>>>  _do_fork+0x1cb/0x11d0 kernel/fork.c:2216
>>>  __do_sys_clone kernel/fork.c:2323 [inline]
>>>  __se_sys_clone kernel/fork.c:2317 [inline]
>>>  __x64_sys_clone+0xbf/0x150 kernel/fork.c:2317
>>>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>>>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>>
>>> Freed by task 9325:
>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
>>>  set_track mm/kasan/kasan.c:460 [inline]
>>>  __kasan_slab_free+0x102/0x150 mm/kasan/kasan.c:521
>>>  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
>>>  __cache_free mm/slab.c:3498 [inline]
>>>  kmem_cache_free+0x83/0x290 mm/slab.c:3760
>>>  free_task_struct kernel/fork.c:163 [inline]
>>>  free_task+0x16e/0x1f0 kernel/fork.c:457
>>>  copy_process+0x1dcc/0x87a0 kernel/fork.c:2148
>>>  _do_fork+0x1cb/0x11d0 kernel/fork.c:2216
>>>  __do_sys_clone kernel/fork.c:2323 [inline]
>>>  __se_sys_clone kernel/fork.c:2317 [inline]
>>>  __x64_sys_clone+0xbf/0x150 kernel/fork.c:2317
>>>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>>>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>>
>>> The buggy address belongs to the object at ffff8881b72ae240
>>>  which belongs to the cache task_struct(81:syz2) of size 6080
>>> The buggy address is located 4304 bytes inside of
>>>  6080-byte region [ffff8881b72ae240, ffff8881b72afa00)
>>> The buggy address belongs to the page:
>>> page:ffffea0006dcab80 count:1 mapcount:0 mapping:ffff8881d2dce0c0 index:0x0 compound_mapcount: 0
>>> flags: 0x2fffc0000010200(slab|head)
>>> raw: 02fffc0000010200 ffffea00074a1f88 ffffea0006ebbb88 ffff8881d2dce0c0
>>> raw: 0000000000000000 ffff8881b72ae240 0000000100000001 ffff8881d87fe580
>>> page dumped because: kasan: bad access detected
>>> page->mem_cgroup:ffff8881d87fe580
>>>
>>> Memory state around the buggy address:
>>>  ffff8881b72af200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>  ffff8881b72af280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>> ffff8881b72af300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>                          ^
>>>  ffff8881b72af380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>  ffff8881b72af400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>> ==================================================================
>>>
>>>
>>> .
>>>
>>
> .
>


