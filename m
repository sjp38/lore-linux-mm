Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9667FC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A9D522DD3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="HHJukI5c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A9D522DD3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E59C76B0008; Wed, 21 Aug 2019 14:32:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE4816B000A; Wed, 21 Aug 2019 14:32:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAA676B000C; Wed, 21 Aug 2019 14:32:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0178.hostedemail.com [216.40.44.178])
	by kanga.kvack.org (Postfix) with ESMTP id A336E6B0008
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:07 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 61F0499AC
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:07 +0000 (UTC)
X-FDA: 75847279494.30.verse22_2f96357c7852a
X-HE-Tag: verse22_2f96357c7852a
X-Filterd-Recvd-Size: 7603
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:06 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id u190so2736603qkh.5
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=3VISVZWuGNTiVd6JKqfbutJFN34lrqN05fvYPH9Kreg=;
        b=HHJukI5cKFcu78i/O1Yn8iw05mYEjKQotNnDCY7uW/VDROaso248Cz4QQVCEUqJcRv
         EBzDUyZOfUDX0OqfFfNYvmLzaOIniVyftuF2AgycrkM0czlodTpOiI5hsWSB3EmJ2IOF
         Sdf0QIF5vjVVnt5v/fb4faCNkExE0O0J9E/u7OrVqBv3KwAkDQY25mF4NF6uZGiJmJaq
         V5rSY+0126UdxSnVxgCpzdNP9IOeLPAdBIaRSaDqEYxUJRdmoxnf7zCcQdaMR1gPUppS
         eit1DPkEzoQPfq6qmFm0NeeZa9yVUmAjXHBjiWUl8i01GTKsv8qd8JE2lN5bdfa1Jkf4
         TRIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=3VISVZWuGNTiVd6JKqfbutJFN34lrqN05fvYPH9Kreg=;
        b=Y0N0BxXdNGjng/1myqfVBUrByjM1kjaDaKg5z1sImW5UmZinhdnjE/HE20nbgA7uWG
         QDU/51nPGgupczmHNf5yjBCSL9Vd3qqgQkeswXZFPRGuw8xdX+ptXmTTzfmaGDAv/GPz
         RmzKydWbJ3OF2+kdzDV1FvEhDh/yEMt9kBUIlLI7wQjffBYB3+ME+vTVeRUsdY8gRj7Y
         GxSB+1AXsdyBz+CKj4I2Kyjx5cA1VxPoiplP6QTEHQVSZLtac3FJk0G4gIcKqr5bGnzC
         GKDefr+6mApLjBgb3s0+al8/DtDi6AuITuYYAd3PNF7+S0int7WLM5mzkziG2PxGs6zh
         t40g==
X-Gm-Message-State: APjAAAVPg7rvwiG2GEEP5v4iY2DzMhNZwDDwivQ7dWtN8BABu1JQYjuX
	GoiNeg9o2Wa2ZOlCfFw1y0Wiew==
X-Google-Smtp-Source: APXvYqxQXpDqPyZwJQWEPUkusjd/UilDz4Mpzt+wUtcrvVVsDPsRqQ1Np6P1GcXQU3ssA/+pWMdUqw==
X-Received: by 2002:a37:a9c6:: with SMTP id s189mr32305161qke.191.1566412326277;
        Wed, 21 Aug 2019 11:32:06 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:05 -0700 (PDT)
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
	linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: [PATCH v3 00/17] arm64: MMU enabled kexec relocation
Date: Wed, 21 Aug 2019 14:31:47 -0400
Message-Id: <20190821183204.23576-1-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changelog:
v3:
	- Split changes to create_safe_exec_page() into several patches for
	  easier review as request by Mark Rutland. This is why this series
	  has 3 more patches.
	- Renamed trans_table to tans_pgd as agreed with Mark. The header
	  comment in trans_pgd.c explains that trans stands for
	  transitional page tables. Meaning they are used in transition
	  between two kernels.
