Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D690C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:54:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1B8E2171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:54:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1B8E2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 722D86B000C; Fri,  9 Aug 2019 05:54:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D2666B000D; Fri,  9 Aug 2019 05:54:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59AE66B000E; Fri,  9 Aug 2019 05:54:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0D41A6B000C
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:54:42 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z2so1005128ede.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:54:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GwruKyw7mHs3C54oT/QuJsxh7Ksfp9svOQkHJNfLpNk=;
        b=fv4EXROP8nLuDsftP+y1werVWLsY9jNiWv3ooxBYIPT8JNrcweFeRK09A7VkDE1kqR
         B29kkmN3a6IQyFL8X0dqzff4LC7s8i8ArteK9exr0CekD6ycSocbO7jvBrAJC0IdNRBm
         ZF8qMi+eFFlDN9/KCqGfzduT1UdkZcuu0Eccjrup6QenzHUxTQYA1e/O5hCN5VeTCEd2
         dzD2UO3iytDOIZ9C4YcNLtyBfsZ7fV4Eg5ji+fd0JFV+zDgBr1Kkbm68ADKUviJ99DuF
         rmcwqo8hps9T+jf4wo+mCHzVMbsQ+LVRu4AQswfayiMIvxvH9BbLw/P820XJXTkJ7Y5x
         H7hA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAVeiVGNzA90l+2Z8YP2/DRe0tdSbIL0onBSFM/HIhSgQll6t0u1
	LmjFZ5h3XUZY6b3X3fK5Y7MzZI5EgKKtIz45ohPYYR567obiWE7d1qAYIlyILoBtFOlhhlC64zd
	xueIEwzEdWY1eK0El7g27+xptkVGKWlsvgbVJlS0YJsNPsulOtPsPo9y2+NMTZQs/kA==
X-Received: by 2002:a50:addc:: with SMTP id b28mr20945656edd.174.1565344481601;
        Fri, 09 Aug 2019 02:54:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpraLNUTPhINBMjvLdo2WTXCUuazdWWVY3P6q/TJTS4/3hVdzdbwpTj9An/4/Z3ta6DYiF
X-Received: by 2002:a50:addc:: with SMTP id b28mr20945584edd.174.1565344480289;
        Fri, 09 Aug 2019 02:54:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565344480; cv=none;
        d=google.com; s=arc-20160816;
        b=DHeVUMumbmGd2JWb0RlJVvS4C1r0zGxDPX5MN2D+SvSMknwEOJlINRtKkJBcCay2G4
         0N2qe63b/EFJHBq7C0nlvdMgKtu01yEak2co6UQad8I4943VooRIUfheaMBA94oaNgOd
         QbXJG5jB+u0qblFCMO6zeyvgNIdslLZZifqP1hLls6tueUYuUeqBudVHLOTfAnC91Sqp
         PFzgvRJcx80ByKuPCk1XJTlVpT4VcQarc2882y6Vwm37Kbem09eOLy9yRPM1UCn2wnft
         QbpXMzVT2T6gakqJvdGHn0UVpJkU6PrED8F0saN+BzRR+QXHc6te11uI407rB2prmlx5
         zfGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GwruKyw7mHs3C54oT/QuJsxh7Ksfp9svOQkHJNfLpNk=;
        b=H+TXOCd8cQLSDidXEA6LvVuu5K8OvNmnd/2Gaq2WG3hyHDXBfoMR+Rc2CgXQhINGyu
         ahY5ljk6Ty4cWe2eailllH9ZGi0EB/nyZz8RibtBeq7dO87JBwctVDTV8v/+SmtaVwFX
         Rre93d+VXWX6TepQMsIdajXo42Nx8W0NFyVkXhJ9W6+eZhoYcdnv+AWEDRHoMEEcngZU
         Gt34tTgv428pANy9nTvbyiI3y1XhQfDgm91pb7Q61+Uf0X74FHinDWKGdQGlucfmV8n2
         q8Fzz+q8DRqpBT90/a3FTRxes64JJlcpqtN5IpuqAvETAwzNH81WEVJVtHJokfCPH4rd
         MWZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id pk16si31227922ejb.96.2019.08.09.02.54.39
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 02:54:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4CFA015A2;
	Fri,  9 Aug 2019 02:54:39 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0F7113F575;
	Fri,  9 Aug 2019 02:54:37 -0700 (PDT)
