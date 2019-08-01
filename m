Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25B73C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:24:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE0522087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:24:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="atLlsRo/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE0522087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 595DA8E0022; Thu,  1 Aug 2019 11:24:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51F3D8E0001; Thu,  1 Aug 2019 11:24:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BED28E0022; Thu,  1 Aug 2019 11:24:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1715C8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 11:24:44 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c207so61478059qkb.11
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 08:24:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :mime-version:content-transfer-encoding;
        bh=Tv/fOnD6YC9u+5WmWm5gwywTsIsmHeTM0Q1GSWNKYUk=;
        b=TjC9J+pEuPVQCk/y0bfnAmk2hI6HroTxyaLgYD8tOGAMDE9UI2PTkYQS1bjrCvF2aM
         N+r7y9MYKP9H1TgP049xTgE//IRbGmsGWkkfnkCb+gPYkxiEjxB4RCwD9Dega25/Twux
         0LpAzlgHSkAZ8Oqm4hIjlMztEDyJUyjbZwFP/kBPWEJcTG4zlIMoe7rW6dnysg5ruouB
         9de4m0sktzYXEZU19N1hveHtQRkIlnjN8CoTVHPlkhDV04C5XFJEreG7h/7rVC18UPfS
         OemLJMLnGtOFLZ+z9rSR80oUts61jFgURhFfM3MiPOgsq96zeT7NYmpl2jHD/QSVLT/O
         xMVQ==
X-Gm-Message-State: APjAAAWgyFvvMr7wWK5gRr2uKmjw4umq4gLj7OSKMmKz8RU8LnqOwth9
	/oSRtqJnOZZsKF964XY1YyedGEUGIPQ7W9DZZi9ST0X+vY8DZZYeGnGSKzOtPtQyhdfTJPR9HNV
	B1jJhwKEcDnYJ3p4wA/Ph1fsD9zM9XdmLeP6eIAC2y16pBlLMCW6Y9eL0EDoKFLdvaA==
X-Received: by 2002:ac8:341d:: with SMTP id u29mr87019636qtb.320.1564673083820;
        Thu, 01 Aug 2019 08:24:43 -0700 (PDT)
X-Received: by 2002:ac8:341d:: with SMTP id u29mr87019535qtb.320.1564673082436;
        Thu, 01 Aug 2019 08:24:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564673082; cv=none;
        d=google.com; s=arc-20160816;
        b=vGIZuxai4JRiLzopXXQGvUr2zEMFqs5b/WIykkcWg6u7/8nXxQdfOeFKtZ4F0Batkr
         FfNDNQckKkdCocWu+i6+i/J4TcPR9uShw3+e+0Ss+LNh+wxT9+K0s2RRBjS0Ds5QJUzR
         ixkVbI25ycV0zFML6KSFI0E28oFXreeW4YhnYUnXFpudscOH76dohw2YIVidOkWk5elI
         v5dq3FlYClCyl5zQnGAvMk1g7IQIN2pISr9Q9K1L2WN2Ju7V/ZPFkcSL5dLOebfpDVS7
         3dxQvG/GiW9ZmxFqNR0ZJEyV/iEPQfg7q0UTVNxBpfOi3Kvfn7+5RJv/Jj+t2W+8gpPN
         weTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:dkim-signature;
        bh=Tv/fOnD6YC9u+5WmWm5gwywTsIsmHeTM0Q1GSWNKYUk=;
        b=n/A/hf4nknOFhKuXdINHv0X9Eu2S045a68HL+jxyALNoHQafZmSH79x5T1vaWNGF+K
         ISuCZPTQCXa3zSjjpiC0o/HUMq4XqqYVg1imypCY9p1pKLJRX92SoUkc84xR+9TruT6+
         R0ys/CbA8avn+1Q82+MDdngeCyuQPbkryx9Bezajwd1oaiu3VH7BMNCzyUr6//hhpbWC
         8Pfl+Q+e9owpSbawlrbnqdZp9ylmoAyPPMbNH5A4hlXjWyLO7heaCzoeihisLXaNdJOn
         INJO8tXJX9/b100a142I2FndrKLNa8idz9/x/ZHpNZzEYou3mjVEj3zJljpVgDlhma9c
         xhHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="atLlsRo/";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor40337844qkj.8.2019.08.01.08.24.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 08:24:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="atLlsRo/";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Tv/fOnD6YC9u+5WmWm5gwywTsIsmHeTM0Q1GSWNKYUk=;
        b=atLlsRo/HsLlYJHkAHesgcO9qfPaQjZk+gYOvxKZpX5zmCTxt7zu8tiCRhoteNN7dd
         6HAmzBsFnGGSMNK2C1/2c095tMDLJ4ZXLXLn7i+ZEgdYwpo1qYHK/Q1xRHZwxOfakJw6
         /7ct9TY6fVLVY5D3c86/4ePweUPMk5TKNh2ZI97gVVKUkfE3dvmvGGH5WFhqRYhDDdNj
         MN0U1s86suOZc/o8BsUsL3OJ8/tYd9JgVijBxGQUq2ZZTq5MshwLKDUEHOPwOnM0CjpD
         UlAySrOA8+Uey1c7x2oPbu2GeSyZevsm2xsSMvkzV3E2NKwjBTx9zLYFJGZQjyw6+Y/3
         BOhA==