v2:
	- Fixed hibernate bug reported by James Morse
	- Addressed comments from James Morse:
	  * More incremental changes to trans_table
	  * Removed TRANS_FORCEMAP
	  * Added kexec reboot data for image with 380M in size.

Enable MMU during kexec relocation in order to improve reboot performance=
.

If kexec functionality is used for a fast system update, with a minimal
downtime, the relocation of kernel + initramfs takes a significant portio=
n
of reboot.

The reason for slow relocation is because it is done without MMU, and thu=
s
not benefiting from D-Cache.

Performance data
----------------
For this experiment, the size of kernel plus initramfs is small, only 25M=
.
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

With bigger userland (fitImage 380M), the reboot time is improved by 3.57=
s,
and is reduced from 3.9s down to 0.33s

Previous approaches and discussions
-----------------------------------
https://lore.kernel.org/lkml/20190817024629.26611-1-pasha.tatashin@soleen=
.com
version 2 of this series

https://lore.kernel.org/lkml/20190801152439.11363-1-pasha.tatashin@soleen=
.com
version 1 of this series

https://lore.kernel.org/lkml/20190709182014.16052-1-pasha.tatashin@soleen=
.com
reserve space for kexec to avoid relocation, involves changes to generic =
code
to optimize a problem that exists on arm64 only:

https://lore.kernel.org/lkml/20190716165641.6990-1-pasha.tatashin@soleen.=
com
The first attempt to enable MMU, some bugs that prevented performance
improvement. The page tables unnecessary configured idmap for the whole
physical space.

https://lore.kernel.org/lkml/20190731153857.4045-1-pasha.tatashin@soleen.=
com
No linear copy, bug with EL2 reboots.

Pavel Tatashin (17):
  kexec: quiet down kexec reboot
  arm64, hibernate: use get_safe_page directly
  arm64, hibernate: remove gotos in create_safe_exec_page
  arm64, hibernate: rename dst to page in create_safe_exec_page
  arm64, hibernate: check pgd table allocation
  arm64, hibernate: add trans_pgd public functions
  arm64, hibernate: move page handling function to new trans_pgd.c
  arm64, trans_pgd: make trans_pgd_map_page generic
  arm64, trans_pgd: add trans_pgd_create_empty
  arm64, trans_pgd: adjust trans_pgd_create_copy interface
  arm64, trans_pgd: add PUD_SECT_RDONLY
  arm64, trans_pgd: complete generalization of trans_pgds
  kexec: add machine_kexec_post_load()
  arm64, kexec: move relocation function setup and clean up
  arm64, kexec: add expandable argument to relocation function
  arm64, kexec: configure trans_pgd page table for kexec
  arm64, kexec: enable MMU during kexec relocation

 arch/arm64/Kconfig                     |   4 +
 arch/arm64/include/asm/kexec.h         |  51 ++++-
 arch/arm64/include/asm/pgtable-hwdef.h |   1 +
 arch/arm64/include/asm/trans_pgd.h     |  63 ++++++
 arch/arm64/kernel/asm-offsets.c        |  14 ++
 arch/arm64/kernel/cpu-reset.S          |   4 +-
 arch/arm64/kernel/cpu-reset.h          |   8 +-
 arch/arm64/kernel/hibernate.c          | 261 ++++++------------------
 arch/arm64/kernel/machine_kexec.c      | 199 ++++++++++++++----
 arch/arm64/kernel/relocate_kernel.S    | 196 +++++++++---------
 arch/arm64/mm/Makefile                 |   1 +
 arch/arm64/mm/trans_pgd.c              | 270 +++++++++++++++++++++++++
 kernel/kexec.c                         |   4 +
 kernel/kexec_core.c                    |   8 +-
 kernel/kexec_file.c                    |   4 +
 kernel/kexec_internal.h                |   2 +
 16 files changed, 750 insertions(+), 340 deletions(-)
 create mode 100644 arch/arm64/include/asm/trans_pgd.h
 create mode 100644 arch/arm64/mm/trans_pgd.c

--=20
2.23.0


