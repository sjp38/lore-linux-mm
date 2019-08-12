Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5BD5C0650F
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 02:53:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 556782070C
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 02:53:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="T90xIibo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 556782070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6CAD6B0006; Sun, 11 Aug 2019 22:53:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1DA86B0008; Sun, 11 Aug 2019 22:53:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0B946B000A; Sun, 11 Aug 2019 22:53:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0229.hostedemail.com [216.40.44.229])
	by kanga.kvack.org (Postfix) with ESMTP id 788376B0006
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 22:53:35 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 16935180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 02:53:35 +0000 (UTC)
X-FDA: 75812255190.03.rub03_3c4fe0405e448
X-HE-Tag: rub03_3c4fe0405e448
X-Filterd-Recvd-Size: 9142
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 02:53:34 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id u17so48744703pgi.6
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 19:53:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=dXAwlxqvWpTq/VMVrnK7FGyu0HZLxIWbkokfBoAnTq4=;
        b=T90xIibomBisJwQABzIUsht/uCJ7Wpu1F5ylnr74+CB2KOjxBvBgqSKfOG58lwS4kZ
         VWgOuWnWiLjdrwpBnOgHVwVZIa+xm85xXLySCEKs02bzt2U/w+p8taibofXiys4BhpCM
         dd7/9Gtve2SgCVJ0DbcRfwe0yHaxvbYbO1kSQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:in-reply-to:references:date
         :message-id:mime-version;
        bh=dXAwlxqvWpTq/VMVrnK7FGyu0HZLxIWbkokfBoAnTq4=;
        b=Q9ucRTVGvAK/d0GthYLtQJR/CyRKXWZ0WnSGyF5t1+hLiWyqDArGmYSCJ9P/95TTQV
         uPEKL5Y+MkCW0EY+H1NgHC89EaYW15caciNJKmJf1j2bMcUCHJBwjBRuYg9QkCew1hEq
         G1bcV03T7S33wJ1bnWzTRKaFwOY/fA4rH9fCGjj7KqNFblEUHm6jM5KIvsMic8ZK+Wei
         s856EPtG8xrgWJAZ2/9GchDey0No30GmF0mxGZOO1qD3MaPLxPUm+DiFRLpRoEYlTd4C
         gmBDpItT8Jd+GRpvSlqAJzvCeASglVePfjsrE2sYMSdFUepi1kG0sc4Q4zhw1XhHDdnj
         JGsQ==
X-Gm-Message-State: APjAAAWcG+tEAlUPi3LeIj2iWg8nrY/QchcLDVh0CvdWhPbRFVfozbRv
	KooaxIR1Nxd6ARHmMl4RV7eC5w==
X-Google-Smtp-Source: APXvYqyVQHMVr62bi42Hx7X6BbSWDgA0eCIeib2P4K39NguiFEmQd88+naDY/ISZNLqYfG0MbjMLGg==
X-Received: by 2002:a62:3543:: with SMTP id c64mr32989322pfa.242.1565578413205;
        Sun, 11 Aug 2019 19:53:33 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id i137sm112983579pgc.4.2019.08.11.19.53.30
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 11 Aug 2019 19:53:32 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: Mark Rutland <mark.rutland@arm.com>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org, linux-kernel@vger.kernel.org, dvyukov@google.com
Subject: Re: [PATCH v3 1/3] kasan: support backing vmalloc space with real shadow memory
In-Reply-To: <20190809095435.GD48423@lakrids.cambridge.arm.com>
References: <20190731071550.31814-1-dja@axtens.net> <20190731071550.31814-2-dja@axtens.net> <20190808135037.GA47131@lakrids.cambridge.arm.com> <20190808174325.GD47131@lakrids.cambridge.arm.com> <20190809095435.GD48423@lakrids.cambridge.arm.com>
Date: Mon, 12 Aug 2019 12:53:25 +1000
Message-ID: <87y2zzf61m.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mark Rutland <mark.rutland@arm.com> writes:

> On Thu, Aug 08, 2019 at 06:43:25PM +0100, Mark Rutland wrote:
>> On Thu, Aug 08, 2019 at 02:50:37PM +0100, Mark Rutland wrote:
>> > Hi Daniel,
>> > 
>> > This is looking really good!
>> > 
>> > I spotted a few more things we need to deal with, so I've suggested some
>> > (not even compile-tested) code for that below. Mostly that's just error
>> > handling, and using helpers to avoid things getting too verbose.
>> 
>> FWIW, I had a quick go at that, and I've pushed the (corrected) results
>> to my git repo, along with an initial stab at arm64 support (which is
>> currently broken):
>> 
>> https://git.kernel.org/pub/scm/linux/kernel/git/mark/linux.git/log/?h=kasan/vmalloc
>
> I've fixed my arm64 patch now, and that appears to work in basic tests
> (example below), so I'll throw my arm64 Syzkaller instance at that today
> to shake out anything major that we've missed or that I've botched.
>
> I'm very excited to see this!
>
> Are you happy to pick up my modified patch 1 for v4?

Thanks, I'll do that.

I'll also have a crack at poisioning on free - I know I did that in an
early draft and then dropped it, so I don't think it was painful at all.

Regards,
Daniel

