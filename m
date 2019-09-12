Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A0E2C5ACAE
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 02:28:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C33EB2085B
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 02:28:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Ip5OLDle"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C33EB2085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58A4B6B0003; Wed, 11 Sep 2019 22:28:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 514536B0005; Wed, 11 Sep 2019 22:28:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B5736B0006; Wed, 11 Sep 2019 22:28:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0AED06B0003
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:28:40 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 70F53181AC9C6
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:28:39 +0000 (UTC)
X-FDA: 75924685158.01.sand11_2e66322868529
X-HE-Tag: sand11_2e66322868529
X-Filterd-Recvd-Size: 18101
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:28:38 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id g13so27462006qtj.4
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 19:28:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=oelIDX2GGk6G9QYTmFYRmlQXkUvz9vI70v2ZCNUKJKM=;
        b=Ip5OLDlekBoK2U5Kf5ZXwqLYQa0Q5Trx/h7GtpyjNFTDmGPyrffFiNGDFrYKoLo9t7
         Gv4OmFt8nSBoWYxmMwsvuGQ3wjQDt0sRGB1tShjb/Sec5EB5wAjSmzq9RaHNUUN0aQiS
         d10gRS+QYzsNdhFSeufkzNpYDbJZCEsRV5aToW/zcHojaxNUP5pJof+OEaO1bCJoWcOB
         w76wp4haJJErnxr6QYMUABWJ6McvwRauxIglaQ1Ov7/JaWq4VgZCY1gLCowz4PGTOtUh
         qYdmF/h82Zmrpt/0ep7N4IWnyJIHcPWjnoMYZMunFnJDWIru8Qsz5+x7AeRN+Aq73FX8
         UZGA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=oelIDX2GGk6G9QYTmFYRmlQXkUvz9vI70v2ZCNUKJKM=;
        b=eorM+XpuK21kS0WG7WNeasoZMOcGM4GMnsDjr44Pgfr4OJeD/dxh2JBsPYsSMKSTiF
         wjGLaaxOTTmYSyS9K/fN5ZC/ROeoa8ffwk2/1CSwwdkruCFCfRstyzvVBNOrhN3n/zba
         tlvEYY4FXwxlUpD5sM+KcZrQhl4ZuMedNiYjMX9Z90JjAEmhi+T79y/2CAT1LmsecSvc
         jS1ZtjvDBI0/X7g1oWluMP0dBpw2X59tN30ehgon2oSLV6Pt2jcp00sHbeROBi4CilrO
         GqpLdFXIwfikjlDwqQMGTmz3OA1ywokNvaQcXgszx+IwiVY5i7llV9uK3W5qnfNa5jzj
         PvUA==
X-Gm-Message-State: APjAAAWmFOlDpyRZtLjvw4srqsdizL/y3g6mE+FPvQq1giHc7FffsE1A
	H+98zklheAH01gr5H3fU/P4BXQ==
X-Google-Smtp-Source: APXvYqy0S4S+9rjaGmDNE4P2jqlz8fGZKK+gDRQ+1rTE2b2wmoD4RqJVoQpdgrK/0q88Nydab7eDJQ==
X-Received: by 2002:ac8:2b82:: with SMTP id m2mr39448499qtm.35.1568255317794;
        Wed, 11 Sep 2019 19:28:37 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id t73sm10835473qke.113.2019.09.11.19.28.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Sep 2019 19:28:37 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: CONFIG_SHUFFLE_PAGE_ALLOCATOR=y lockdep splat (WAS Re:
 page_alloc.shuffle=1 + CONFIG_PROVE_LOCKING=y = arm64 hang)
From: Qian Cai <cai@lca.pw>
In-Reply-To: <1568144988.5576.132.camel@lca.pw>
Date: Wed, 11 Sep 2019 22:28:35 -0400
Cc: Dan Williams <dan.j.williams@intel.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>,
 linux-arm-kernel@lists.infradead.org,
 Peter Zijlstra <peterz@infradead.org>,
 Waiman Long <longman@redhat.com>,
 Thomas Gleixner <tglx@linutronix.de>