Date: Fri, 9 Aug 2019 10:54:35 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Daniel Axtens <dja@axtens.net>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org,
	aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org,
	linux-kernel@vger.kernel.org, dvyukov@google.com
Subject: Re: [PATCH v3 1/3] kasan: support backing vmalloc space with real
 shadow memory
Message-ID: <20190809095435.GD48423@lakrids.cambridge.arm.com>
References: <20190731071550.31814-1-dja@axtens.net>
 <20190731071550.31814-2-dja@axtens.net>
 <20190808135037.GA47131@lakrids.cambridge.arm.com>
 <20190808174325.GD47131@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808174325.GD47131@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 06:43:25PM +0100, Mark Rutland wrote:
> On Thu, Aug 08, 2019 at 02:50:37PM +0100, Mark Rutland wrote:
> > Hi Daniel,
> > 
> > This is looking really good!
> > 
> > I spotted a few more things we need to deal with, so I've suggested some
> > (not even compile-tested) code for that below. Mostly that's just error
> > handling, and using helpers to avoid things getting too verbose.
> 
> FWIW, I had a quick go at that, and I've pushed the (corrected) results
> to my git repo, along with an initial stab at arm64 support (which is
> currently broken):
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/mark/linux.git/log/?h=kasan/vmalloc

I've fixed my arm64 patch now, and that appears to work in basic tests
(example below), so I'll throw my arm64 Syzkaller instance at that today
to shake out anything major that we've missed or that I've botched.

I'm very excited to see this!

Are you happy to pick up my modified patch 1 for v4?

Thanks,
Mark.

