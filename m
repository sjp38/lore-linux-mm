Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B375B2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 05:20:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 12so6292318wmn.1
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 02:20:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j19si3255076wmi.49.2017.06.30.02.20.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 02:20:45 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5U9IlUY122893
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 05:20:43 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bd6tdvwaq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 05:20:43 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 30 Jun 2017 10:20:41 +0100
Date: Fri, 30 Jun 2017 12:20:31 +0300
In-Reply-To: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 0/7] userfaultfd: enable zeropage support for shmem
From: Mike Rapoprt <rppt@linux.vnet.ibm.com>
Message-Id: <221EB91B-4491-4737-BD8B-FE983E1084A4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Hi,

Any updates/comments?


On June 20, 2017 9:20:45 AM GMT+03:00, Mike Rapoport <rppt@linux=2Evnet=2E=
ibm=2Ecom> wrote:
>Hi,
>
>These patches enable support for UFFDIO_ZEROPAGE for shared memory=2E
>
>The first two patches are not strictly related to userfaultfd, they are
>just minor refactoring to reduce amount of code duplication=2E
>
>Mike Rapoport (7):
>shmem: shmem_charge: verify max_block is not exceeded before inode
>update
>  shmem: introduce shmem_inode_acct_block
>userfaultfd: shmem: add shmem_mfill_zeropage_pte for userfaultfd
>support
>  userfaultfd: mcopy_atomic: introduce mfill_atomic_pte helper
>  userfaultfd: shmem: wire up shmem_mfill_zeropage_pte
>  userfaultfd: report UFFDIO_ZEROPAGE as available for shmem VMAs
>  userfaultfd: selftest: enable testing of UFFDIO_ZEROPAGE for shmem
>
> fs/userfaultfd=2Ec                         |  10 +-
> include/linux/shmem_fs=2Eh                 |   6 ++
>mm/shmem=2Ec                               | 167
>+++++++++++++++++--------------
> mm/userfaultfd=2Ec                         |  48 ++++++---
> tools/testing/selftests/vm/userfaultfd=2Ec |   2 +-
> 5 files changed, 136 insertions(+), 97 deletions(-)

--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