Content-Transfer-Encoding: quoted-printable
Message-Id: <53A576C6-C9C4-45D0-A86F-1B7D1824E79E@lca.pw>
References: <1566509603.5576.10.camel@lca.pw>
 <1567717680.5576.104.camel@lca.pw> <1568128954.5576.129.camel@lca.pw>
 <1568144988.5576.132.camel@lca.pw>
To: Will Deacon <will@kernel.org>,
 Theodore Ts'o <tytso@mit.edu>,
 oleg@redhat.com,
 gkohli@codeaurora.org
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Adjusted Cc a bit as this looks like more of the scheduler territory.

> On Sep 10, 2019, at 3:49 PM, Qian Cai <cai@lca.pw> wrote:
>=20
> Hmm, it feels like that CONFIG_SHUFFLE_PAGE_ALLOCATOR=3Dy introduces =
some unique
> locking patterns that the lockdep does not like via,
>=20
> allocate_slab
>  shuffle_freelist
>    get_random_u32
>=20
> Here is another splat with while compiling/installing a kernel,
>=20
> [ 1254.443119][    C2] WARNING: possible circular locking dependency =
detected
> [ 1254.450038][    C2] 5.3.0-rc5-next-20190822 #1 Not tainted
> [ 1254.455559][    C2] =
------------------------------------------------------
> [ 1254.462988][    C2] swapper/2/0 is trying to acquire lock:
> [ 1254.468509][    C2] ffffffffa2925218 =
(random_write_wait.lock){..-.}, at:
> __wake_up_common_lock+0xc6/0x150
> [ 1254.478154][    C2]=20
> [ 1254.478154][    C2] but task is already holding lock:
> [ 1254.485896][    C2] ffff88845373fda0 =
(batched_entropy_u32.lock){-.-.}, at:
> get_random_u32+0x4c/0xe0
> [ 1254.495007][    C2]=20
> [ 1254.495007][    C2] which lock already depends on the new lock.
> [ 1254.495007][    C2]=20
> [ 1254.505331][    C2]=20
> [ 1254.505331][    C2] the existing dependency chain (in reverse =
order) is:
> [ 1254.514755][    C2]=20
> [ 1254.514755][    C2] -> #3 (batched_entropy_u32.lock){-.-.}:
> [ 1254.522553][    C2]        __lock_acquire+0x5b3/0xb40
> [ 1254.527638][    C2]        lock_acquire+0x126/0x280
> [ 1254.533016][    C2]        _raw_spin_lock_irqsave+0x3a/0x50
> [ 1254.538624][    C2]        get_random_u32+0x4c/0xe0
> [ 1254.543539][    C2]        allocate_slab+0x6d6/0x19c0
> [ 1254.548625][    C2]        new_slab+0x46/0x70
> [ 1254.553010][    C2]        ___slab_alloc+0x58b/0x960
> [ 1254.558533][    C2]        __slab_alloc+0x43/0x70
> [ 1254.563269][    C2]        kmem_cache_alloc+0x354/0x460
> [ 1254.568534][    C2]        fill_pool+0x272/0x4b0
> [ 1254.573182][    C2]        __debug_object_init+0x86/0x7a0
> [ 1254.578615][    C2]        debug_object_init+0x16/0x20
> [ 1254.584256][    C2]        hrtimer_init+0x27/0x1e0
> [ 1254.589079][    C2]        init_dl_task_timer+0x20/0x40
> [ 1254.594342][    C2]        __sched_fork+0x10b/0x1f0
> [ 1254.599253][    C2]        init_idle+0xac/0x520
> [ 1254.603816][    C2]        fork_idle+0x18c/0x230
> [ 1254.608933][    C2]        idle_threads_init+0xf0/0x187
> [ 1254.614193][    C2]        smp_init+0x1d/0x12d
> [ 1254.618671][    C2]        kernel_init_freeable+0x37e/0x76e
> [ 1254.624282][    C2]        kernel_init+0x11/0x12f
> [ 1254.629016][    C2]        ret_from_fork+0x27/0x50
> [ 1254.634344][    C2]=20
> [ 1254.634344][    C2] -> #2 (&rq->lock){-.-.}:
> [ 1254.640831][    C2]        __lock_acquire+0x5b3/0xb40
> [ 1254.645917][    C2]        lock_acquire+0x126/0x280
> [ 1254.650827][    C2]        _raw_spin_lock+0x2f/0x40
> [ 1254.655741][    C2]        task_fork_fair+0x43/0x200
> [ 1254.661213][    C2]        sched_fork+0x29b/0x420
> [ 1254.665949][    C2]        copy_process+0xf12/0x3180
> [ 1254.670947][    C2]        _do_fork+0xef/0x950
> [ 1254.675422][    C2]        kernel_thread+0xa8/0xe0
> [ 1254.680244][    C2]        rest_init+0x28/0x311
> [ 1254.685298][    C2]        arch_call_rest_init+0xe/0x1b
> [ 1254.690558][    C2]        start_kernel+0x6eb/0x724
> [ 1254.695469][    C2]        x86_64_start_reservations+0x24/0x26
> [ 1254.701339][    C2]        x86_64_start_kernel+0xf4/0xfb
> [ 1254.706689][    C2]        secondary_startup_64+0xb6/0xc0
> [ 1254.712601][    C2]=20
> [ 1254.712601][    C2] -> #1 (&p->pi_lock){-.-.}:
> [ 1254.719263][    C2]        __lock_acquire+0x5b3/0xb40
> [ 1254.724349][    C2]        lock_acquire+0x126/0x280
> [ 1254.729260][    C2]        _raw_spin_lock_irqsave+0x3a/0x50
> [ 1254.735317][    C2]        try_to_wake_up+0xad/0x1050
> [ 1254.740403][    C2]        default_wake_function+0x2f/0x40
> [ 1254.745929][    C2]        pollwake+0x10d/0x160
> [ 1254.750491][    C2]        __wake_up_common+0xc4/0x2a0
> [ 1254.755663][    C2]        __wake_up_common_lock+0xea/0x150
> [ 1254.761756][    C2]        __wake_up+0x13/0x20
> [ 1254.766230][    C2]        account.constprop.9+0x217/0x340
> [ 1254.771754][    C2]        extract_entropy.constprop.7+0xcf/0x220
> [ 1254.777886][    C2]        _xfer_secondary_pool+0x19a/0x3d0
> [ 1254.783981][    C2]        push_to_pool+0x3e/0x230
> [ 1254.788805][    C2]        process_one_work+0x52a/0xb40
> [ 1254.794064][    C2]        worker_thread+0x63/0x5b0
> [ 1254.798977][    C2]        kthread+0x1df/0x200
> [ 1254.803451][    C2]        ret_from_fork+0x27/0x50
> [ 1254.808787][    C2]=20
> [ 1254.808787][    C2] -> #0 (random_write_wait.lock){..-.}:
> [ 1254.816409][    C2]        check_prev_add+0x107/0xea0
> [ 1254.821494][    C2]        validate_chain+0x8fc/0x1200
> [ 1254.826667][    C2]        __lock_acquire+0x5b3/0xb40
> [ 1254.831751][    C2]        lock_acquire+0x126/0x280
> [ 1254.837189][    C2]        _raw_spin_lock_irqsave+0x3a/0x50
> [ 1254.842797][    C2]        __wake_up_common_lock+0xc6/0x150
> [ 1254.848408][    C2]        __wake_up+0x13/0x20
> [ 1254.852882][    C2]        account.constprop.9+0x217/0x340
> [ 1254.858988][    C2]        extract_entropy.constprop.7+0xcf/0x220
> [ 1254.865122][    C2]        crng_reseed+0xa1/0x3f0
> [ 1254.869859][    C2]        _extract_crng+0xc3/0xd0
> [ 1254.874682][    C2]        crng_reseed+0x21b/0x3f0
> [ 1254.879505][    C2]        _extract_crng+0xc3/0xd0
> [ 1254.884772][    C2]        extract_crng+0x40/0x60
> [ 1254.889507][    C2]        get_random_u32+0xb4/0xe0
> [ 1254.894417][    C2]        allocate_slab+0x6d6/0x19c0
> [ 1254.899501][    C2]        new_slab+0x46/0x70
> [ 1254.903886][    C2]        ___slab_alloc+0x58b/0x960
> [ 1254.909377][    C2]        __slab_alloc+0x43/0x70
> [ 1254.914112][    C2]        kmem_cache_alloc+0x354/0x460
> [ 1254.919375][    C2]        __build_skb+0x23/0x60
> [ 1254.924024][    C2]        __netdev_alloc_skb+0x127/0x1e0
> [ 1254.929470][    C2]        tg3_poll_work+0x11b2/0x1f70 [tg3]
> [ 1254.935654][    C2]        tg3_poll_msix+0x67/0x330 [tg3]
> [ 1254.941092][    C2]        net_rx_action+0x24e/0x7e0
> [ 1254.946089][    C2]        __do_softirq+0x123/0x767
> [ 1254.951000][    C2]        irq_exit+0xd6/0xf0
> [ 1254.955385][    C2]        do_IRQ+0xe2/0x1a0
> [ 1254.960155][    C2]        ret_from_intr+0x0/0x2a
> [ 1254.964896][    C2]        cpuidle_enter_state+0x156/0x8e0
> [ 1254.970418][    C2]        cpuidle_enter+0x41/0x70
> [ 1254.975242][    C2]        call_cpuidle+0x5e/0x90
> [ 1254.979975][    C2]        do_idle+0x333/0x370
> [ 1254.984972][    C2]        cpu_startup_entry+0x1d/0x1f
> [ 1254.990148][    C2]        start_secondary+0x290/0x330
> [ 1254.995319][    C2]        secondary_startup_64+0xb6/0xc0
> [ 1255.000750][    C2]=20
> [ 1255.000750][    C2] other info that might help us debug this:
> [ 1255.000750][    C2]=20
> [ 1255.011424][    C2] Chain exists of:
> [ 1255.011424][    C2]   random_write_wait.lock --> &rq->lock -->
> batched_entropy_u32.lock
> [ 1255.011424][    C2]=20
> [ 1255.025245][    C2]  Possible unsafe locking scenario:
> [ 1255.025245][    C2]=20
> [ 1255.033012][    C2]        CPU0                    CPU1
> [ 1255.038270][    C2]        ----                    ----
> [ 1255.043526][    C2]   lock(batched_entropy_u32.lock);
> [ 1255.048610][    C2]                                lock(&rq->lock);
> [
> 1255.054918][    C2]                                =
lock(batched_entropy_u32.loc
> k);
> [ 1255.063035][    C2]   lock(random_write_wait.lock);
> [ 1255.067945][    C2]=20
> [ 1255.067945][    C2]  *** DEADLOCK ***
> [ 1255.067945][    C2]=20
> [ 1255.076000][    C2] 1 lock held by swapper/2/0:
> [ 1255.080558][    C2]  #0: ffff88845373fda0 =
(batched_entropy_u32.lock){-.-.},
> at: get_random_u32+0x4c/0xe0
> [ 1255.090547][    C2]=20
> [ 1255.090547][    C2] stack backtrace:
> [ 1255.096333][    C2] CPU: 2 PID: 0 Comm: swapper/2 Not tainted =
5.3.0-rc5-next-
> 20190822 #1
> [ 1255.104473][    C2] Hardware name: HPE ProLiant DL385 =
Gen10/ProLiant DL385
> Gen10, BIOS A40 03/09/2018
> [ 1255.114276][    C2] Call Trace:
> [ 1255.117439][    C2]  <IRQ>
> [ 1255.120169][    C2]  dump_stack+0x86/0xca
> [ 1255.124205][    C2]  print_circular_bug.cold.32+0x243/0x26e
> [ 1255.129816][    C2]  check_noncircular+0x29e/0x2e0
> [ 1255.135221][    C2]  ? __bfs+0x238/0x380
> [ 1255.139172][    C2]  ? print_circular_bug+0x120/0x120
> [ 1255.144259][    C2]  ? find_usage_forwards+0x7d/0xb0
> [ 1255.149260][    C2]  check_prev_add+0x107/0xea0
> [ 1255.153823][    C2]  validate_chain+0x8fc/0x1200
> [ 1255.159007][    C2]  ? check_prev_add+0xea0/0xea0
> [ 1255.163743][    C2]  ? check_usage_backwards+0x210/0x210
> [ 1255.169091][    C2]  __lock_acquire+0x5b3/0xb40
> [ 1255.173655][    C2]  lock_acquire+0x126/0x280
> [ 1255.178041][    C2]  ? __wake_up_common_lock+0xc6/0x150
> [ 1255.183732][    C2]  _raw_spin_lock_irqsave+0x3a/0x50
> [ 1255.188817][    C2]  ? __wake_up_common_lock+0xc6/0x150
> [ 1255.194076][    C2]  __wake_up_common_lock+0xc6/0x150
> [ 1255.199163][    C2]  ? __wake_up_common+0x2a0/0x2a0
> [ 1255.204078][    C2]  ? rcu_read_lock_any_held.part.5+0x20/0x20
> [ 1255.210428][    C2]  __wake_up+0x13/0x20
> [ 1255.214379][    C2]  account.constprop.9+0x217/0x340
> [ 1255.219377][    C2]  extract_entropy.constprop.7+0xcf/0x220
> [ 1255.224987][    C2]  ? crng_reseed+0xa1/0x3f0
> [ 1255.229375][    C2]  crng_reseed+0xa1/0x3f0
> [ 1255.234122][    C2]  ? rcu_read_lock_sched_held+0xac/0xe0
> [ 1255.239556][    C2]  ? check_flags.part.16+0x86/0x220
> [ 1255.244641][    C2]  ? extract_entropy.constprop.7+0x220/0x220
> [ 1255.250511][    C2]  ? __kasan_check_read+0x11/0x20
> [ 1255.255422][    C2]  ? validate_chain+0xab/0x1200
> [ 1255.260742][    C2]  ? rcu_read_lock_any_held.part.5+0x20/0x20
> [ 1255.266616][    C2]  _extract_crng+0xc3/0xd0
> [ 1255.270915][    C2]  crng_reseed+0x21b/0x3f0
> [ 1255.275215][    C2]  ? extract_entropy.constprop.7+0x220/0x220
> [ 1255.281085][    C2]  ? __kasan_check_write+0x14/0x20
> [ 1255.286517][    C2]  ? do_raw_spin_lock+0x118/0x1d0
> [ 1255.291428][    C2]  ? rwlock_bug.part.0+0x60/0x60
> [ 1255.296251][    C2]  _extract_crng+0xc3/0xd0
> [ 1255.300550][    C2]  extract_crng+0x40/0x60
> [ 1255.304763][    C2]  get_random_u32+0xb4/0xe0
> [ 1255.309640][    C2]  allocate_slab+0x6d6/0x19c0
> [ 1255.314203][    C2]  new_slab+0x46/0x70
> [ 1255.318066][    C2]  ___slab_alloc+0x58b/0x960
> [ 1255.322539][    C2]  ? __build_skb+0x23/0x60
> [ 1255.326841][    C2]  ? fault_create_debugfs_attr+0x140/0x140
> [ 1255.333048][    C2]  ? __build_skb+0x23/0x60
> [ 1255.337348][    C2]  __slab_alloc+0x43/0x70
> [ 1255.341559][    C2]  ? __slab_alloc+0x43/0x70
> [ 1255.345944][    C2]  ? __build_skb+0x23/0x60
> [ 1255.350242][    C2]  kmem_cache_alloc+0x354/0x460
> [ 1255.354978][    C2]  ? __netdev_alloc_skb+0x1c6/0x1e0
> [ 1255.360626][    C2]  ? trace_hardirqs_on+0x3a/0x160
> [ 1255.365535][    C2]  __build_skb+0x23/0x60
> [ 1255.369660][    C2]  __netdev_alloc_skb+0x127/0x1e0
> [ 1255.374576][    C2]  tg3_poll_work+0x11b2/0x1f70 [tg3]
> [ 1255.379750][    C2]  ? find_held_lock+0x11b/0x150
> [ 1255.385027][    C2]  ? tg3_tx_recover+0xa0/0xa0 [tg3]
> [ 1255.390114][    C2]  ? _raw_spin_unlock_irqrestore+0x38/0x50
> [ 1255.395809][    C2]  ? __kasan_check_read+0x11/0x20
> [ 1255.400718][    C2]  ? validate_chain+0xab/0x1200
> [ 1255.405455][    C2]  ? __wake_up_common+0x2a0/0x2a0
> [ 1255.410761][    C2]  ? mark_held_locks+0x34/0xb0
> [ 1255.415415][    C2]  tg3_poll_msix+0x67/0x330 [tg3]
> [ 1255.420327][    C2]  net_rx_action+0x24e/0x7e0
> [ 1255.424800][    C2]  ? find_held_lock+0x11b/0x150
> [ 1255.429536][    C2]  ? napi_busy_loop+0x600/0x600
> [ 1255.434733][    C2]  ? rcu_read_lock_sched_held+0xac/0xe0
> [ 1255.440169][    C2]  ? __do_softirq+0xed/0x767
> [ 1255.444642][    C2]  ? rcu_read_lock_any_held.part.5+0x20/0x20
> [ 1255.450518][    C2]  ? lockdep_hardirqs_on+0x1b0/0x2a0
> [ 1255.455693][    C2]  ? irq_exit+0xd6/0xf0
> [ 1255.460280][    C2]  __do_softirq+0x123/0x767
> [ 1255.464668][    C2]  irq_exit+0xd6/0xf0
> [ 1255.468532][    C2]  do_IRQ+0xe2/0x1a0
> [ 1255.472308][    C2]  common_interrupt+0xf/0xf
> [ 1255.476694][    C2]  </IRQ>
> [ 1255.479509][    C2] RIP: 0010:cpuidle_enter_state+0x156/0x8e0
> [ 1255.485750][    C2] Code: bf ff 8b 05 a4 27 2d 01 85 c0 0f 8f 1d 04 =
00 00 31
> ff e8 4d ba 92 ff 80 7d d0 00 0f 85 0b 02 00 00 e8 ae c0 a7 ff fb 45 =
85 ed <0f>
> 88 2d 02 00 00 4d 63 fd 49 83 ff 09 0f 87 91 06 00 00 4b 8d 04
> [ 1255.505335][    C2] RSP: 0018:ffff888206637cf8 EFLAGS: 00000202 =
ORIG_RAX:
> ffffffffffffffc8
> [ 1255.514154][    C2] RAX: 0000000000000000 RBX: ffff889f98b44008 =
RCX:
> ffffffffa116e980
> [ 1255.522033][    C2] RDX: 0000000000000007 RSI: dffffc0000000000 =
RDI:
> ffff8882066287ec
> [ 1255.529913][    C2] RBP: ffff888206637d48 R08: fffffbfff4557aee =
R09:
> 0000000000000000
> [ 1255.538278][    C2] R10: 0000000000000000 R11: 0000000000000000 =
R12:
> ffffffffa28e8ac0
> [ 1255.546158][    C2] R13: 0000000000000002 R14: 0000012412160253 =
R15:
> ffff889f98b4400c
> [ 1255.554040][    C2]  ? lockdep_hardirqs_on+0x1b0/0x2a0
> [ 1255.559725][    C2]  ? cpuidle_enter_state+0x152/0x8e0
> [ 1255.564898][    C2]  cpuidle_enter+0x41/0x70
> [ 1255.569196][    C2]  call_cpuidle+0x5e/0x90
> [ 1255.573408][    C2]  do_idle+0x333/0x370
> [ 1255.577358][    C2]  ? complete+0x51/0x60
> [ 1255.581394][    C2]  ? arch_cpu_idle_exit+0x40/0x40
> [ 1255.586777][    C2]  ? complete+0x51/0x60
> [ 1255.590814][    C2]  cpu_startup_entry+0x1d/0x1f
> [ 1255.595461][    C2]  start_secondary+0x290/0x330
> [ 1255.600111][    C2]  ? set_cpu_sibling_map+0x18f0/0x18f0
> [ 1255.605460][    C2]  secondary_startup_64+0xb6/0xc0

This looks like a false positive. shuffle_freelist() introduced the =
chain,

batched_entropy_u32.lock -> random_write_wait.lock

but I can=E2=80=99t see how it is possible to get the reversed chain. =
Imaging something like this,

 __wake_up_common_lock  <=E2=80=94 acquired random_write_wait.lock
      __sched_fork <=E2=80=94 is that even possible?
           init_dl_task_timer
              debug_object_init
                   allocate_slab
                      shuffle_freelist
                          get_random_u32 <=E2=80=94 acquired =
batched_entropy_u32.lock=

