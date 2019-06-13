Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9DEBC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:22:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BA2121473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:22:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="bBNgno4o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BA2121473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C01EB6B0006; Thu, 13 Jun 2019 09:22:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB1C26B000C; Thu, 13 Jun 2019 09:22:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A52E46B000E; Thu, 13 Jun 2019 09:22:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 849CC6B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:22:40 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h47so11696499qtc.20
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:22:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=RvQ7s6KqQFboNBrXACowYJehaEqJCBGaI4+3OVeMERI=;
        b=goGe+4uEDzFEQm0hz/21zOg6kkVCltpvVAYlJd8TSwX1MHIi0Wb9G+radffU8GnreZ
         QwbfxgFfogdHrx1BrLS4joQmdyKsBmrD+NXYiYWqi6i5W0494QdHceYdm5lGSpUKAd8U
         5dPFO/GCqin1uUTPBgPI5LpMS8jJbdD3oxlpS4wJ5p5PrxAOC7Co4rcWyeZ2vVQ4Im7X
         f/FASIxhB9Z46WfPZpBz/r9RCfsWwOI92VUranJQRRjrN6Jn+PdQ73OUHwuevMzNayfD
         dYP85APW9O3r/1Ux97CG6nOyBSvE305+1LzgxI87AGitumJwK8U+m4aY6jfP7TvIRXQX
         nfew==
X-Gm-Message-State: APjAAAWCVnMuk/bsrJU+w7T8vLLiyGn6ykrkK761QY+rGUBx4qiszjqR
	fHpe3nLmttAJqi5+ALso1Y1PTqaS3ZD4O94EyKBGDqcJhU2QtudGbueYC07WAlmVxmaSNAPbCk/
	0+7ETEI8CsljQ/UsYQ5JfAgifDKXzHj9hh8/xSRUKsz9MIev7ZjQ9/fqxlXR2ix1LCg==
X-Received: by 2002:a0c:ed31:: with SMTP id u17mr3548311qvq.107.1560432160274;
        Thu, 13 Jun 2019 06:22:40 -0700 (PDT)
X-Received: by 2002:a0c:ed31:: with SMTP id u17mr3548236qvq.107.1560432159367;
        Thu, 13 Jun 2019 06:22:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560432159; cv=none;
        d=google.com; s=arc-20160816;
        b=t1TzY3i/2OG2YOQS+pNa1aT4X1Vo/H31mrppnN11bhoZ/9lZG0uQdc23S7tVm48wDj
         D3KP/HM9F2pYPskY31mb3LhRUq3g2IqqLDLpzizjhhMfgzYPo+JY/O0xbDzRHDO0LrCO
         qIxDdH8IZdJJY4LiAuu/iKjX8rAtjboUpFv1F6pXn8YGJsOrxiqIB8eQV1VEyXHJJss+
         wY8qoXKpStLbngbpkxA2qU2Sre+wSXNgdWjYCqi0l4Q0ZSCClty/xVote9wdAeLGOK/F
         WdcUGFV00S4jL9979634uhDbnEH6KRRR4xfCB/EwRKLi8PScmpol2yQ9bZnJNlk9DJGO
         1CDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=RvQ7s6KqQFboNBrXACowYJehaEqJCBGaI4+3OVeMERI=;
        b=FrolieUJ/mJ8lhpZzzhceJx2gJSJXOwYhFOrHFZqk/397M3/T3t1uBdKhvCth61cwl
         a43DaegypsEoje/mlVPSqIWiGwf20SFTtM24mPjVFtoACJ+v+CRABWa6oKtx0McHs8UC
         Bs5qpdUAZra7R0S9s7Z6fmJfjqhq2xSQ8kvvT25xG7I8/XS9cwI0d/m1BM7zQd0tgAt1
         zDcOjYhDAE+lp+tB+C5GYium7uqJa9EtNyMByfu9LK+qLeW6Th4gIYhpJcHq8529h9Jq
         g1F2kDBWfE/kOjSpHMy3DbcYUQKluYFL7lVRQuM3IRUyA9zhv6pvmsLDtxwsRBre/2+y
         mX7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=bBNgno4o;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g67sor1638485qkb.95.2019.06.13.06.22.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 06:22:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=bBNgno4o;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=RvQ7s6KqQFboNBrXACowYJehaEqJCBGaI4+3OVeMERI=;
        b=bBNgno4o9GAsUM3oGJioC5sI7aRIso2DiB+okxiU8rjGN4HJ0v1gxCNMi7udkAGL6f
         oky91oVZh7z6knKRvgJl9IikO9fYnZb3jWcg1ZNvsauYAOjk0zxqs7/D+G+mWwOQwvi5
         XAEFmebepC8uobYYn6F6j3a1ccrCPMqRs6NImFil6YZeSfTI0Yunqha+8AmBT4bPOMrq
         uta0iARaSykyvjwOQfIWg6pltLH3IEX2UrTqThwQMVGM6Fbs4UncTG6BzJSoXCLm0n7w
         kk42c1Hsa+EHGKm3zEtga8Aae3Cdyj5QWiVaxE58eV4dWzuC7FmEvF7H7iUOL7yA11ah
         k7JQ==
X-Google-Smtp-Source: APXvYqxBFU+2n7NeM2FTrwHp7MWYv4DOOcIQv0wH6sniaZCois+k70ecIkcp7EZJ319MIspcW/P2rg==
X-Received: by 2002:a37:9885:: with SMTP id a127mr50858690qke.230.1560432158880;
        Thu, 13 Jun 2019 06:22:38 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 77sm1564782qkd.59.2019.06.13.06.22.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 06:22:38 -0700 (PDT)
