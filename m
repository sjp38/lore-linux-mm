Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 833FCC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 17:52:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37306218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 17:52:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="d05fEMoY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37306218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7AE58E0003; Thu, 28 Feb 2019 12:52:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2B108E0001; Thu, 28 Feb 2019 12:52:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF18B8E0003; Thu, 28 Feb 2019 12:52:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 864CE8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 12:52:00 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id w19so16180627ioa.15
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 09:52:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=aa26oVu8kuIQCaX8+pX/2EveeW8QvMZROPUy5YCCHWw=;
        b=JYIKubIFqhkmj0y59CJqqAIIaQFe4+dal4+ZkvMRUQa9qweY0josqDCa3779JZfirv
         w/Ot881J2kZhHSOr1Uh7rk5SNv7gstCcI7Ww1rgjcalFkDDe5ac4xENzxptVUmDwfWUm
         7FRdXFbdj9hfvQUuYTLGRPlveAJQCblArmGPxF8J/uDx5nBIem6c629vy6m4sgvOa7t6
         mD6ZYLJp7t7FyRItX19DX/ykAlIZ2ouvzuaJ5yWFTnNQhY+XC9i2T4JYZrX7MKN4T9Wj
         3PzJ/4nrt+aXHUenHjVYPQJj1gLfR7ZzlB2BkoZMnozJ3kgsPnShPq074BG10V7w5s0q
         UnYg==
X-Gm-Message-State: AHQUAuaaSyXXdnNUXCtqV96q0SKxk9/AY/GbI+eudh7slC+GtH/ojKx5
	i5iNUcY18iyHpzrUiqEg8cYsiKUC1pPICJLaf4vNhgut4i/4MVRR0VnGM01JZ3FPDsfEdbxSxEp
	dH+73UYl5NRYewGvH6eIyT41HfL1zIk2/0rxevavFvryHhywWQm4FMImlIVTSyMn/fzb6+M778D
	stpGcolXbOS9Md1hkgUGyYRDh50baZKqQtbk2Mlh0Lb/4vuAoumXAMeIbpp9onwYOGgkx/80aQf
	7z0TMLdrWwXm9nyPDwcEM6FturM4mfKUhbpk1LtoAOoJNTghP1olG8eti/uHD59sUy5m8CAweiy
	8Gf/vNvklZLWgWtWa2m3p4vDfJq17JU2zoYQchM/ektlagW6PBORmFKuly+lRfCjw0hMztRBEtu
	7
X-Received: by 2002:a24:5e05:: with SMTP id h5mr669248itb.103.1551376320235;
        Thu, 28 Feb 2019 09:52:00 -0800 (PST)
X-Received: by 2002:a24:5e05:: with SMTP id h5mr669183itb.103.1551376319160;
        Thu, 28 Feb 2019 09:51:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551376319; cv=none;
        d=google.com; s=arc-20160816;
        b=e2eRaUowE7QEqJF947jdA0D9YAczTWn39kIuwQsgJrwzCsYTF14GmrU2Qj9KWMaHOt
         uTDTTgQpM0Nm1mKtoXCLhqS9vlGOgkk7r0gun9JDgK+OxbHdDt3Ib5a1HJzc2V9+VR+I
         evfo4BEzSnIYuURS39VEgwgryfi2N3tU4MgK6e0iaKL9vWabeyAtR1RuKfhuMx71lpux
         bWN1q+DWkU3smJA1OwxnsWPIknX+wOoCwZDE72U4AQ+DmjnyARiF60EU2Q0TL8I3M3Bk
         BSn4kTfXj7InQ5S2/rsuWC6gcD259A2BrYpAE/zg7ltV5H3BTsBk/FnkTkp/W8/ebR4m
         lIOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=aa26oVu8kuIQCaX8+pX/2EveeW8QvMZROPUy5YCCHWw=;
        b=g0MlGvYeRtGodbsHmypBOJt3rm/TYmIkNcbH40m3kM9E8xrjM2W536zhc31pRxB1e+
         O/JXAeRuR1fK63yEA7Rz/XK2L02IbOIMUYju/xb25/740CqW7yJpX3ZRWldy87y2cP0e
         OPwM5Twbn/z8fNUlviP/MT+PqRroQ4ELXa/MdCsp4RoJaG9rOQGpfP6yxBwn5FBeTEVo
         FNdiuCChBr9EyVVqmd5PSHQF8CJdDWKQuGTJPF6NM/hjM/NJNjivVwBA3zqlcJAWC7Rs
         j6mwxh1hKL8SfhqEXA3Rx5Zu2KxF+ETB/O7Kh8scLfb88UKz5/SowFdIHPozrF3k6xQv
         Foqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=d05fEMoY;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 184sor10456239itk.6.2019.02.28.09.51.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 09:51:59 -0800 (PST)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=d05fEMoY;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=aa26oVu8kuIQCaX8+pX/2EveeW8QvMZROPUy5YCCHWw=;
        b=d05fEMoYD5fhgV82rozFD/qwjA0kUuMveP/ZYg6BikmB9JfGt69RNy0grHmy4YMAPu
         G966C1iYtoL9SrrPYiy+OrCT4mBvyeCsQ/hvFnC9lqMr7ibaNu6OMsp5mpN7QNAb44ik
         Lh0Lwke2/c0wfYBMqmZBPYbLYkQd8krv8el3MHxoRk/Wqejxsi9YpYWbUIA1Zrrz7iY8
         3/+yToKJ/k+JkqgRZfnqAGxXhyiHcRGC0d4qoTWXbyvFcEhXj8GTYGRV2QpwTqDUAJee
         zvUopETzlsP1/yiL+MR6TQHug7D1JJb3JQdHrhMoPg4B9jKgumpwXbcL92hywEnJShcy
         5s3g==