>
> Thanks,
> Mark.
>
> # echo STACK_GUARD_PAGE_LEADING > DIRECT 
> [  107.453162] lkdtm: Performing direct entry STACK_GUARD_PAGE_LEADING
> [  107.454672] lkdtm: attempting bad read from page below current stack
> [  107.456672] ==================================================================
> [  107.457929] BUG: KASAN: vmalloc-out-of-bounds in lkdtm_STACK_GUARD_PAGE_LEADING+0x88/0xb4
> [  107.459398] Read of size 1 at addr ffff20001515ffff by task sh/214
> [  107.460864] 
> [  107.461271] CPU: 0 PID: 214 Comm: sh Not tainted 5.3.0-rc3-00004-g84f902ca9396-dirty #7
> [  107.463101] Hardware name: linux,dummy-virt (DT)
> [  107.464407] Call trace:
> [  107.464951]  dump_backtrace+0x0/0x1e8
> [  107.465781]  show_stack+0x14/0x20
> [  107.466824]  dump_stack+0xbc/0xf4
> [  107.467780]  print_address_description+0x60/0x33c
> [  107.469221]  __kasan_report+0x140/0x1a0
> [  107.470388]  kasan_report+0xc/0x18
> [  107.471439]  __asan_load1+0x4c/0x58
> [  107.472428]  lkdtm_STACK_GUARD_PAGE_LEADING+0x88/0xb4
> [  107.473908]  lkdtm_do_action+0x40/0x50
> [  107.475255]  direct_entry+0x128/0x1b0
> [  107.476348]  full_proxy_write+0x90/0xc8
> [  107.477595]  __vfs_write+0x54/0xa8
> [  107.478780]  vfs_write+0xd0/0x230
> [  107.479762]  ksys_write+0xc4/0x170
> [  107.480738]  __arm64_sys_write+0x40/0x50
> [  107.481888]  el0_svc_common.constprop.0+0xc0/0x1c0
> [  107.483240]  el0_svc_handler+0x34/0x88
> [  107.484211]  el0_svc+0x8/0xc
> [  107.484996] 
> [  107.485429] 
> [  107.485895] Memory state around the buggy address:
> [  107.487107]  ffff20001515fe80: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
> [  107.489162]  ffff20001515ff00: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
> [  107.491157] >ffff20001515ff80: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
> [  107.493193]                                                                 ^
> [  107.494973]  ffff200015160000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> [  107.497103]  ffff200015160080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> [  107.498795] ==================================================================
> [  107.500495] Disabling lock debugging due to kernel taint
> [  107.503212] Unable to handle kernel paging request at virtual address ffff20001515ffff
> [  107.505177] Mem abort info:
> [  107.505797]   ESR = 0x96000007
> [  107.506554]   Exception class = DABT (current EL), IL = 32 bits
> [  107.508031]   SET = 0, FnV = 0
> [  107.508547]   EA = 0, S1PTW = 0
> [  107.509125] Data abort info:
> [  107.509704]   ISV = 0, ISS = 0x00000007
> [  107.510388]   CM = 0, WnR = 0
> [  107.511089] swapper pgtable: 4k pages, 48-bit VAs, pgdp=0000000041c65000
> [  107.513221] [ffff20001515ffff] pgd=00000000bdfff003, pud=00000000bdffe003, pmd=00000000aa31e003, pte=0000000000000000
> [  107.515915] Internal error: Oops: 96000007 [#1] PREEMPT SMP
> [  107.517295] Modules linked in:
> [  107.518074] CPU: 0 PID: 214 Comm: sh Tainted: G    B             5.3.0-rc3-00004-g84f902ca9396-dirty #7
> [  107.520755] Hardware name: linux,dummy-virt (DT)
> [  107.522208] pstate: 60400005 (nZCv daif +PAN -UAO)
> [  107.523670] pc : lkdtm_STACK_GUARD_PAGE_LEADING+0x88/0xb4
> [  107.525176] lr : lkdtm_STACK_GUARD_PAGE_LEADING+0x88/0xb4
> [  107.526809] sp : ffff200015167b90
> [  107.527856] x29: ffff200015167b90 x28: ffff800002294740 
> [  107.529728] x27: 0000000000000000 x26: 0000000000000000 
> [  107.531523] x25: ffff200015167df0 x24: ffff2000116e8400 
> [  107.533234] x23: ffff200015160000 x22: dfff200000000000 
> [  107.534694] x21: ffff040002a2cf7a x20: ffff2000116e9ee0 
> [  107.536238] x19: 1fffe40002a2cf7a x18: 0000000000000000 
> [  107.537699] x17: 0000000000000000 x16: 0000000000000000 
> [  107.539288] x15: 0000000000000000 x14: 0000000000000000 
> [  107.540584] x13: 0000000000000000 x12: ffff10000d672bb9 
> [  107.541920] x11: 1ffff0000d672bb8 x10: ffff10000d672bb8 
> [  107.543438] x9 : 1ffff0000d672bb8 x8 : dfff200000000000 
> [  107.545008] x7 : ffff10000d672bb9 x6 : ffff80006b395dc0 
> [  107.546570] x5 : 0000000000000001 x4 : dfff200000000000 
> [  107.547936] x3 : ffff20001113274c x2 : 0000000000000007 
> [  107.549121] x1 : eb957a6c7b3ab400 x0 : 0000000000000000 
> [  107.550220] Call trace:
> [  107.551017]  lkdtm_STACK_GUARD_PAGE_LEADING+0x88/0xb4
> [  107.552288]  lkdtm_do_action+0x40/0x50
> [  107.553302]  direct_entry+0x128/0x1b0
> [  107.554290]  full_proxy_write+0x90/0xc8
> [  107.555332]  __vfs_write+0x54/0xa8
> [  107.556278]  vfs_write+0xd0/0x230
> [  107.557000]  ksys_write+0xc4/0x170
> [  107.557834]  __arm64_sys_write+0x40/0x50
> [  107.558980]  el0_svc_common.constprop.0+0xc0/0x1c0
> [  107.560111]  el0_svc_handler+0x34/0x88
> [  107.560936]  el0_svc+0x8/0xc
> [  107.561580] Code: 91140280 97ded9e3 d10006e0 97e4672e (385ff2e1) 
> [  107.563208] ---[ end trace 9e69aa587e1dc0cc ]---

