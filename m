Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CE3DC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53ADA218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="JU3sdhxL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53ADA218DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE6AD6B0005; Mon,  9 Sep 2019 14:12:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D97D16B0006; Mon,  9 Sep 2019 14:12:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C85F56B0007; Mon,  9 Sep 2019 14:12:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0192.hostedemail.com [216.40.44.192])
	by kanga.kvack.org (Postfix) with ESMTP id A4C116B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:25 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 5609C641D
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:25 +0000 (UTC)
X-FDA: 75916177050.01.rod46_6c62b23d42f21
X-HE-Tag: rod46_6c62b23d42f21
X-Filterd-Recvd-Size: 8547
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:24 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id g13so16863336qtj.4
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=bHW6yWQ7UW+zE64/WnOR0Njpl5GgnEnN/6DGhYBHVKU=;
        b=JU3sdhxLJfxvSVBs3bFdU2e4zLi8oAmSQDOExSf/O4iwr/3/8XkTrTYiJAME9KMSqq
         g95sXFHrej2UYw7bd0AxF56vJamNB+gtzsZnv0LaU8Wr325f811eQzeQCAEiut+kvxiL
         83v4KQgVt6omgbqgIQ3ocINWrA9ndgIQGDQO4c5bZOWVbJ+ek7o/OgNS37zB8aTjiGQw
         aWOsWdhwbkR30CynP/7acBvWe6RzMFhmYU2QfKX/uWYIjwOzp4BW7WcfaV8c+DQ8pK2K
         5EImhK5mvI4RBh+A1rWDEFtE3zROb4tT5Dm473Zeal2lS0t0rltfiOcLtNMqp0v5bHWB
         IGOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=bHW6yWQ7UW+zE64/WnOR0Njpl5GgnEnN/6DGhYBHVKU=;
        b=aA9ZmA/aZKlwOJVTdSSvpboENem5JKFUlSiq0dXDXV/lnFfwYZ8EIp4vPuQV4pPxS0
         EW0lyHN80Ht3PMbW/hQbQYgrJnoo5qUG4etgS0Y+UvfqLEwZZsfOX5nUp82vcuxCqoBu
         8ExXTZOsw/pGZUt985TMDJsPhndqJfTWtLFk1MHBo8FpNri/IDUNOwM/1QIl6nWYDUOU
         kFzozekjFXKoALPGLkFiJj9AxmWXcmr/n04SfvS+laRSQDkPw4UvWMWWtBXL27NepWRP
         nFMrr9IJe5CL8ureRlRrCBLabNkorjqZ/eIFIYWCnOTd7ppi7SaFQig4ZEzk7B0I4mvm
         YJaA==
X-Gm-Message-State: APjAAAWJv3Ki65NpVBLDK+cabeWzKYUV+vRth2L9VBwdeQ1T4h2RTmI3
	SZ4Cp4Hhbu67In/1W80epVPyRg==
X-Google-Smtp-Source: APXvYqxG+TIFdHDE4E3CtIW89ZhOmN9Ul0/qBQpcK8s8bWc+75DnjRjIbii0jaXyV2uFOZAwnh6oJQ==
X-Received: by 2002:ac8:6684:: with SMTP id d4mr24552690qtp.286.1568052744047;
        Mon, 09 Sep 2019 11:12:24 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:23 -0700 (PDT)
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
Subject: [PATCH v4 00/17] arm64: MMU enabled kexec relocation
Date: Mon,  9 Sep 2019 14:12:04 -0400
Message-Id: <20190909181221.309510-1-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changelog:
v4:
	- Addressed comments from James Morse.
	- Split "check pgd table allocation" into two patches, and moved to
	  the beginning of series  for simpler backport of the fixes.
	  Added "Fixes:" tags to commit logs.
	- Changed "arm64, hibernate:" to "arm64: hibernate:"
	- Added Reviewed-by's
	- Moved "add PUD_SECT_RDONLY" earlier in series to be with other
	  clean-ups
	- Added "Derived from:" to arch/arm64/mm/trans_pgd.c
	- Removed "flags" from trans_info
	- Changed .trans_alloc_page assumption to return zeroed page.
	- Simplify changes to trans_pgd_map_page(), by keeping the old
	  code.
	- Simplify changes to trans_pgd_create_copy, by keeping the old
	  code.
	- Removed: "add trans_pgd_create_empty"
	- replace init_mm with NULL, and keep using non "__" version of
	  populate functions.
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
https://lore.kernel.org/lkml/20190821183204.23576-1-pasha.tatashin@soleen=
.com/
version 3 of this series

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
  arm64: hibernate: pass the allocated pgdp to ttbr0
  arm64: hibernate: check pgd table allocation
  arm64: hibernate: use get_safe_page directly
  arm64: hibernate: remove gotos in create_safe_exec_page
  arm64: hibernate: rename dst to page in create_safe_exec_page
  arm64: hibernate: add PUD_SECT_RDONLY
  arm64: hibernate: add trans_pgd public functions
  arm64: hibernate: move page handling function to new trans_pgd.c
  arm64: trans_pgd: make trans_pgd_map_page generic
  arm64: trans_pgd: pass allocator trans_pgd_create_copy
  arm64: trans_pgd: pass NULL instead of init_mm to *_populate functions
  kexec: add machine_kexec_post_load()
  arm64: kexec: move relocation function setup and clean up
  arm64: kexec: add expandable argument to relocation function
  arm64: kexec: configure trans_pgd page table for kexec
  arm64: kexec: enable MMU during kexec relocation

 arch/arm64/Kconfig                     |   4 +
 arch/arm64/include/asm/kexec.h         |  51 +++++-
 arch/arm64/include/asm/pgtable-hwdef.h |   1 +
 arch/arm64/include/asm/trans_pgd.h     |  43 +++++
 arch/arm64/kernel/asm-offsets.c        |  14 ++
 arch/arm64/kernel/cpu-reset.S          |   4 +-
 arch/arm64/kernel/cpu-reset.h          |   8 +-
 arch/arm64/kernel/hibernate.c          | 239 ++++---------------------
 arch/arm64/kernel/machine_kexec.c      | 195 ++++++++++++++++----
 arch/arm64/kernel/relocate_kernel.S    | 196 ++++++++++----------
 arch/arm64/mm/Makefile                 |   1 +
 arch/arm64/mm/trans_pgd.c              | 225 +++++++++++++++++++++++
 kernel/kexec.c                         |   4 +
 kernel/kexec_core.c                    |   8 +-
 kernel/kexec_file.c                    |   4 +
 kernel/kexec_internal.h                |   2 +
 16 files changed, 658 insertions(+), 341 deletions(-)
 create mode 100644 arch/arm64/include/asm/trans_pgd.h
 create mode 100644 arch/arm64/mm/trans_pgd.c

--=20
2.23.0


