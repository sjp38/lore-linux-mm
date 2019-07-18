Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21C94C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 15:51:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE9A7208C0
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 15:51:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rrnpLwV7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE9A7208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A8F38E0005; Thu, 18 Jul 2019 11:51:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75B138E0001; Thu, 18 Jul 2019 11:51:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 670378E0005; Thu, 18 Jul 2019 11:51:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABE28E0001
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 11:51:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so20203474ede.23
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 08:51:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=o1/2Vj7xsNu11SnVwjU6bjgxspYgWkQ65EmdfVPZ5+g=;
        b=a4BygiO8oXtp6bUXTscygI7OWMuz6dhWtyTiyfbTAgew+MjX377Ta+G1KKGu2AQC3o
         9IHCtYdy1C7OjakOCDSX0++e2rrmLVZ/BpXrh2kcIunjo/tnjuuiLt5qXMLogsyf5tOr
         nS57Rr32Z8sPC/W16UH975ne57Tmf8/H+ltbOcxxejQmvannrM+PIamGsLyZoYlcTz8Q
         e8ld1aNsyIIA+n5CbTssu9YtsbCnD6ypHz+3f9eBGdJClDCx9AwQ1z+vAqUP8kCofDIV
         VMgsPIdSqjBQmYIYEmQivnh6M/malzSR7wf3xkKRTIfbefnynkKHw4gc7eH5vPTaXbff
         zvnA==
X-Gm-Message-State: APjAAAVwmNWqVoHyP2yjzEIZg79SVtUwYppnePGGrB3vQydjD6OFkNhk
	1NS1NA25kvYJWpNDfV9K+GEJca3D0ZTpi3+WWAhn3b5ibPoqOjPpCTuw+q5T3Q9PqZ+8gMOLel2
	3w29fqbbzjGlfG2hrm6KJUpetyCGDy5I9P3l1NpkoD8mglxVrwb+C9isAjt5/Xwp5tQ==
X-Received: by 2002:aa7:c559:: with SMTP id s25mr40640407edr.117.1563465111693;
        Thu, 18 Jul 2019 08:51:51 -0700 (PDT)
X-Received: by 2002:aa7:c559:: with SMTP id s25mr40640332edr.117.1563465110831;
        Thu, 18 Jul 2019 08:51:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563465110; cv=none;
        d=google.com; s=arc-20160816;
        b=b8qeyPLY5IhgyQbR6CvM8Bmg3O+6zAQ3VKg6W3yEeTy09Zdz76xjaGax3BV7sdwntL
         6ImQGM/gTKXQ9Fkb5KjcHnTdhGGCzyM98ttg0N/OzEkFhGPH420NxaeOcZsC4ovJTTaz
         l+hZdBuGym+Y8qVeoexAu6gDCJiixHwqColeY3onjufbiJGaMgLr5Pc8Fek8kA1K4F2n
         hUVYFmxJOk85QuGbmevBvoSildovtT4TLC4rLs+T7RSCvQsxMIZTx1kNfEJAwt+DdT1s
         r/6wA+3uK6cLyPyfZC2d48IAoYJS9J039qyApLUUGCkT84v+0rGvqocdn+YcYOPKVU6R
         Ho7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=o1/2Vj7xsNu11SnVwjU6bjgxspYgWkQ65EmdfVPZ5+g=;
        b=E13c5yFvSuchFRdCAm8KzUkuYbu/WIfD3FZ1CLABkVyke5aGQz8Sm0RHeLwHmGVKkI
         abxvVXjaw1xuYysEUrEyGDoAoSZS7bGeyq5Iao1Y7sRSW/wQ+4JjlwZw+UXxvz8poZVb
         NHtBcmTgNXw03c6kWDQq1MhoPR3VZ3rMgkUUYY7Tq2XKlUjfezvHYoAO88MCrwbLZrGz
         fldrDsV9PINzbhlblgJQalyIpSziJM6GyUnszJaFmTme7LwxAuTpBtot4ZFA4Tjlp3WY
         C6YJgoS0mB2F/MWlhgXMCFpjG7fAS4Cz00hV02d/h6Dlr7ytznOqZE7YWCcw5kMbxnvo
         ZhlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rrnpLwV7;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id dx6sor9278037ejb.37.2019.07.18.08.51.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 08:51:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rrnpLwV7;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=o1/2Vj7xsNu11SnVwjU6bjgxspYgWkQ65EmdfVPZ5+g=;
        b=rrnpLwV7JKspeC+AT2HYLoo9is9pcRiv0lSu2Nwr16wbT8io4MRCltJUtLp6gxkOOp
         GrvYZW/wmX6ePV5SX6KzndxJF3rnLFHo6k0CuBRfOWW7BAyYgmWLia99W9sKY1XNqlMK
         S5F5yW2QFJVUeLDjwjndf4LM+WJ0CKJPICGGDQMqytNQgTmapQHO+cMj/SOFj2fF/Jlo
         Jl6iXHrdvgP1MaHj23a2/dWBd5A/yd+r2BTot1UI8B8CM19+Keu1npKPe3BosAitZu8m
         ZZIkNpY6HoTnZrMG1UIFMxz2Ev7Xe3Wft58UOkLropjQF4PlPrjtcdZAAY7o492IKrcY
         o8QA==