X-Google-Smtp-Source: APXvYqw3Gb/vOPCL1TGmLJEiHqcxjOdRAq1C1VmjCkWtGf47bWHytoZvqOSnm0xivMnB6x9shEofOA==
X-Received: by 2002:a24:7a48:: with SMTP id a69mr689060itc.142.1551376318776;
        Thu, 28 Feb 2019 09:51:58 -0800 (PST)
Received: from [192.168.1.158] ([216.160.245.98])
        by smtp.gmail.com with ESMTPSA id o141sm3065221ito.14.2019.02.28.09.51.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 09:51:57 -0800 (PST)
Subject: Re: BUG: Bad page state (6)
To: Eric Biggers <ebiggers@kernel.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com>,
 Andrew Morton <akpm@linux-foundation.org>, arunks@codeaurora.org,
 Dan Williams <dan.j.williams@intel.com>, Lance Roy <ldr709@gmail.com>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 Michal Hocko <mhocko@suse.com>, nborisov@suse.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
 Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>,
 yuehaibing@huawei.com
References: <00000000000024b3aa0582f1cde7@google.com>
 <CACT4Y+byrcaasUaEJj=hcemEEBBkon=VC24gPwGXHzfeRP0E3w@mail.gmail.com>
 <20190228174250.GB663@sol.localdomain>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <54e34bcb-7de7-4488-cead-3ea3a2b71ed7@kernel.dk>
