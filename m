Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95759C31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 02:08:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33F3520863
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 02:08:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PaKtAZBV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33F3520863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96E366B0003; Tue, 18 Jun 2019 22:08:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91F248E0002; Tue, 18 Jun 2019 22:08:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 835E08E0001; Tue, 18 Jun 2019 22:08:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6068B6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:08:39 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id z42so2228871uac.10
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 19:08:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=Zcgrh2Nt2NZ+TS/tReXDhAYsSlm95d7J1erUZeQsKfU=;
        b=EFIBYuJh+JgW0P2bgSpOme8BVXWqxbhwYW767Vl7J238ELZ1Ocpv4tALktq1lUVjaP
         coIhCiQ3j8qCPBtwzeZGyEI4W158dMoRHp5Qh9eUoRvwXZjYWowtfXXqALJqY386CP7s
         YrbcM5u5NeHJvMfKnWVAOS5USbKk0Dyrb9vnUa7/kH3MoLyUMD87218AzhQ2ex4YHiEC
         Eid+E+jgOE4ZgBbCfLmnN7fdF1yq2T0eHjfHOGvvUQSNGNCR9eUySiAC2ci9ibaxR8Ny
         W+TcLwvGXRr4ELeqnrdTN6wvNEgg9CnsEpqif4Ttz4wJ2ESC7TWq5B7PukQBgrCDbByB
         s9ig==
X-Gm-Message-State: APjAAAX48wSe2iygKYDRq7OD2Vtm0P294b7+jxS56NxXSU0IDTi5U8Zi
	EkcxkFjT65tdDEdaQn0q5PZj2plYNKIL2Ph1CAlaAjpsmzMwOdhDg92m81S0Y31y6YbJpqpxj5B
	oMAonj5NgizK/fm1qfzIw8E+V1sxSNe3yPm6jJaQayPPqN+3jZJ2/xsFt/UF7j5WDaw==
X-Received: by 2002:a67:3116:: with SMTP id x22mr2267787vsx.228.1560910118951;
        Tue, 18 Jun 2019 19:08:38 -0700 (PDT)
X-Received: by 2002:a67:3116:: with SMTP id x22mr2267771vsx.228.1560910117945;
        Tue, 18 Jun 2019 19:08:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560910117; cv=none;
        d=google.com; s=arc-20160816;
        b=sLPypCRB9VOitVa1fzfK0HIWGVfXgl2y5VizFIqBefcznifmo8IhlEw+/SwPxopkzp
         QNl/OkTUIsafj6QRXFWVWBZeEQOSjAWCuc3PkamOtx4VgKFqAp2E7x9soHykKDiqg1Yf
         sbhkJ3okz7L/U0N5FN5cBnCrr/FH1o4qWjj9TbZAzV0lj3zupmTg8oQmThw4wPEBDtCQ
         GnlLZEpD3zAz0dYqMuwAtpI2o8ImN5vKLO7GHUZ5wR2mOgaiKuzV8hHIJIvCCp//hp+W
         rEm3gD17wq6V1ytaON1xOgi/wXUwqxgVzqWAIVGrbakFimkIlU09F87MOK7h+uAP3YNX
         E8UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=Zcgrh2Nt2NZ+TS/tReXDhAYsSlm95d7J1erUZeQsKfU=;
        b=zQpeHXe5bs6P3fxYYrmVnqWox3F9cFcBWA8zSpEuI1TYoCsj/b2jH+VejOXmPZ9vgk
         Ew0iiODb5oUMi3cOpK0K/8mHKIJay+0y58d7C36++Qe5Zh+Kxgm6f0kkYX6wsi2381tz
         5SDnCoX4Wz36uR4aav6tHBnPa9K7fWjGfhKp090pOElEHPazVk2CypTtv6FOuLp7UTl8
         proI8nUoHXJTerURibvM8HWYp2avFFltdDRSyeCAyyyMU30nbjwIuHfUkh6FTWl/W5iR
         OFGD4Wi7jLZpLn4St+SYaE3ucp49pBnFspRqihMfXlM9K3BsRvZOq4pwOZXcqN3ShNl2
         0HgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PaKtAZBV;
       spf=pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=avagin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a18sor7926077vsl.61.2019.06.18.19.08.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 19:08:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PaKtAZBV;
       spf=pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=avagin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=Zcgrh2Nt2NZ+TS/tReXDhAYsSlm95d7J1erUZeQsKfU=;
        b=PaKtAZBVDVaO6Hb1I07e8lxDtp7KJnDTanQOq1WJ8DyoTY2I59iXmdUyfMZX4xStZQ
         vkyPksVc+t0tuX+d/KrtYBx6LLU/h3Em47sFuSJ8sX12vQSxkQYriIsfP68JUxf1trei
         KOnxjFZwaJNhEDGCm8GsutWtodYUJpYutzVviUQdHvJNx9UBE63z+KURqAqD7uq/UK7q
         8ang3NXcXIoRGnuAirlU8W0ktwLIqyc6239n6Nw6OwTHNLxREH+aM0BZlNy3UgKuvggh
         hmDrSt22Uo2djKKHJWgSBM67i6clQ3WxFZYuC6V7OPzeYLp/+1aoBL3m1gqm51ClELh0
         rhTw==
X-Google-Smtp-Source: APXvYqzR6M4ASBmE29kpToF1Qk4IgBC42FD2hpS8nsvAgOmI+6AJE50qVrom3xlqxZWLoeqJaQod5SCQ4ZWc2VYEPiM=
X-Received: by 2002:a67:8b44:: with SMTP id n65mr58201083vsd.99.1560910117425;
 Tue, 18 Jun 2019 19:08:37 -0700 (PDT)
