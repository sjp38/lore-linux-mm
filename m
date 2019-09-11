Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3C99ECDE27
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:10:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B63B6222C0
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 07:10:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B63B6222C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 481816B0006; Wed, 11 Sep 2019 03:10:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 458EF6B0007; Wed, 11 Sep 2019 03:10:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36EE16B0008; Wed, 11 Sep 2019 03:10:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0165.hostedemail.com [216.40.44.165])
	by kanga.kvack.org (Postfix) with ESMTP id 13FB16B0006
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 03:10:26 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 61F71181AC9CB
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:25 +0000 (UTC)
X-FDA: 75921766410.27.trees05_77f1a947a0612
X-HE-Tag: trees05_77f1a947a0612
X-Filterd-Recvd-Size: 6527
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:24 +0000 (UTC)
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DAE9E7BDD1
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:10:22 +0000 (UTC)
Received: by mail-pf1-f199.google.com with SMTP id f2so15009393pfk.13
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 00:10:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Z6bU0DABfNT+bNkpJjwoTv7ZeQvLLitBOUD6BWG7TU8=;
        b=fsnfiqljKBPVE00W0lGNB2sy4zQWGn6n99QIDyLz+RDQbEAQoYw1OWf/YE06W5SFYS
         sCUJhh/M6qKoGz90pe7MFiesI8FYUmxWG8FCKkgWiRwWIVUgjWoC9oy4v5lbVKK4/YAM
         5i7V6tgjW8hcd/dqYj6P+2O+CZAjbmOz9yqv3b4m9m94xUHeXhsivvB2UJbIQ+IQtUq/
         RZg+yJb9ZOloY5SoklkyRgtfee2DGK4ywqTPvH0LY4sxpR3C5MTmzasc44OrjvK577Dv
         1XvFZTZreCq8Z+4UPeH43JZxpTGqX3BNvTm6GW8ru18GXg7iSL5R82r0vSiubqL6lhIH
         A3xw==
X-Gm-Message-State: APjAAAXPaM5V2Ig0G7UEhhCPk60shxRyp3xCGU0P3iBgo0Gwht4QUMgU
	fTBHyTn8QmNUb74mHQ6IfmyMPNByw4fJyDhtKjr+pHn+laEkcsJWO1kVyCmYAt7gyOHhQlEEtoM
	B7xN7C/vv9bI=
X-Received: by 2002:a63:4a51:: with SMTP id j17mr31549988pgl.284.1568185821863;
        Wed, 11 Sep 2019 00:10:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyx76ttPQ3MnRNAef1miRs8CQvNZFBrwVZL+gMCq3ehAAxKzSGX55Rh3xVKkY+K8a4Dqpyy8Q==
X-Received: by 2002:a63:4a51:: with SMTP id j17mr31549958pgl.284.1568185821499;
        Wed, 11 Sep 2019 00:10:21 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id j10sm1573091pjn.3.2019.09.11.00.10.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Sep 2019 00:10:20 -0700 (PDT)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 0/7] mm: Page fault enhancements
Date: Wed, 11 Sep 2019 15:10:00 +0800
Message-Id: <20190911071007.20077-1-peterx@redhat.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

v3:
- check fatal signals in __get_user_page_locked() [Linus]
- add r-bs

v2:
- resent previous version, rebase only

This series is split out of userfaultfd-wp series to only cover the
general page fault changes, since it seems to make sense itself.

Basically it does two things:

  (a) Allows the page fault handlers to be more interactive on not
      only SIGKILL, but also the rest of userspace signals (especially
      for user-mode faults), and,

  (b) Allows the page fault retry (VM_FAULT_RETRY) to happen for more
      than once.

I'm keeping the CC list as in uffd-wp v5, hopefully I'm not sending
too much spams...

And, instead of writting again the cover letter, I'm just copy-pasting
my previous link here which has more details on why we do this:

  https://patchwork.kernel.org/cover/10691991/

The major change from that latest version should be that we introduced
a new page fault flag FAULT_FLAG_INTERRUPTIBLE as suggested by Linus
[1] to represents that we would like the fault handler to respond to
non-fatal signals.  Also, we're more careful now on when to do the
immediate return of the page fault for such signals.  For example, now
we'll only check against signal_pending() for user-mode page faults
and we keep the kernel-mode page fault patch untouched for it.  More
information can be found in separate patches.

The patchset is only lightly tested on x86.

All comments are greatly welcomed.  Thanks,

[1] https://lkml.org/lkml/2019/6/25/1382

Peter Xu (7):
  mm/gup: Rename "nonblocking" to "locked" where proper
  mm: Introduce FAULT_FLAG_DEFAULT
  mm: Introduce FAULT_FLAG_INTERRUPTIBLE
  mm: Return faster for non-fatal signals in user mode faults
  userfaultfd: Don't retake mmap_sem to emulate NOPAGE
  mm: Allow VM_FAULT_RETRY for multiple times
  mm/gup: Allow VM_FAULT_RETRY for multiple times

 arch/alpha/mm/fault.c           |  7 +--
 arch/arc/mm/fault.c             |  8 +++-
 arch/arm/mm/fault.c             | 14 +++---
 arch/arm64/mm/fault.c           | 16 +++----
 arch/hexagon/mm/vm_fault.c      |  6 +--
 arch/ia64/mm/fault.c            |  6 +--
 arch/m68k/mm/fault.c            | 10 ++--
 arch/microblaze/mm/fault.c      |  6 +--
 arch/mips/mm/fault.c            |  6 +--
 arch/nds32/mm/fault.c           | 12 ++---
 arch/nios2/mm/fault.c           |  8 ++--
 arch/openrisc/mm/fault.c        |  6 +--
 arch/parisc/mm/fault.c          |  9 ++--
 arch/powerpc/mm/fault.c         | 10 ++--
 arch/riscv/mm/fault.c           | 12 ++---
 arch/s390/mm/fault.c            | 11 ++---
 arch/sh/mm/fault.c              |  7 ++-
 arch/sparc/mm/fault_32.c        |  5 +-
 arch/sparc/mm/fault_64.c        |  6 +--
 arch/um/kernel/trap.c           |  7 +--
 arch/unicore32/mm/fault.c       | 11 ++---
 arch/x86/mm/fault.c             |  6 +--
 arch/xtensa/mm/fault.c          |  6 +--
 drivers/gpu/drm/ttm/ttm_bo_vm.c | 12 +++--
 fs/userfaultfd.c                | 28 +-----------
 include/linux/mm.h              | 81 +++++++++++++++++++++++++++++----
 include/linux/sched/signal.h    | 12 +++++
 mm/filemap.c                    |  2 +-
 mm/gup.c                        | 69 ++++++++++++++++------------
 mm/hugetlb.c                    | 14 +++---
 mm/shmem.c                      |  2 +-
 31 files changed, 234 insertions(+), 181 deletions(-)

--=20
2.21.0


