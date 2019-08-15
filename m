Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 579A5C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:47:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 186B020578
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:47:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="XfCOaZuL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 186B020578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E9FC6B02C5; Thu, 15 Aug 2019 12:47:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 999836B02C6; Thu, 15 Aug 2019 12:47:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8896E6B02C7; Thu, 15 Aug 2019 12:47:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0116.hostedemail.com [216.40.44.116])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3846B02C5
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:47:55 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1E247180AD802
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:47:55 +0000 (UTC)
X-FDA: 75825244110.01.toad91_6218ed87c2a3e
X-HE-Tag: toad91_6218ed87c2a3e
X-Filterd-Recvd-Size: 6349
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:47:53 +0000 (UTC)
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7FGhiww024255
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:47:49 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=QXKJOgRl5FIoWJim517rSgnhgGSAwYjtUxv7Q7p0QmE=;
 b=XfCOaZuLGA9TUpMf4peT78rnVC04WYt5MDcJOygLrKvAHyEGn0W6RuxJFkBbwA7YfqLE
 pI5moNCqnPq6663MOrFC8e4MUPKc9pMOabwWtSBWh8uu89UbzKk8EBV3tyc9kGXdXkIT
 ylKHDh3q1b1KIqPrL+6BUFzzi9PGDXsmg5U= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2uda85r75n-17
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:47:49 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 15 Aug 2019 09:47:39 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 0BC6C62E16D2; Thu, 15 Aug 2019 09:45:34 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <hannes@cmpxchg.org>, <matthew.wilcox@oracle.com>,
        <kirill.shutemov@linux.intel.com>, <oleg@redhat.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <srikar@linux.vnet.ibm.com>, Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v13 0/6] THP aware uprobe
Date: Thu, 15 Aug 2019 09:45:19 -0700
Message-ID: <20190815164525.1848545-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-15_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908150163
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This set makes uprobe aware of THPs.

Currently, when uprobe is attached to text on THP, the page is split by
FOLL_SPLIT. As a result, uprobe eliminates the performance benefit of THP.

This set makes uprobe THP-aware. Instead of FOLL_SPLIT, we introduces
FOLL_SPLIT_PMD, which only split PMD for uprobe.

After all uprobes within the THP are removed, the PTE-mapped pages are
regrouped as huge PMD.

This set (plus a few THP patches) is also available at

   https://github.com/liu-song-6/linux/tree/uprobe-thp


Changes v12 => v13
1. Improve checks for the page in collapse_pte_mapped_thp() (Oleg).
2. Include Reviewed-by from Oleg.

Changes v11.4 => v12
1. Combine the first 4 patches with the rest 2 patches again in the same
   set.
2. Improve checks for the page in collapse_pte_mapped_thp() (Oleg).
3. Fixed build error w/o CONFIG_SHMEM.

v11.1 to v11.4 are only the last two patches.

Changes v11.3 => v11.4:
1. Simplify locking for pte_mapped_thp (Oleg).
2. Improve checks for the page in collapse_pte_mapped_thp() (Oleg).
3. Move HPAGE_PMD_MASK to collapse_pte_mapped_thp() (kbuild test robot).

Changes v11.2 => v11.3:
1. Update vma/pmd check in collapse_pte_mapped_thp() (Oleg).
2. Add Acked-by from Kirill

Changes v11.1 => v11.2:
1. Call collapse_pte_mapped_thp() directly from uprobe_write_opcode();
2. Add VM_BUG_ON() for addr alignment in khugepaged_add_pte_mapped_thp()
   and collapse_pte_mapped_thp().

Changes v9 => v10:
1. 2/4 incorporate suggestion by Oleg Nesterov.
2. Reword change log of 4/4.

Changes v8 => v9:
1. To replace with orig_page, only unmap old_page. Let the orig_page fault
   in (Oleg Nesterov).

Changes v7 => v8:
1. check PageUptodate() for orig_page (Oleg Nesterov).

Changes v6 => v7:
1. Include Acked-by from Kirill A. Shutemov for the first 4 patches;
2. Keep only the first 4 patches (while I working on improving the last 2).

Changes v5 => v6:
1. Enable khugepaged to collapse pmd for pte-mapped THP
   (Kirill A. Shutemov).
2. uprobe asks khuagepaged to collaspe pmd. (Kirill A. Shutemov)

Note: Theast two patches in v6 the set apply _after_ v7 of set "Enable THP
      for text section of non-shmem files"

Changes v4 => v5:
1. Propagate pte_alloc() error out of follow_pmd_mask().

Changes since v3:
1. Simplify FOLL_SPLIT_PMD case in follow_pmd_mask(), (Kirill A. Shutemov)
2. Fix try_collapse_huge_pmd() to match change in follow_pmd_mask().

Changes since v2:
1. For FOLL_SPLIT_PMD, populated the page table in follow_pmd_mask().
2. Simplify logic in uprobe_write_opcode. (Oleg Nesterov)
3. Fix page refcount handling with FOLL_SPLIT_PMD.
4. Much more testing, together with THP on ext4 and btrfs (sending in
   separate set).
5. Rebased.

Changes since v1:
1. introduces FOLL_SPLIT_PMD, instead of modifying split_huge_pmd*();
2. reuse pages_identical() from ksm.c;
3. rewrite most of try_collapse_huge_pmd().

Song Liu (6):
  mm: move memcmp_pages() and pages_identical()
  uprobe: use original page when all uprobes are removed
  mm, thp: introduce FOLL_SPLIT_PMD
  uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
  khugepaged: enable collapse pmd for pte-mapped THP
  uprobe: collapse THP pmd after removing all uprobes

 include/linux/khugepaged.h |  12 +++
 include/linux/mm.h         |   8 ++
 kernel/events/uprobes.c    |  81 +++++++++++++-----
 mm/gup.c                   |   8 +-
 mm/khugepaged.c            | 168 ++++++++++++++++++++++++++++++++++++-
 mm/ksm.c                   |  18 ----
 mm/util.c                  |  13 +++
 7 files changed, 268 insertions(+), 40 deletions(-)

--
2.17.1

