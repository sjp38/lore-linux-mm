Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46F30C3A5AB
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1FE32184B
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 10:15:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1FE32184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5049C6B0279; Thu,  5 Sep 2019 06:15:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B4026B027A; Thu,  5 Sep 2019 06:15:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A2C36B027B; Thu,  5 Sep 2019 06:15:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0207.hostedemail.com [216.40.44.207])
	by kanga.kvack.org (Postfix) with ESMTP id 1317E6B0279
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 06:15:52 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A413D185D
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:15:51 +0000 (UTC)
X-FDA: 75900460902.17.glove14_5034fc06b1618
X-HE-Tag: glove14_5034fc06b1618
X-Filterd-Recvd-Size: 6448
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:15:51 +0000 (UTC)
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DD496C0578F8
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:15:49 +0000 (UTC)
Received: by mail-pf1-f199.google.com with SMTP id z23so1492615pfn.0
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 03:15:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=sGQuWQQe8fDlEhpLmREf75/mh3j/W3ajLyehA5owUl8=;
        b=HE1DuLhcHEJlK9atjWPInOsnT0WPh1T1k4Eo2CF0tWhgdoouPzE/mU+WXCYSkN+8yP
         eSYE4bHzR8qmotruLh00V1J1fXLnDrtWpVgr/JmZgFXR9h5ZkdxshrwFmXK5cCqNf8ud
         vA/7+oDbE7emH7oKqxAwG+ffq4UnlzJou3+CEkzfvzudo1Y0XJnj199Fp6O2J6mfcCCJ
         RaGzHy0fK3cv3xeMUAM4bu49FuWX5Q7ZOzPNgeHx6gmnTOBQJ4jRRkwvTJzNxxh1SNUQ
         9q6poPIO6fVRlraCNBRY722UUtqiTtrVred+utmN2hp77YB3LJchyrl0hbucExZ193CZ
         lTig==
X-Gm-Message-State: APjAAAVXQtfKUWiSTlOeQUXiu4yIi2ZpeCSBGkfC+aiJfr7AvRdmvKcd
	LwgDTQ3bbz1ta5Kb2ci2odYybHre/PqLZ4hU7KyAY5bPCjACoYUFX6qHOeJdbx4pM6CVZ/OTjgw
	6XV19xzIUd/k=
X-Received: by 2002:a17:902:8a81:: with SMTP id p1mr2465950plo.71.1567678549046;
        Thu, 05 Sep 2019 03:15:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgSRo4NDJ7ab9oov6zo1BxyCr5I28O4Qdk/qqHUJDnK0Sb3P39/6OhZUQ34zMdEKMPdKxa2A==
X-Received: by 2002:a17:902:8a81:: with SMTP id p1mr2465913plo.71.1567678548782;
        Thu, 05 Sep 2019 03:15:48 -0700 (PDT)
Received: from xz-x1.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id a20sm413852pfo.33.2019.09.05.03.15.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 03:15:48 -0700 (PDT)
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
Subject: [PATCH v2 0/7] mm: Page fault enhancements
Date: Thu,  5 Sep 2019 18:15:27 +0800
Message-Id: <20190905101534.9637-1-peterx@redhat.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
 mm/gup.c                        | 61 ++++++++++++++-----------
 mm/hugetlb.c                    | 14 +++---
 mm/shmem.c                      |  2 +-
 31 files changed, 227 insertions(+), 180 deletions(-)

--=20
2.21.0