X-Google-Smtp-Source: APXvYqzZD3a7tT1okA0boG+U3Hsp3SOLhKzDGE1jT3CDvSGW9wPow4/sMDwhXS8im+A6DBmuvHqQWA==
X-Received: by 2002:a37:4dc6:: with SMTP id a189mr84646858qkb.41.1564673081928;
        Thu, 01 Aug 2019 08:24:41 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o5sm30899952qkf.10.2019.08.01.08.24.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 08:24:41 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org
Subject: [PATCH v1 0/8] arm64: MMU enabled kexec relocation
Date: Thu,  1 Aug 2019 11:24:31 -0400
Message-Id: <20190801152439.11363-1-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Enable MMU during kexec relocation in order to improve reboot performance.

If kexec functionality is used for a fast system update, with a minimal
downtime, the relocation of kernel + initramfs takes a significant portion
of reboot.

The reason for slow relocation is because it is done without MMU, and thus
not benefiting from D-Cache.

Performance data
----------------
For this experiment, the size of kernel plus initramfs is small, only 25M.
If initramfs was larger, than the improvements would be greater, as time
spent in relocation is proportional to the size of relocation.

Previously:
kernel shutdown	0.022131328s
relocation	0.440510736s
kernel startup	0.294706768s

Relocation was taking: 58.2% of reboot time

Now:
kernel shutdown	0.032066576s
relocation	0.022158152s
kernel startup	0.296055880s

Now: Relocation takes 6.3% of reboot time

Total reboot is x2.16 times faster.

Previous approaches and discussions
-----------------------------------
https://lore.kernel.org/lkml/20190709182014.16052-1-pasha.tatashin@soleen.com
reserve space for kexec to avoid relocation, involves changes to generic code
to optimize a problem that exists on arm64 only:

https://lore.kernel.org/lkml/20190716165641.6990-1-pasha.tatashin@soleen.com
The first attempt to enable MMU, some bugs that prevented performance
improvement. The page tables unnecessary configured idmap for the whole
physical space.

https://lore.kernel.org/lkml/20190731153857.4045-1-pasha.tatashin@soleen.com
No linear copy, bug with EL2 reboots.

Pavel Tatashin (8):
  kexec: quiet down kexec reboot
  arm64, mm: transitional tables
  arm64: hibernate: switch to transtional page tables.
  kexec: add machine_kexec_post_load()
  arm64, kexec: move relocation function setup and clean up
  arm64, kexec: add expandable argument to relocation function
  arm64, kexec: configure transitional page table for kexec
  arm64, kexec: enable MMU during kexec relocation

 arch/arm64/Kconfig                     |   4 +
 arch/arm64/include/asm/kexec.h         |  51 ++++-
 arch/arm64/include/asm/pgtable-hwdef.h |   1 +
 arch/arm64/include/asm/trans_table.h   |  68 ++++++
 arch/arm64/kernel/asm-offsets.c        |  14 ++
 arch/arm64/kernel/cpu-reset.S          |   4 +-
 arch/arm64/kernel/cpu-reset.h          |   8 +-
 arch/arm64/kernel/hibernate.c          | 261 ++++++-----------------
 arch/arm64/kernel/machine_kexec.c      | 199 ++++++++++++++----
 arch/arm64/kernel/relocate_kernel.S    | 196 +++++++++---------
 arch/arm64/mm/Makefile                 |   1 +
 arch/arm64/mm/trans_table.c            | 273 +++++++++++++++++++++++++
 kernel/kexec.c                         |   4 +
 kernel/kexec_core.c                    |   8 +-
 kernel/kexec_file.c                    |   4 +
 kernel/kexec_internal.h                |   2 +
 16 files changed, 758 insertions(+), 340 deletions(-)
 create mode 100644 arch/arm64/include/asm/trans_table.h
 create mode 100644 arch/arm64/mm/trans_table.c

-- 
2.22.0