Date: Thu, 28 Feb 2019 10:51:56 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190228174250.GB663@sol.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 10:42 AM, Eric Biggers wrote:
> On Thu, Feb 28, 2019 at 11:36:21AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
>> On Thu, Feb 28, 2019 at 11:32 AM syzbot
>> <syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com> wrote:
>>>
>>> Hello,
>>>
>>> syzbot found the following crash on:
>>>
>>> HEAD commit:    42fd8df9d1d9 Add linux-next specific files for 20190228
>>> git tree:       linux-next
>>> console output: https://syzkaller.appspot.com/x/log.txt?x=179ba9e0c00000
>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=c0f38652d28b522f
>>> dashboard link: https://syzkaller.appspot.com/bug?extid=6f5a9b79b75b66078bf0
>>> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
>>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12ed6bd0c00000
>>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10690c8ac00000
>>>
>>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>>> Reported-by: syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com
>>
>> +Jens, Eric,
>>
>> Looks similar to:
>> https://groups.google.com/forum/#!msg/syzkaller-bugs/E3v3XQweVBw/6BPrkIYJIgAJ
>> Perhaps the fixing commit is not in the build yet?
>>
>>
>>> BUG: Bad page state in process syz-executor193  pfn:9225a
>>> page:ffffea0002489680 count:0 mapcount:0 mapping:ffff88808652fd80 index:0x81
>>> shmem_aops
>>> name:"memfd:cgroup2"
>>> flags: 0x1fffc000008000e(referenced|uptodate|dirty|swapbacked)
>>> raw: 01fffc000008000e ffff88809277fac0 ffff88809277fac0 ffff88808652fd80
>>> raw: 0000000000000081 0000000000000000 00000000ffffffff 0000000000000000
>>> page dumped because: non-NULL mapping
>>> Modules linked in:
>>> CPU: 0 PID: 7659 Comm: syz-executor193 Not tainted 5.0.0-rc8-next-20190228
>>> #45
>>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
>>> Google 01/01/2011
>>> Call Trace:
>>>   __dump_stack lib/dump_stack.c:77 [inline]
>>>   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
>>>   bad_page.cold+0xda/0xff mm/page_alloc.c:586
>>>   free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1013
>>>   free_pages_check mm/page_alloc.c:1022 [inline]
>>>   free_pages_prepare mm/page_alloc.c:1112 [inline]
>>>   free_pcp_prepare mm/page_alloc.c:1137 [inline]
>>>   free_unref_page_prepare mm/page_alloc.c:3001 [inline]
>>>   free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3070
>>>   release_pages+0x60d/0x1940 mm/swap.c:794
>>>   pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
>>>   activate_page_drain mm/swap.c:297 [inline]
>>>   lru_add_drain_cpu+0x3b1/0x520 mm/swap.c:596
>>>   lru_add_drain+0x20/0x60 mm/swap.c:647
>>>   exit_mmap+0x290/0x530 mm/mmap.c:3134
>>>   __mmput kernel/fork.c:1047 [inline]
>>>   mmput+0x15f/0x4c0 kernel/fork.c:1068
>>>   exit_mm kernel/exit.c:546 [inline]
>>>   do_exit+0x816/0x2fa0 kernel/exit.c:863
>>>   do_group_exit+0x135/0x370 kernel/exit.c:980
>>>   __do_sys_exit_group kernel/exit.c:991 [inline]
>>>   __se_sys_exit_group kernel/exit.c:989 [inline]
>>>   __x64_sys_exit_group+0x44/0x50 kernel/exit.c:989
>>>   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
>>>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>> RIP: 0033:0x442a58
>>> Code: 00 00 be 3c 00 00 00 eb 19 66 0f 1f 84 00 00 00 00 00 48 89 d7 89 f0
>>> 0f 05 48 3d 00 f0 ff ff 77 21 f4 48 89 d7 44 89 c0 0f 05 <48> 3d 00 f0 ff
>>> ff 76 e0 f7 d8 64 41 89 01 eb d8 0f 1f 84 00 00 00
>>> RSP: 002b:00007ffe99e2faf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
>>> RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000442a58
>>> RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
>>> RBP: 00000000004c2468 R08: 00000000000000e7 R09: ffffffffffffffd0
>>> R10: 0000000002000005 R11: 0000000000000246 R12: 0000000000000001
>>> R13: 00000000006d4180 R14: 0000000000000000 R15: 0000000000000000
>>>
>>>
>>> ---
>>> This bug is generated by a bot. It may contain errors.
>>> See https://goo.gl/tpsmEJ for more information about syzbot.
>>> syzbot engineers can be reached at syzkaller@googlegroups.com.
>>>
>>> syzbot will keep track of this bug report. See:
>>> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
>>> syzbot.
>>> syzbot can test patches for this bug, for details see:
>>> https://goo.gl/tpsmEJ#testing-patches
>>>
>>> --
>>> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
>>> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
>>> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/00000000000024b3aa0582f1cde7%40google.com.
>>> For more options, visit https://groups.google.com/d/optout.
>>
>> -- 
>> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
>> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
>> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/CACT4Y%2BbyrcaasUaEJj%3DhcemEEBBkon%3DVC24gPwGXHzfeRP0E3w%40mail.gmail.com.
>> For more options, visit https://groups.google.com/d/optout.
> 
> It bisects down to the same patch ("block: implement bio helper to add iter bvec
> pages to bio") so apparently it's just still broken despite Jens' fix.
> 
> BTW, as this is trivially bisectable with the reproducer, I still don't see why
> syzbot can't do the bisection itself and use get_maintainer.pl on the broken
> patch to actually send the report to the right person:
> 
> $ ./scripts/get_maintainer.pl 0001-block-implement-bio-helper-to-add-iter-bvec-pages-to.patch 
> Jens Axboe <axboe@kernel.dk> (maintainer:BLOCK LAYER)
> linux-block@vger.kernel.org (open list:BLOCK LAYER)
> linux-kernel@vger.kernel.org (open list)
> 
> Spamming unrelated lists and maintainers not only prevents the bug from being
> fixed, but it also reduces the average usefulness of syzbot reports which
> teaches people to ignore them.

Huh, weird. Where's the reproducer for this one?

-- 
Jens Axboe