X-Google-Smtp-Source: APXvYqw00ujty99sE0UwyCrWserbFlWAFCGTN+6SZBiwaPFyqiJ29qMg1gTGBJT2Tgv5+5XWImY/7i+W2RoFb/dclQs=
X-Received: by 2002:a17:906:4bcb:: with SMTP id x11mr36854194ejv.1.1563465110036;
 Thu, 18 Jul 2019 08:51:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190708150532.GB17098@dennisz-mbp>
In-Reply-To: <20190708150532.GB17098@dennisz-mbp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 18 Jul 2019 17:51:37 +0200
Message-ID: <CACT4Y+YevDd-y4Au33=mr-0-UQPy8NR0vmG8zSiCfmzx6gTB-w@mail.gmail.com>
Subject: Re: kasan: paging percpu + kasan causes a double fault
To: Dennis Zhou <dennis@kernel.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Tejun Heo <tj@kernel.org>, Kefeng Wang <wangkefeng.wang@huawei.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 8, 2019 at 5:05 PM Dennis Zhou <dennis@kernel.org> wrote:
>
> Hi Andrey, Alexander, and Dmitry,
>
> It was reported to me that when percpu is ran with param
> percpu_alloc=page or the embed allocation scheme fails and falls back to
> page that a double fault occurs.
>
> I don't know much about how kasan works, but a difference between the
> two is that we manually reserve vm area via vm_area_register_early().
> I guessed it had something to do with the stack canary or the irq_stack,
> and manually mapped the shadow vm area with kasan_add_zero_shadow(), but
> that didn't seem to do the trick.
>
> RIP resolves to the fixed_percpu_data declaration.
>
> Double fault below:
> [    0.000000] PANIC: double fault, error_code: 0x0
> [    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 5.2.0-rc7-00007-ge0afe6d4d12c-dirty #299
> [    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.el7 04/01/2014
> [    0.000000] RIP: 0010:no_context+0x38/0x4b0
> [    0.000000] Code: df 41 57 41 56 4c 8d bf 88 00 00 00 41 55 49 89 d5 41 54 49 89 f4 55 48 89 fd 4c8
> [    0.000000] RSP: 0000:ffffc8ffffffff28 EFLAGS: 00010096
> [    0.000000] RAX: dffffc0000000000 RBX: ffffc8ffffffff50 RCX: 000000000000000b
> [    0.000000] RDX: fffff52000000030 RSI: 0000000000000003 RDI: ffffc90000000130
> [    0.000000] RBP: ffffc900000000a8 R08: 0000000000000001 R09: 0000000000000000
> [    0.000000] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000003
> [    0.000000] R13: fffff52000000030 R14: 0000000000000000 R15: ffffc90000000130
> [    0.000000] FS:  0000000000000000(0000) GS:ffffc90000000000(0000) knlGS:0000000000000000
> [    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.000000] CR2: ffffc8ffffffff18 CR3: 0000000002e0d001 CR4: 00000000000606b0
> [    0.000000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [    0.000000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [    0.000000] Call Trace:
> [    0.000000] Kernel panic - not syncing: Machine halted.
> [    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 5.2.0-rc7-00007-ge0afe6d4d12c-dirty #299
> [    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.el7 04/01/2014
> [    0.000000] Call Trace:
> [    0.000000]  <#DF>
> [    0.000000]  dump_stack+0x5b/0x90
> [    0.000000]  panic+0x17e/0x36e
> [    0.000000]  ? __warn_printk+0xdb/0xdb
> [    0.000000]  ? spurious_kernel_fault_check+0x1a/0x60
> [    0.000000]  df_debug+0x2e/0x39
> [    0.000000]  do_double_fault+0x89/0xb0
> [    0.000000]  double_fault+0x1e/0x30
> [    0.000000] RIP: 0010:no_context+0x38/0x4b0
> [    0.000000] Code: df 41 57 41 56 4c 8d bf 88 00 00 00 41 55 49 89 d5 41 54 49 89 f4 55 48 89 fd 4c8
> [    0.000000] RSP: 0000:ffffc8ffffffff28 EFLAGS: 00010096
> [    0.000000] RAX: dffffc0000000000 RBX: ffffc8ffffffff50 RCX: 000000000000000b
> [    0.000000] RDX: fffff52000000030 RSI: 0000000000000003 RDI: ffffc90000000130
> [    0.000000] RBP: ffffc900000000a8 R08: 0000000000000001 R09: 0000000000000000
> [    0.000000] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000003
> [ 0.000000] R13: fffff52000000030 R14: 0000000000000000 R15: ffffc90000000130


Hi Dennis,

I don't have lots of useful info, but a naive question: could you stop
using percpu_alloc=page with KASAN? That should resolve the problem :)
We could even add a runtime check that will clearly say that this
combintation does not work.

I see that setup_per_cpu_areas is called after kasan_init which is
called from setup_arch. So KASAN should already map final shadow at
that point.
The only potential reason that I see is that setup_per_cpu_areas maps
the percpu region at address that is not covered/expected by
kasan_init. Where is page-based percpu is mapped? Is that covered by
kasan_init?
Otherwise, seeing the full stack trace of the fault may shed some light.

