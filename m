Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DA77C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:28:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 243CB2064B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:28:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="glTMlIzP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 243CB2064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FC926B0005; Thu, 20 Jun 2019 13:28:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AD258E0002; Thu, 20 Jun 2019 13:28:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 874BF8E0001; Thu, 20 Jun 2019 13:28:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F26F6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:28:06 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 21so2217265pgl.5
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=/n1Ua2HjBrE3gKy7VoP7FqeX76ghf8PfBftOVKtaDWc=;
        b=SpJ972UKSUPOM3dFVz8UDnSv4PCoKRD+unrqkfF+FPG3iBH8jMU17BFj6YQVoDCNnj
         X7USR1twY0wt7urGpsaHhFu4B1FAnsASlGhUrTte3UEId3NxlpbIZuuReSFzjFdLOe38
         qULCIngUg3V6hP7//fVgalSHTXVEJgRomtoZV2iVned53ZzyDRp4lmoygLP5ATBMYQqA
         tUv8zZGla8CHXV9F/Nkg0yVNIqaw8RExGY5YWII+FI/d6TgR+CyuEQtwYTVK6wlUBpHl
         W+5KMOkg7QR89niOZJ3+oF4tOfAI+G+/rggmSmjEJMq98Kv5QxcpTaV+Rf3H3MKttEIm
         Ue7g==
X-Gm-Message-State: APjAAAWyYXn5ogfDpB0p2l/kMBE/aL5Rv/4X+ZJkr/wCzUE1iGTkd2Kb
	qzx9b905n26M+39woTe0H212u+ocqRYZNhRvtpDnzKVYeL5t/xn9e4wN+64eQuyAJIsl7cajTg4
	AU+gsAZUYaLtR0IeCYpCwpb5ZqdR4QjX/CtEJ6iGcQni74USYDu/P0e+/blbY7zT2+Q==
X-Received: by 2002:a63:4a20:: with SMTP id x32mr13679895pga.107.1561051685695;
        Thu, 20 Jun 2019 10:28:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqykruEMDBqsvXwzkGmR48IW4ObOmiig129cjvKpMk6z+Swnhe+4xtflsgciU11XbMfqVp
X-Received: by 2002:a63:4a20:: with SMTP id x32mr13679828pga.107.1561051684838;
        Thu, 20 Jun 2019 10:28:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561051684; cv=none;
        d=google.com; s=arc-20160816;
        b=hx8RJYxElDC/anmr9C8d6Y+cKW1rax0EATSoyDaLClSzfw9lChTV3NZNQGSCukv9kP
         N1lSe6Ijipph1m9oprIlt25YDWTkNcvduz0uNax4FI40jsq62q1JGiMzzMRL26PGd7Yd
         Tn8fTKIuGIYWLPo+JDROTMKfXKcIVbj9k5u8mzqtS7AWB1Gnf3u5O2dMyQ2SltjSzjVD
         Wj9Hl9thggOtx3LO0f9Ao0KpXHE/Z/T7nBsx969h/J32oJ+gTm0YoU5PZiX0S/kOi+Kz
         Ohmf6S88+dBR1CHRWKn0sVyI7AcfwrU3i7o+5wt+++0tzgQt/N0JvOS4Cv7h3SV7fKHu
         YpZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=/n1Ua2HjBrE3gKy7VoP7FqeX76ghf8PfBftOVKtaDWc=;
        b=OEJhwXsNtXi8lwEHrY5b+bNUBkI3eImH3Q/XKyIOEWc71E6rhQxonGw6zP7ki90h58
         nWsFw0oxEhpVT/9VCAqcZoVFnGSTL9+6nBrUDe9R8FaM+uu5kkp1IlXC6ewcVm4U/zLO
         EljuIV+/asDyKxMMcKlYI5+Y0Xn6c/3PFTBwhcW/XDA2kJ6vtSMHu6fO6LiJk9fXKOty
         Ky3GIHFWqFVT3j+HQZ/xbLkM6L9f4MqlmQADIpEFTqmXPXEL1LtfFOXLm3rMaBV8OCh5
         h2aZn9mr9sTrjw6r3iPWvrR4vlvGHwzD0efXQIbid7ZXucoU6eA9SrParAdU2wkNIi45
         5bBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=glTMlIzP;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a15si104310pgw.246.2019.06.20.10.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 10:28:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=glTMlIzP;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KHKJZ9021478
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:04 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=/n1Ua2HjBrE3gKy7VoP7FqeX76ghf8PfBftOVKtaDWc=;
 b=glTMlIzPXLRlKooWq7LCc2dpG0iviBHZpAT2WgsXy8Edi3b9YnUoQHgtcop9HVoUuRo0
 MK5kzYWBpltVMux/yZCpNJtzWVAq+ZGlYgR1YSKDgy51MI9ztzL6aG3ZnbJvsL+QZi7g
 +9JYUqP/FLhL6yPT5Wo+CMJCXU+0H4iNhKc= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t7wrj36rx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:04 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 20 Jun 2019 10:28:02 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 3D4F862E2004; Thu, 20 Jun 2019 10:28:01 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 0/6] [PATCH v3 0/6] Enable THP for text section of non-shmem files
