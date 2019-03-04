Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A13DC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 15:32:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4DD920657
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 15:32:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4DD920657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32CCB8E0003; Mon,  4 Mar 2019 10:32:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DD378E0001; Mon,  4 Mar 2019 10:32:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A4E68E0003; Mon,  4 Mar 2019 10:32:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDBC18E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 10:32:28 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id l198so3278936oib.1
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 07:32:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=lt2x03QLRnCsdNwuu0e5r1TMxTP0BVQ+wIUxU3vNIQg=;
        b=HBbpC6z5sd+q/rhx+nP5uRNx4tXBwBO0WOb1PfGg3845mYPnjdB6Fay3arqj6v874e
         zLigpNebpRmiy7No1Ezg0PQkAgmQ0XRM+4+NXV+rzZLykQ0yfl57CUy034u3D3sJ7ZCA
         PBeYpqCLwrHh8rxzbRmmygd4JU/8MmQS5LVYliGtjMPCDG/T3e8mIcgM+iJdG/E2RYEj
         ALDuCVcnBYPDzrva8sZq7hQglSiJKP4SvJlcaI6GH4KNKeDrwESVRedqFkxrKYOnkU9F
         0/gHrEtqqSqlvAnpAfBEncpMMCNVX/PdkBwdfoYVhxybNtYHWAzoBTw71XpHNLZbuWGM
         OvrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAVVSDwz6Yuo4t2FAUqRWEChnE9TOgyNql2YmAP9tF7a5Pu0pFk1
	X5IY7EH5SBz/nrWVKCTXCTg6Gu3iSiffSi+2eeDHAtHwS4xHTYhbWdQAHv0L92mOk1skAfl4Uk9
	AtFI/35drgOqk3Ny+f/VtFy5oMIFm5qxTEAy8Ll+w6TnoTGW9HUY68RGtYlo6cvBezA==
X-Received: by 2002:a05:6830:20da:: with SMTP id z26mr13351523otq.204.1551713548568;
        Mon, 04 Mar 2019 07:32:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqwt2TaI6vjC4GqHMF8l7RhGUl9yvVoAdDY3LCstqhDAuSsbsYKGmQRagZPwRD7Cu7K7eSD9
X-Received: by 2002:a05:6830:20da:: with SMTP id z26mr13351453otq.204.1551713546987;
        Mon, 04 Mar 2019 07:32:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551713546; cv=none;
        d=google.com; s=arc-20160816;
        b=KTzwhL+Ob89hdn+3/qN1sEqiNSfbe2tKWeo1HNfQ2SEDfNZh5mz++cJXKivuxh+MYR
         OYSR5WNJvPRQwMH+jKjKmyKZPUihFp0Mz4IYoPyjtxJnR9s3hcL9vQbyZKLQuR+DHA6X
         w1EybeQpkGaFuFaC95L7MRzC1i8EZURndx48jgpDoPXCSKaq93Is0bgSK0hYs3Ja9Gme
         BFQK7aXS0KifdWFIVUnCiZqANyQCf/FWr6o+dbiCAtjNjg08AnxYuG2UJK0iyoTBJL2j
         J6tzRW8xanXcuEYVCkyke+RE8h5CJE8D5Tz4xgC1MFq/7n+n525nEAXR9G5aAmn2TfxO
         6mGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=lt2x03QLRnCsdNwuu0e5r1TMxTP0BVQ+wIUxU3vNIQg=;
        b=TT450X7gOpTTePwaClbaqJeWlzssuWufXPXcHJEYO0ghM5okAZYIsprXZRmM4VF41B
         Plh79HnBpEFzG7YBjSAHz8cPYKVCLu5yd6rcbUnV2CjZd7wEvi7NVc+F5xDAz9FG4KA1
         X7JICKhdHdF1PFwiDMrDx3aC4Bn/R9Q26UgLfss4jsdrnLp++4T6zIHprzxK7SweCPW5
         0HCITxG1uD7xCr684nzcGxfinYZgvM7HdlWfY5NmjhztBdTizBaeJGsoMHhp7JnfEFfY
         lf+oGRnZRw/8mpKUbi03JbbN0j8UDcYF8wTjnnt19sJbpotZtRxMWd5xYTFzStBslkrP
         KWQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id z13si2584330otq.277.2019.03.04.07.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 07:32:26 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 811FF416B9CF8CAC933F;
	Mon,  4 Mar 2019 23:32:21 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.408.0; Mon, 4 Mar 2019
 23:32:18 +0800
Message-ID: <5C7D4500.3070607@huawei.com>
Date: Mon, 4 Mar 2019 23:32:16 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Dmitry Vyukov <dvyukov@google.com>
CC: syzbot <syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>, "Michal
 Hocko" <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>,
	<cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML
	<linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs
	<syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>,
	David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>,
	Matthew Wilcox <willy@infradead.org>, Mel Gorman <mgorman@suse.de>,
	"Vlastimil Babka" <vbabka@suse.cz>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
