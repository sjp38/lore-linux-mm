Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DCE8C10F0C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:37:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 368422084D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:37:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 368422084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83C958E000D; Mon, 11 Mar 2019 05:37:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C3A58E0002; Mon, 11 Mar 2019 05:37:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B2838E000D; Mon, 11 Mar 2019 05:37:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7AD8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 05:37:17 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id i21so4690942qtq.6
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 02:37:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=uJR3aci6bbnfD795Is+jjZ7l7Ym+8Hk3SK4jeuHuseA=;
        b=eQpeehKzBTmysRwItE6sDKr5vyUpdUuElaiPlqq5KBx+o3lSGHxZnx+KHPhHC4JmJK
         lQDmhSgX3tcs2CwLOs7Ho1K96fp++TAEaC8nedGWRLaCfN7Qtom0msJGWgtSNLDrSXLw
         qzLYU8Ch59r/GR9WMOBYYcndbYfGGtHlUGd7EZYTQQsxaH5BqPPd6XEQIrz54yn4tU60
         /FudnlDkjhaA/MgIFcqDQw2A559tA3+uKAoKkAIBe7afJ4lfVTnLf/P4lHxlI7Zp5tOU
         dKd209oKUbzqKhiztfb2nGLAlx+DQFVOOgOo1Eie9jcIGb5nZx9g6zmzPuLpM/CZktD/
         YbuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWQL1n2/8hfeWHomMG7KhzLpg9A3hKkV9c+xOxbTJcBjkXK4np8
	tbO9IUK7xghKiHQrFSKAhKJJpULtCqFRFeKvtUAIoYKcw647xgbjGVWIntLR1jp7vPw/yBr5TpT
	6/KmEXzAzdh+zHN+PB81HvIKZb7rn7ZywIuBxyKw33DwEvZd3d4a94vnZscifNGBf3Q==
X-Received: by 2002:a0c:fa92:: with SMTP id o18mr5899565qvn.81.1552297036992;
        Mon, 11 Mar 2019 02:37:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1R6mtilvzIBBvncE5xz7rFAM9WICau3N6f4iLlBSml3kKObdZ5Fn+QGevo1Rt52B03BJz
X-Received: by 2002:a0c:fa92:: with SMTP id o18mr5899542qvn.81.1552297036301;
        Mon, 11 Mar 2019 02:37:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552297036; cv=none;
        d=google.com; s=arc-20160816;
        b=otq6YwqpoWhLGWzGI1HV6VD7DC83tyr1Kzi8fuVAUquSppLpaL6hwqeGTBX7l0xyGe
         YrzyspvIijj3HMU/cAKeO3zzmbZv/e7Z7G739ouMO49kwm7LN6h4L2p0ciDcfkMlT7bA
         jBnopgxry+7bu5cFv98oW2Y+Q0U3/6ccYPAHSYgYYb+AVHAwQpQd7nShiBqjhctAS3jz
         LyOcDmdWkeryNf+ALb7hPfLDRUDFk+MuvMDx2RegM2xyTjChME9UeXq/Yi7iUeip2Upm
         Bc410N3prScWM0hVsImoeZfa7SBpbSFD2PMWcFGvYkaXiQkvy6G9tiplNPqWJoeSpQBH
         rNug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=uJR3aci6bbnfD795Is+jjZ7l7Ym+8Hk3SK4jeuHuseA=;
        b=wCj6IdZWwIHZ3uBSQxZUwkcdiD3GfbG6NcTG4MzKinmv+DZ3AnfxR2H1li5N6EqvVj
         gt8u0ONPWbz9Eo+JesPUjL8M7mgWJPzRmigEmVYeiWA6wBvB9qANGap8iP4QMFxMNSy/
         EdI1p0nP3oqCt/vHPQo1wBwgnkZ3uZjonmjUl0OeeBOzHvT3lrIEo5qdWvJ2HKBS5No/
         3bbXiwOnrmOhl8xQXPkOgSbCin+c2w+A+X7Acvw1H3ORBiX0VxuvrTtzQPfqNv6VH5aS
         KbumVB8Bh80j/cGKp1/u8TWRVrS0X6NA1ZvewO40R94gUCQJTxgifO8PQL+jqN1zMEh2
         KqDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m126si1572282qkc.163.2019.03.11.02.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 02:37:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D0F77C057F3C;
	Mon, 11 Mar 2019 09:37:14 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C95C05D705;
	Mon, 11 Mar 2019 09:37:02 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>,
	kvm@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
Date: Mon, 11 Mar 2019 17:36:58 +0800
Message-Id: <20190311093701.15734-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 11 Mar 2019 09:37:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

(The idea comes from Andrea, and following discussions with Mike and
 other people)

This patchset introduces a new sysctl flag to allow the admin to
forbid users from using userfaultfd:

  $ cat /proc/sys/vm/unprivileged_userfaultfd
  [disabled] enabled kvm

  - When set to "disabled", all unprivileged users are forbidden to
    use userfaultfd syscalls.

  - When set to "enabled", all users are allowed to use userfaultfd
    syscalls.

  - When set to "kvm", all unprivileged users are forbidden to use the
    userfaultfd syscalls, except the user who has permission to open
    /dev/kvm.

This new flag can add one more layer of security to reduce the attack
surface of the kernel by abusing userfaultfd.  Here we grant the
thread userfaultfd permission by checking against CAP_SYS_PTRACE
capability.  By default, the value is "disabled" which is the most
strict policy.  Distributions can have their own perferred value.

The "kvm" entry is a bit special here only to make sure that existing
users like QEMU/KVM won't break by this newly introduced flag.  What
we need to do is simply set the "unprivileged_userfaultfd" flag to
"kvm" here to automatically grant userfaultfd permission for processes
like QEMU/KVM without extra code to tweak these flags in the admin
code.

Patch 1:  The interface patch to introduce the flag

Patch 2:  The KVM related changes to detect opening of /dev/kvm

Patch 3:  Apply the flag to userfaultfd syscalls

All comments would be greatly welcomed.  Thanks,

Peter Xu (3):
  userfaultfd/sysctl: introduce unprivileged_userfaultfd
  kvm/mm: introduce MMF_USERFAULTFD_ALLOW flag
  userfaultfd: apply unprivileged_userfaultfd check

 fs/userfaultfd.c               | 121 +++++++++++++++++++++++++++++++++
 include/linux/sched/coredump.h |   1 +
 include/linux/userfaultfd_k.h  |   5 ++
 init/Kconfig                   |  11 +++
 kernel/sysctl.c                |  11 +++
 virt/kvm/kvm_main.c            |   7 ++
 6 files changed, 156 insertions(+)

-- 
2.17.1

