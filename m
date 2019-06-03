Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B3EBC04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 08:54:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34E9527DD1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 08:54:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Bnaq2q9U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34E9527DD1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FD546B0269; Mon,  3 Jun 2019 04:54:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 786296B026B; Mon,  3 Jun 2019 04:54:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64F046B026C; Mon,  3 Jun 2019 04:54:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC8C56B0269
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 04:54:15 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id q12so1403554ljc.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 01:54:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JUUJPuh4FPDthH4k9+d32/GKkWMslSeYJNdsv2xAH8E=;
        b=knuaRPN3ojf0GyIete0lL6LbJ8gVZe0qs5GRh6PMKDexxuW/i9db7hlmzItughTGxo
         3ZL3MBDHml4v9sbuEKHuFOP0vibpEn5rMy03ihaLTzcXNQvanihgVhB6trDjParluiCM
         LWJmNJxTSgvj0BUXUm5gXIb32nFv2BVUq4ObGwV0BjALu7zpdLd3O49CUIWUP4yPIR/p
         RlBazAjsAHzykUBAK2d4Zfy20Rax7NdJBe258YylB8rwf+qlGBETXA5kaMLPNUu77wXZ
         q9+laV+SF67VRSLGlM3o6fCLdXvEq916FDMX7h9PVPYtPN+q35Fq5tJoDXUva8szpFTu
         08ag==
X-Gm-Message-State: APjAAAX4qMKUe5ZXxI3s7DLKGtNCkRpYk+UqJ2PTm6HsuXZv4MzDBUzR
	pJZpLkyetvixOgU9o9k0t7ZhaEfewiVgKseUTjKnW0Wkezr7FTGY3hHCZ/tomItzvk1JYy7/vR9
	mPZhTkEfVa5FIVlgWnq41RZhVgqsldi3EERUCRLi+yCH2geW/m+EITrAyFSAcUAaWaA==
X-Received: by 2002:a2e:89d0:: with SMTP id c16mr1980941ljk.219.1559552055185;
        Mon, 03 Jun 2019 01:54:15 -0700 (PDT)
X-Received: by 2002:a2e:89d0:: with SMTP id c16mr1980901ljk.219.1559552054138;
        Mon, 03 Jun 2019 01:54:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559552054; cv=none;
        d=google.com; s=arc-20160816;
        b=fUXfWo6MO/eY0173NxRgRd0ypSypV2OraMnt5XgomYv7HjwtsNyQV4yqEnAwQY+wtb
         C08gghWTvEBn5TWFTkCgrCNnewtId21wWS9B4kEukQnNLSQG413Dj/fCtAZW8FZj7lZD
         xCryhbMyv2a/9Bb/RoZ0EMKOdVlrFb8QfjYDk9iVjwBw0Efijg4AkHiH4G50e1s6TbYE
         2H0SHjuECV35qyv0Schb06BZCrbn0zEIT6NRfSCkapWSBLN1UzwjdygIHIlEHeOv5epo
         8tZCGg27fEQqGFfyXAFwdf+ORJ5lrbfthnSdb9l6s2/8b4uo0ziwb+gBlfagGf4MbNSA
         jGag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=JUUJPuh4FPDthH4k9+d32/GKkWMslSeYJNdsv2xAH8E=;
        b=tojwhDWMpOQF7JhaifEOH2MlKxOGacQSTx9sC2Cuu4wPEFri3JUlqEVSEG7jSK1Cv4
         Kv6trDLbY8wP6JxyotfJC2nHOgb22MiGzOLt3MZtrbeofwVL3Ri6FuXXIi9dKEBj6ZGL
         ZEUby6kQqO1hBH19txEVll7+VYC6XJfgPJa+RlkznJ8yQW0S02l1RPgbHWY0dMOiwDVK
         bYr2FL0SgHTfHTyJ8n5+PWfXZDr/+aORpdrVgZwFJJEUx2011TNYBMOgw7/c8C+pmLxv
         ijSG5X6pgbU2E2eT97HmQ3t+51soBIY7U9T6QD6P2P+QRQ2kOzALaKcovxB109s9+DP6
         +g/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Bnaq2q9U;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w16sor5287845ljw.32.2019.06.03.01.54.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 01:54:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Bnaq2q9U;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=JUUJPuh4FPDthH4k9+d32/GKkWMslSeYJNdsv2xAH8E=;
        b=Bnaq2q9UT6+uD6gnDtm7lycidd6swzo3+noCOZPmFLmz010XBkIXJeIk36Cb56jFgT
         q2psdaHLFOgRS0cy72FtcC8fFp8V8yCHjquAy5zSSHky5hgVYzFyneCF2mZoETXoZeuH
         +Q8k7GjDWIgkM2Dz7X3iJ/BZ+p4hd0K9Ki6cD8xLwEMn0a/XvvNbsOR3Ggbrj6TIJsCR
         Dt5q7d/+FihqTsMAwSs7xiaBH5ACsdxzj5tV+cmhMKgtL3stErB6xAyoNqqAzDBRP44c
         8jkMHl97RItrAewAvPErnDevPnpXJoPY+n2u4Fe9dTk3Q17b3vfXaNmAPcj0KSy09SEJ
         vtZA==