MIME-Version: 1.0
From: Andrei Vagin <avagin@gmail.com>
Date: Tue, 18 Jun 2019 19:08:26 -0700
Message-ID: <CANaxB-xz6-uCYbSsSEXn3OScYCfpPwP_DxWdh63d9PuLNkeV5g@mail.gmail.com>
Subject: WARNING: CPU: 0 PID: 11655 at mm/page_counter.c:62
To: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

We run CRIU tests on linux-next kernels and today we found this
warning in the kernel log:

[  381.345960] WARNING: CPU: 0 PID: 11655 at mm/page_counter.c:62
page_counter_cancel+0x26/0x30
[  381.345992] Modules linked in:
[  381.345998] CPU: 0 PID: 11655 Comm: kworker/0:8 Not tainted
5.2.0-rc5-next-20190618+ #1
[  381.346001] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[  381.346010] Workqueue: memcg_kmem_cache kmemcg_workfn
[  381.346013] RIP: 0010:page_counter_cancel+0x26/0x30
[  381.346017] Code: 1f 44 00 00 0f 1f 44 00 00 48 89 f0 53 48 f7 d8
f0 48 0f c1 07 48 29 f0 48 89 c3 48 89 c6 e8 61 ff ff ff 48 85 db 78
02 5b c3 <0f> 0b 5b c3 66 0f 1f 44 00 00 0f 1f 44 00 00 48 85 ff 74 41
41 55
[  381.346019] RSP: 0018:ffffb3b34319f990 EFLAGS: 00010086
[  381.346022] RAX: fffffffffffffffc RBX: fffffffffffffffc RCX: 0000000000000004
[  381.346024] RDX: 0000000000000000 RSI: fffffffffffffffc RDI: ffff9c2cd7165270
[  381.346026] RBP: 0000000000000004 R08: 0000000000000000 R09: 0000000000000001
[  381.346028] R10: 00000000000000c8 R11: ffff9c2cd684e660 R12: 00000000fffffffc
[  381.346030] R13: 0000000000000002 R14: 0000000000000006 R15: ffff9c2c8ce1f200
[  381.346033] FS:  0000000000000000(0000) GS:ffff9c2cd8200000(0000)
knlGS:0000000000000000
[  381.346039] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  381.346041] CR2: 00000000007be000 CR3: 00000001cdbfc005 CR4: 00000000001606f0
[  381.346043] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  381.346045] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  381.346047] Call Trace:
[  381.346054]  page_counter_uncharge+0x1d/0x30
[  381.346065]  __memcg_kmem_uncharge_memcg+0x39/0x60
[  381.346071]  __free_slab+0x34c/0x460
[  381.346079]  deactivate_slab.isra.80+0x57d/0x6d0
[  381.346088]  ? add_lock_to_list.isra.36+0x9c/0xf0
[  381.346095]  ? __lock_acquire+0x252/0x1410
[  381.346106]  ? cpumask_next_and+0x19/0x20
[  381.346110]  ? slub_cpu_dead+0xd0/0xd0
[  381.346113]  flush_cpu_slab+0x36/0x50
[  381.346117]  ? slub_cpu_dead+0xd0/0xd0
[  381.346125]  on_each_cpu_mask+0x51/0x70
[  381.346131]  ? ksm_migrate_page+0x60/0x60
[  381.346134]  on_each_cpu_cond_mask+0xab/0x100
[  381.346143]  __kmem_cache_shrink+0x56/0x320
[  381.346150]  ? ret_from_fork+0x3a/0x50
[  381.346157]  ? unwind_next_frame+0x73/0x480
[  381.346176]  ? __lock_acquire+0x252/0x1410
[  381.346188]  ? kmemcg_workfn+0x21/0x50
[  381.346196]  ? __mutex_lock+0x99/0x920
[  381.346199]  ? kmemcg_workfn+0x21/0x50
[  381.346205]  ? kmemcg_workfn+0x21/0x50
[  381.346216]  __kmemcg_cache_deactivate_after_rcu+0xe/0x40
[  381.346220]  kmemcg_cache_deactivate_after_rcu+0xe/0x20
[  381.346223]  kmemcg_workfn+0x31/0x50
[  381.346230]  process_one_work+0x23c/0x5e0
[  381.346241]  worker_thread+0x3c/0x390
[  381.346248]  ? process_one_work+0x5e0/0x5e0
[  381.346252]  kthread+0x11d/0x140
[  381.346255]  ? kthread_create_on_node+0x60/0x60
[  381.346261]  ret_from_fork+0x3a/0x50
[  381.346275] irq event stamp: 10302
[  381.346278] hardirqs last  enabled at (10301): [<ffffffffb2c1a0b9>]
_raw_spin_unlock_irq+0x29/0x40
[  381.346282] hardirqs last disabled at (10302): [<ffffffffb2182289>]
on_each_cpu_mask+0x49/0x70
[  381.346287] softirqs last  enabled at (10262): [<ffffffffb2191f4a>]
cgroup_idr_replace+0x3a/0x50
[  381.346290] softirqs last disabled at (10260): [<ffffffffb2191f2d>]
cgroup_idr_replace+0x1d/0x50
[  381.346293] ---[ end trace b324ba73eb3659f0 ]---

All logs are here:
https://travis-ci.org/avagin/linux/builds/546601278

The problem is probably in the " [PATCH v7 00/10] mm: reparent slab
memory on cgroup removal" series.

Thanks,
Andrei