# echo STACK_GUARD_PAGE_LEADING > DIRECT 
[  107.453162] lkdtm: Performing direct entry STACK_GUARD_PAGE_LEADING
[  107.454672] lkdtm: attempting bad read from page below current stack
[  107.456672] ==================================================================
[  107.457929] BUG: KASAN: vmalloc-out-of-bounds in lkdtm_STACK_GUARD_PAGE_LEADING+0x88/0xb4
[  107.459398] Read of size 1 at addr ffff20001515ffff by task sh/214
[  107.460864] 
[  107.461271] CPU: 0 PID: 214 Comm: sh Not tainted 5.3.0-rc3-00004-g84f902ca9396-dirty #7
[  107.463101] Hardware name: linux,dummy-virt (DT)
[  107.464407] Call trace:
[  107.464951]  dump_backtrace+0x0/0x1e8
[  107.465781]  show_stack+0x14/0x20
[  107.466824]  dump_stack+0xbc/0xf4
[  107.467780]  print_address_description+0x60/0x33c
[  107.469221]  __kasan_report+0x140/0x1a0
[  107.470388]  kasan_report+0xc/0x18
[  107.471439]  __asan_load1+0x4c/0x58
[  107.472428]  lkdtm_STACK_GUARD_PAGE_LEADING+0x88/0xb4
[  107.473908]  lkdtm_do_action+0x40/0x50
[  107.475255]  direct_entry+0x128/0x1b0
[  107.476348]  full_proxy_write+0x90/0xc8
[  107.477595]  __vfs_write+0x54/0xa8
[  107.478780]  vfs_write+0xd0/0x230
[  107.479762]  ksys_write+0xc4/0x170
[  107.480738]  __arm64_sys_write+0x40/0x50
[  107.481888]  el0_svc_common.constprop.0+0xc0/0x1c0
[  107.483240]  el0_svc_handler+0x34/0x88
[  107.484211]  el0_svc+0x8/0xc
[  107.484996] 
[  107.485429] 
[  107.485895] Memory state around the buggy address:
[  107.487107]  ffff20001515fe80: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
[  107.489162]  ffff20001515ff00: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
[  107.491157] >ffff20001515ff80: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
[  107.493193]                                                                 ^
[  107.494973]  ffff200015160000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  107.497103]  ffff200015160080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  107.498795] ==================================================================
[  107.500495] Disabling lock debugging due to kernel taint
[  107.503212] Unable to handle kernel paging request at virtual address ffff20001515ffff
[  107.505177] Mem abort info:
[  107.505797]   ESR = 0x96000007
[  107.506554]   Exception class = DABT (current EL), IL = 32 bits
[  107.508031]   SET = 0, FnV = 0
[  107.508547]   EA = 0, S1PTW = 0
[  107.509125] Data abort info:
[  107.509704]   ISV = 0, ISS = 0x00000007
[  107.510388]   CM = 0, WnR = 0
[  107.511089] swapper pgtable: 4k pages, 48-bit VAs, pgdp=0000000041c65000
[  107.513221] [ffff20001515ffff] pgd=00000000bdfff003, pud=00000000bdffe003, pmd=00000000aa31e003, pte=0000000000000000
[  107.515915] Internal error: Oops: 96000007 [#1] PREEMPT SMP
[  107.517295] Modules linked in:
[  107.518074] CPU: 0 PID: 214 Comm: sh Tainted: G    B             5.3.0-rc3-00004-g84f902ca9396-dirty #7
[  107.520755] Hardware name: linux,dummy-virt (DT)
[  107.522208] pstate: 60400005 (nZCv daif +PAN -UAO)
[  107.523670] pc : lkdtm_STACK_GUARD_PAGE_LEADING+0x88/0xb4
[  107.525176] lr : lkdtm_STACK_GUARD_PAGE_LEADING+0x88/0xb4
[  107.526809] sp : ffff200015167b90
[  107.527856] x29: ffff200015167b90 x28: ffff800002294740 
[  107.529728] x27: 0000000000000000 x26: 0000000000000000 
[  107.531523] x25: ffff200015167df0 x24: ffff2000116e8400 
[  107.533234] x23: ffff200015160000 x22: dfff200000000000 
[  107.534694] x21: ffff040002a2cf7a x20: ffff2000116e9ee0 
[  107.536238] x19: 1fffe40002a2cf7a x18: 0000000000000000 
[  107.537699] x17: 0000000000000000 x16: 0000000000000000 
[  107.539288] x15: 0000000000000000 x14: 0000000000000000 
[  107.540584] x13: 0000000000000000 x12: ffff10000d672bb9 
[  107.541920] x11: 1ffff0000d672bb8 x10: ffff10000d672bb8 
[  107.543438] x9 : 1ffff0000d672bb8 x8 : dfff200000000000 
[  107.545008] x7 : ffff10000d672bb9 x6 : ffff80006b395dc0 
[  107.546570] x5 : 0000000000000001 x4 : dfff200000000000 
[  107.547936] x3 : ffff20001113274c x2 : 0000000000000007 
[  107.549121] x1 : eb957a6c7b3ab400 x0 : 0000000000000000 
[  107.550220] Call trace:
[  107.551017]  lkdtm_STACK_GUARD_PAGE_LEADING+0x88/0xb4
[  107.552288]  lkdtm_do_action+0x40/0x50
[  107.553302]  direct_entry+0x128/0x1b0
[  107.554290]  full_proxy_write+0x90/0xc8
[  107.555332]  __vfs_write+0x54/0xa8
[  107.556278]  vfs_write+0xd0/0x230
[  107.557000]  ksys_write+0xc4/0x170
[  107.557834]  __arm64_sys_write+0x40/0x50
[  107.558980]  el0_svc_common.constprop.0+0xc0/0x1c0
[  107.560111]  el0_svc_handler+0x34/0x88
[  107.560936]  el0_svc+0x8/0xc
[  107.561580] Code: 91140280 97ded9e3 d10006e0 97e4672e (385ff2e1) 
[  107.563208] ---[ end trace 9e69aa587e1dc0cc ]---