References: <00000000000006457e057c341ff8@google.com> <5C7BFE94.6070500@huawei.com> <CACT4Y+Z+CH0UTdSz-w_woMPrBwg-GuobV1Su4qd9ReffTkyfVg@mail.gmail.com> <5C7D2F82.40907@huawei.com> <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com>
In-Reply-To: <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/3/4 22:11, Dmitry Vyukov wrote:
> On Mon, Mar 4, 2019 at 3:00 PM zhong jiang <zhongjiang@huawei.com> wrote:
>> On 2019/3/4 15:40, Dmitry Vyukov wrote:
>>> On Sun, Mar 3, 2019 at 5:19 PM zhong jiang <zhongjiang@huawei.com> wrote:
>>>> Hi, guys
>>>>
>>>> I also hit the following issue. but it fails to reproduce the issue by the log.
>>>>
>>>> it seems to the case that we access the mm->owner and deference it will result in the UAF.
>>>> But it should not be possible that we specify the incomplete process to be the mm->owner.
>>>>
>>>> Any thoughts?
>>> FWIW syzbot was able to reproduce this with this reproducer.
>>> This looks like a very subtle race (threaded reproducer that runs
>>> repeatedly in multiple processes), so most likely we are looking for
>>> something like few instructions inconsistency window.
>>>
>> I has a little doubtful about the instrustions inconsistency window.
>>
>> I guess that you mean some smb barriers should be taken into account.:-)
>>
>> Because IMO, It should not be the lock case to result in the issue.
>
> Since the crash was triggered on x86 _most likley_ this is not a
> missed barrier. What I meant is that one thread needs to executed some
> code, while another thread is stopped within few instructions.
>
>
It is weird and I can not find any relationship you had said with the issue.:-(

Because It is the cause that mm->owner has been freed, whereas we still deference it.

From the lastest freed task call trace, It fails to create process.

Am I miss something or I misunderstand your meaning. Please correct me.

Thanks,
zhong jiang
>> Thanks,
>> zhong jinag
>>>> Thanks,
>>>> zhong jiang
>>>>
>>>> On 2018/12/4 23:43, syzbot wrote:
>>>>> syzbot has found a reproducer for the following crash on:
>>>>>
>>>>> HEAD commit:    0072a0c14d5b Merge tag 'media/v4.20-4' of git://git.kernel..
>>>>> git tree:       upstream
>>>>> console output: https://syzkaller.appspot.com/x/log.txt?x=11c885a3400000
>>>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=b9cc5a440391cbfd
>>>>> dashboard link: https://syzkaller.appspot.com/bug?extid=cbb52e396df3e565ab02
>>>>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>>>>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12835e25400000
>>>>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=172fa5a3400000
>>>>>
>>>>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>>>>> Reported-by: syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com
>>>>>
>>>>> cgroup: fork rejected by pids controller in /syz2
>>>>> ==================================================================
>>>>> BUG: KASAN: use-after-free in __read_once_size include/linux/compiler.h:182 [inline]
>>>>> BUG: KASAN: use-after-free in task_css include/linux/cgroup.h:477 [inline]
>>>>> BUG: KASAN: use-after-free in mem_cgroup_from_task mm/memcontrol.c:815 [inline]
>>>>> BUG: KASAN: use-after-free in get_mem_cgroup_from_mm.part.62+0x6d7/0x880 mm/memcontrol.c:844
>>>>> Read of size 8 at addr ffff8881b72af310 by task syz-executor198/9332
>>>>>
>>>>> CPU: 0 PID: 9332 Comm: syz-executor198 Not tainted 4.20.0-rc5+ #142
>>>>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
>>>>> Call Trace:
>>>>>  __dump_stack lib/dump_stack.c:77 [inline]
>>>>>  dump_stack+0x244/0x39d lib/dump_stack.c:113
>>>>>  print_address_description.cold.7+0x9/0x1ff mm/kasan/report.c:256
>>>>>  kasan_report_error mm/kasan/report.c:354 [inline]
>>>>>  kasan_report.cold.8+0x242/0x309 mm/kasan/report.c:412
>>>>>  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:433
>>>>>  __read_once_size include/linux/compiler.h:182 [inline]
>>>>>  task_css include/linux/cgroup.h:477 [inline]
>>>>>  mem_cgroup_from_task mm/memcontrol.c:815 [inline]
>>>>>  get_mem_cgroup_from_mm.part.62+0x6d7/0x880 mm/memcontrol.c:844
>>>>>  get_mem_cgroup_from_mm mm/memcontrol.c:834 [inline]
>>>>>  mem_cgroup_try_charge+0x608/0xe20 mm/memcontrol.c:5888
>>>>>  mcopy_atomic_pte mm/userfaultfd.c:71 [inline]
>>>>>  mfill_atomic_pte mm/userfaultfd.c:418 [inline]
>>>>>  __mcopy_atomic mm/userfaultfd.c:559 [inline]
>>>>>  mcopy_atomic+0xb08/0x2c70 mm/userfaultfd.c:609
>>>>>  userfaultfd_copy fs/userfaultfd.c:1705 [inline]
>>>>>  userfaultfd_ioctl+0x29fb/0x5610 fs/userfaultfd.c:1851
>>>>>  vfs_ioctl fs/ioctl.c:46 [inline]
>>>>>  file_ioctl fs/ioctl.c:509 [inline]
>>>>>  do_vfs_ioctl+0x1de/0x1790 fs/ioctl.c:696
>>>>>  ksys_ioctl+0xa9/0xd0 fs/ioctl.c:713
>>>>>  __do_sys_ioctl fs/ioctl.c:720 [inline]
>>>>>  __se_sys_ioctl fs/ioctl.c:718 [inline]
>>>>>  __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:718
>>>>>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>>>>>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>>>> RIP: 0033:0x44c7e9
>>>>> Code: 5d c5 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 2b c5 fb ff c3 66 2e 0f 1f 84 00 00 00 00
>>>>> RSP: 002b:00007f906b69fdb8 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
>>>>> RAX: ffffffffffffffda RBX: 00000000006e4a08 RCX: 000000000044c7e9
>>>>> RDX: 0000000020000100 RSI: 00000000c028aa03 RDI: 0000000000000004
>>>>> RBP: 00000000006e4a00 R08: 0000000000000000 R09: 0000000000000000
>>>>> R10: 0000000000000000 R11: 0000000000000246 R12: 00000000006e4a0c
>>>>> R13: 00007ffdfd47813f R14: 00007f906b6a09c0 R15: 000000000000002d
>>>>>
>>>>> Allocated by task 9325:
>>>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
>>>>>  set_track mm/kasan/kasan.c:460 [inline]
>>>>>  kasan_kmalloc+0xc7/0xe0 mm/kasan/kasan.c:553
>>>>>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:490
>>>>>  kmem_cache_alloc_node+0x144/0x730 mm/slab.c:3644
>>>>>  alloc_task_struct_node kernel/fork.c:158 [inline]
>>>>>  dup_task_struct kernel/fork.c:843 [inline]
>>>>>  copy_process+0x2026/0x87a0 kernel/fork.c:1751
>>>>>  _do_fork+0x1cb/0x11d0 kernel/fork.c:2216
>>>>>  __do_sys_clone kernel/fork.c:2323 [inline]
>>>>>  __se_sys_clone kernel/fork.c:2317 [inline]
>>>>>  __x64_sys_clone+0xbf/0x150 kernel/fork.c:2317
>>>>>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>>>>>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>>>>
>>>>> Freed by task 9325:
>>>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:448
>>>>>  set_track mm/kasan/kasan.c:460 [inline]
>>>>>  __kasan_slab_free+0x102/0x150 mm/kasan/kasan.c:521
>>>>>  kasan_slab_free+0xe/0x10 mm/kasan/kasan.c:528
>>>>>  __cache_free mm/slab.c:3498 [inline]
>>>>>  kmem_cache_free+0x83/0x290 mm/slab.c:3760
>>>>>  free_task_struct kernel/fork.c:163 [inline]
>>>>>  free_task+0x16e/0x1f0 kernel/fork.c:457
>>>>>  copy_process+0x1dcc/0x87a0 kernel/fork.c:2148
>>>>>  _do_fork+0x1cb/0x11d0 kernel/fork.c:2216
>>>>>  __do_sys_clone kernel/fork.c:2323 [inline]
>>>>>  __se_sys_clone kernel/fork.c:2317 [inline]
>>>>>  __x64_sys_clone+0xbf/0x150 kernel/fork.c:2317
>>>>>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>>>>>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>>>>
>>>>> The buggy address belongs to the object at ffff8881b72ae240
>>>>>  which belongs to the cache task_struct(81:syz2) of size 6080
>>>>> The buggy address is located 4304 bytes inside of
>>>>>  6080-byte region [ffff8881b72ae240, ffff8881b72afa00)
>>>>> The buggy address belongs to the page:
>>>>> page:ffffea0006dcab80 count:1 mapcount:0 mapping:ffff8881d2dce0c0 index:0x0 compound_mapcount: 0
>>>>> flags: 0x2fffc0000010200(slab|head)
>>>>> raw: 02fffc0000010200 ffffea00074a1f88 ffffea0006ebbb88 ffff8881d2dce0c0
>>>>> raw: 0000000000000000 ffff8881b72ae240 0000000100000001 ffff8881d87fe580
>>>>> page dumped because: kasan: bad access detected
>>>>> page->mem_cgroup:ffff8881d87fe580
>>>>>
>>>>> Memory state around the buggy address:
>>>>>  ffff8881b72af200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>>>  ffff8881b72af280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>>>> ffff8881b72af300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>>>                          ^
>>>>>  ffff8881b72af380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>>>  ffff8881b72af400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>>> ==================================================================
>>>>>
>>>>>
>>>>> .
>>>>>
>>>> --
>>>> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
>>>> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
>>>> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/5C7BFE94.6070500%40huawei.com.
>>>> For more options, visit https://groups.google.com/d/optout.
>>> .
>>>
>>
> .
>