Date: Thu, 20 Jun 2019 10:27:46 -0700
Message-ID: <20190620172752.3300742-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200124
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes v3 => v4:

1. Put the logic to drop THP from pagecache in a separate function (Rik).
2. Move the function to drop THP from pagecache to exit_mmap().
3. Revise confusing commit log 6/6.

Changes v2 => v3:
1. Removed the limitation (cannot write to file with THP) by truncating
   whole file during sys_open (see 6/6);
2. Fixed a VM_BUG_ON_PAGE() in filemap_fault() (see 2/6);
3. Split function rename to a separate patch (Rik);
4. Updated condition in hugepage_vma_check() (Rik).

Changes v1 => v2:
1. Fixed a missing mem_cgroup_commit_charge() for non-shmem case.

This set follows up discussion at LSF/MM 2019. The motivation is to put
text section of an application in THP, and thus reduces iTLB miss rate and
improves performance. Both Facebook and Oracle showed strong interests to
this feature.

To make reviews easier, this set aims a mininal valid product. Current
version of the work does not have any changes to file system specific
code. This comes with some limitations (discussed later).

This set enables an application to "hugify" its text section by simply
running something like:

          madvise(0x600000, 0x80000, MADV_HUGEPAGE);

Before this call, the /proc/<pid>/maps looks like:

    00400000-074d0000 r-xp 00000000 00:27 2006927     app

After this call, part of the text section is split out and mapped to
THP:

    00400000-00425000 r-xp 00000000 00:27 2006927     app
    00600000-00e00000 r-xp 00200000 00:27 2006927     app   <<< on THP
    00e00000-074d0000 r-xp 00a00000 00:27 2006927     app

Limitations:

1. This only works for text section (vma with VM_DENYWRITE).
2. Original limitation #2 is removed in v3.

We gated this feature with an experimental config, READ_ONLY_THP_FOR_FS.
Once we get better support on the write path, we can remove the config and
enable it by default.

Tested cases:
1. Tested with btrfs and ext4.
2. Tested with real work application (memcache like caching service).
3. Tested with "THP aware uprobe":
   https://patchwork.kernel.org/project/linux-mm/list/?series=131339

Please share your comments and suggestions on this.

Thanks!

Song Liu (6):
  filemap: check compound_head(page)->mapping in filemap_fault()
  filemap: update offset check in filemap_fault()
  mm,thp: stats for file backed THP
  khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
  mm,thp: add read-only THP support for (non-shmem) FS
  mm,thp: avoid writes to file with THP in pagecache

 fs/inode.c             |   3 ++
 fs/proc/meminfo.c      |   4 ++
 include/linux/fs.h     |  31 ++++++++++++
 include/linux/mmzone.h |   2 +
 mm/Kconfig             |  11 +++++
 mm/filemap.c           |   9 ++--
 mm/khugepaged.c        | 104 +++++++++++++++++++++++++++++++++--------
 mm/mmap.c              |  14 ++++++
 mm/rmap.c              |  12 +++--
 mm/vmstat.c            |   2 +
 10 files changed, 164 insertions(+), 28 deletions(-)

--
2.17.1