X-Google-Smtp-Source: APXvYqwX8KTxehG6Moh7s0HVPC2PVEerjV608hM0QJQvkyLWY5zulnaoungJPYhfg45EtX4hB2Ba3A==
X-Received: by 2002:a2e:6c01:: with SMTP id h1mr13773830ljc.103.1559552053499;
        Mon, 03 Jun 2019 01:54:13 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id p1sm3039454ljj.1.2019.06.03.01.54.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 01:54:12 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 3 Jun 2019 10:54:05 +0200
To: Andrei Vagin <avagin@gmail.com>
Cc: linux-mm@kvack.org, "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: Re: linux-next: general protection fault in __free_vmap_area
Message-ID: <20190603085405.hypqfabymvhto3ay@pc636>
References: <CANaxB-x6C_=CWhfXf0Uqi6FeAkyG-onRf9E==y_V1182GqjF6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANaxB-x6C_=CWhfXf0Uqi6FeAkyG-onRf9E==y_V1182GqjF6A@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 01:02:20AM -0700, Andrei Vagin wrote:
> Hello all,
> 
> I tried to boot linux-next in a kvm virtual machine, but it always panics:
> 
> [    5.897542] general protection fault: 0000 [#1] SMP PTI
> [    5.898716] CPU: 0 PID: 1 Comm: swapper/0 Not tainted
> 5.2.0-rc3-next-20190603-00001-g13841016de38 #1
> [    5.900872] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS ?-20180724_192412-buildhw-07.phx2.fedoraproject.org-1.fc29
> 04/01/2014
> [    5.903238] RIP: 0010:__free_vmap_area+0x7b/0x340
> [    5.904070] Code: ad de 48 89 5d 20 48 89 45 38 48 83 c0 22 48 89
> 45 40 48 8b 05 0e 24 77 02 48 85 c0 0f 84 9e 02 00 00 48 8b 7d 00 48
> 8b 75 08 <48> 8b 50 e0 48 3b 78 e8 73 07 48 39 f2 73 19 0f 0b 48 39 f2
> 73 f9
> [    5.907811] RSP: 0000:ffffb92f80637db0 EFLAGS: 00010202
> [    5.908883] RAX: 6b6b6b6b6b6b6b6b RBX: ffff8f6838de9460 RCX: 6b6b6b6b6b6b6b6b
> [    5.910349] RDX: ffff8f6838de9a80 RSI: ffffb92f81281000 RDI: ffffb92f8127c000
> [    5.911766] RBP: ffff8f6838de9440 R08: ffff8f6838de9280 R09: ffff8f6838de9550
> [    5.913138] R10: ffff8f6838de95c8 R11: 0000000000000000 R12: ffff8f6838de93c8
> [    5.914594] R13: 0000000000008000 R14: ffffffff8b9fb8b0 R15: ffffffff8a61771b
> [    5.916362] FS:  0000000000000000(0000) GS:ffff8f683ba00000(0000)
> knlGS:0000000000000000
> [    5.918360] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    5.919926] CR2: 0000000000000000 CR3: 000000006581e001 CR4: 00000000003606f0
> [    5.921482] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [    5.923032] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [    5.924642] Call Trace:
> [    5.925358]  __purge_vmap_area_lazy+0xd0/0x170
> [    5.926543]  _vm_unmap_aliases+0x1c6/0x200
> [    5.927498]  change_page_attr_set_clr+0xbc/0x2d0
> [    5.928540]  set_memory_nx+0x37/0x40
> [    5.929294]  free_init_pages+0x53/0x90
> [    5.930110]  free_kernel_image_pages+0x1f/0x40
> [    5.931064]  ? rest_init+0x24c/0x24c
> [    5.931832]  kernel_init+0x19/0x104
> [    5.932585]  ret_from_fork+0x3a/0x50
> [    5.933326] Modules linked in:
> [    5.934015] ---[ end trace 07dd6f9c635fabc2 ]---
> [    5.934992] RIP: 0010:__free_vmap_area+0x7b/0x340
> 
> The kernel config is attached. Let me know if you need any additional
> information.
> 
> Thanks,
> Andrei
Hello, Andrei.

I have some questions. Are you able to see the entire kernel log? I mean
what happened before 5.897542 time-stamp. Also, could you please provide
details how you run your KVM machine?

Thank you in advance!

--
Vlad Rezki