Message-ID: <1560432156.5154.11.camel@lca.pw>
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
From: Qian Cai <cai@lca.pw>
To: Mike Rapoport <rppt@linux.ibm.com>, Mark Rutland <mark.rutland@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, akpm@linux-foundation.org, Roman
 Gushchin <guro@fb.com>, catalin.marinas@arm.com,
 linux-kernel@vger.kernel.org, mhocko@kernel.org,  linux-mm@kvack.org,
 vdavydov.dev@gmail.com, hannes@cmpxchg.org,  cgroups@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
Date: Thu, 13 Jun 2019 09:22:36 -0400
In-Reply-To: <20190613121100.GB25164@rapoport-lnx>
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
	 <20190604142338.GC24467@lakrids.cambridge.arm.com>
	 <20190610114326.GF15979@fuggles.cambridge.arm.com>
	 <1560187575.6132.70.camel@lca.pw>
	 <20190611100348.GB26409@lakrids.cambridge.arm.com>
	 <20190613121100.GB25164@rapoport-lnx>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-06-13 at 15:11 +0300, Mike Rapoport wrote:
> The log Qian Cai posted at [1] and partially cited below confirms that the
> failure happens when *user* PGDs are allocated and the addition of
> __GFP_ACCOUNT to gfp flags used by pgd_alloc() only uncovered another
> issue.
> 
> I'm still failing to reproduce it with qemu and I'm not really familiar
> with slub/memcg code to say anything smart about it. Will keep looking.
> 
> Note, that as failures start way after efi_virtmap_init() that allocates a
> PGD for efi_mm, there are no real fixes required for the original series,
> except that the check for mm == &init_mm I copied for some reason from
> powerpc is bogus and can be removed.

Yes, there is more places are not happy with __GFP_ACCOUNT other than efi_mm.
For example,

[  132.786842][ T1501] kobject_add_internal failed for pgd_cache(49:systemd-
udevd.service) (error: -2 parent: cgroup)
[  132.795589][ T1889] CPU: 9 PID: 1889 Comm: systemd-udevd Tainted:
G        W         5.2.0-rc4-next-20190613+ #8
[  132.807356][ T1889] Hardware name: HPE Apollo
70             /C01_APACHE_MB         , BIOS L50_5.13_1.0.9 03/01/2019
[  132.817872][ T1889] Call trace:
[  132.821017][ T1889]  dump_backtrace+0x0/0x268
[  132.825372][ T1889]  show_stack+0x20/0x2c
[  132.829380][ T1889]  dump_stack+0xb4/0x108
[  132.833475][ T1889]  pgd_alloc+0x34/0x5c
[  132.837396][ T1889]  mm_init+0x27c/0x32c
[  132.841315][ T1889]  dup_mm+0x84/0x7b4
[  132.845061][ T1889]  copy_process+0xf20/0x24cc
[  132.849500][ T1889]  _do_fork+0xa4/0x66c
[  132.853420][ T1889]  __arm64_sys_clone+0x114/0x1b4
[  132.858208][ T1889]  el0_svc_handler+0x198/0x260
[  132.862821][ T1889]  el0_svc+0x8/0xc

> 
> I surely can add pgd_alloc_kernel() to be used by the EFI code to make sure
> we won't run into issues with memcg in the future.
> 
> [   82.125966] Freeing unused kernel memory: 28672K
> [   87.940365] Checked W+X mappings: passed, no W+X pages found
> [   87.946769] Run /init as init process
> [   88.040040] systemd[1]: System time before build time, advancing clock.
> [   88.054593] systemd[1]: Failed to insert module 'autofs4': No such file or
> directory
> [   88.374129] modprobe (1726) used greatest stack depth: 28464 bytes left
> [   88.470108] systemd[1]: systemd 239 running in system mode. (+PAM +AUDIT
> +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT
> +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2
> default-hierarchy=legacy)
> [   88.498398] systemd[1]: Detected architecture arm64.
> [   88.506517] systemd[1]: Running in initial RAM disk.
> [   89.621995] mkdir (1730) used greatest stack depth: 27872 bytes left
> [   90.222658] random: systemd: uninitialized urandom read (16 bytes read)
> [   90.230072] systemd[1]: Reached target Swap.
> [   90.240205] random: systemd: uninitialized urandom read (16 bytes read)
> [   90.251088] systemd[1]: Reached target Timers.
> [   90.261303] random: systemd: uninitialized urandom read (16 bytes read)
> [   90.271209] systemd[1]: Listening on udev Control Socket.
> [   90.283238] systemd[1]: Reached target Local File Systems.
> [   90.296232] systemd[1]: Reached target Slices.
> [   90.307239] systemd[1]: Listening on udev Kernel Socket.
> [   90.608597] kobject_add_internal failed for pgd_cache(13:init.scope)
> (error: -2 parent: cgroup)
> [   90.678007] kobject_add_internal failed for pgd_cache(13:init.scope)(error:
> -2 parent: cgroup)
> [   90.713260] kobject_add_internal failed for pgd_cache(21:systemd-tmpfiles-
> setup.service) (error: -2 parent: cgroup)
> [   90.820012] systemd-tmpfile (1759) used greatest stack depth: 27184 bytes
> left
> [   90.861942] kobject_add_internal failed for pgd_cache(13:init.scope) error:
> -2 parent: cgroup)
>  
> > Thanks,
> > Mark.
> > 
> 
> [1] https://cailca.github.io/files/dmesg.txt
> 

