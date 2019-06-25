Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B73DC4646B
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:12:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17E072077C
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:12:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="qc/1KMTv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17E072077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 840AB6B0003; Mon, 24 Jun 2019 20:12:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F1D58E0003; Mon, 24 Jun 2019 20:12:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DFE48E0002; Mon, 24 Jun 2019 20:12:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3466B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 20:12:54 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id j124so18806056ywf.11
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:12:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=sNQn/dOnZHgVylzBkIWRNq/AXNkb7iif//pYLPbgJ2I=;
        b=Z3MoCFnlCzb/3Kt+k1IVdTlEAfNfm5iUQNRnhQo03cwdXmqL1Au4MgNqkM6XRjbvzi
         ZKvVWb76/3kVdQufKuqrPfOdv+0jsa8zxxi8OGOnv5fAjEMpa4En0Z4yifql+EEZcY6s
         JaIY2IuzGEyqJbg4T3njWPy0mVOkShT4N4i4DYJbGIwWHODC56Zx/nN09ILfGHCQzUfk
         aAaZQ7JBX/NkiBWwZ76L0EpPZWAdC6vrOGzJQje1MzDFdSR+LOwg+Fethh+E7CQf28rE
         U8MYl1jUBqZi95gd/pISfRqeMzdxVUtsb4GPg146/XQqJawhRLdoiXxZbKX6hBWGfhha
         aoTA==
X-Gm-Message-State: APjAAAUAXnEpWm4WKJYczoZdNXtFhfJY/tv+XV+fWWIoD1Et8SonW1Qp
	oNdo86ZoU+8I93cURkWw12Ja0Z4n7PSJVP/Wjvz9zLvBfJt9i/QurVugZmmuFYIh9C8odN18kZT
	1S8sV5khnrO78v5XDjOfTGJI3ZhMcYEvkENsW2gvJVty4M1ibC6wQs2ZQFST5bknIqA==
X-Received: by 2002:a0d:d607:: with SMTP id y7mr12235160ywd.376.1561421573934;
        Mon, 24 Jun 2019 17:12:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9RNj4moLmMh0L2omehMESaiPGfDCAZCr7TYQghA8SokNKSWsysP8YJwk74ew/miavtFz7
X-Received: by 2002:a0d:d607:: with SMTP id y7mr12235131ywd.376.1561421573066;
        Mon, 24 Jun 2019 17:12:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561421573; cv=none;
        d=google.com; s=arc-20160816;
        b=XzFLYzkBhBlAJLu83xlmvUw9eVqStqV8Zt9f9ko/uBppv3I4fWAAB/nY+4rb0OlIfE
         UgnFAeYntT6loVnd9OdangwlASwVwFDztBVmidjOC12ssiLd/edsicN6CyUqhGfPMR8f
         4/gfQKq5b7uGXe7d3KsO2mCESGj4OAw6BiBd1rJlQU9GrB4eEJAu2odtsy5jx6d3Jbui
         BmfVmljYnBxnZy1Y0HM102FmIV26tnY2QVwtITNzzrxt1ft+WvhOATnr1wECIu/8ODyT
         uMIXL5FQAZ9a2B0dk/ggeud/l/1d4MmYLCRusyr6GWWBcjyQHV94/VzauYke+qXldEQA
         cMRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=sNQn/dOnZHgVylzBkIWRNq/AXNkb7iif//pYLPbgJ2I=;
        b=dk/oS3J1j1nNDcby4Wue5E9YoSi+lM+vOLYOBmYhEW+FFY/ePeRYDh7qYO2TFzUMae
         Kg2+3PVLIa8FjYTOVwDh5IJS5Oy0+3JSUfQQQUoDLLZm0XW5fWj5yDeebWJNN5Z8rfKr
         UbSxgzH1/9+EAG+7jErigOhGSBzcQGnc16sYh8xNOvFgIycK+PfOPIk+6Dq7BRq1TvQ/
         gomoVTlSRxHLhL2NkWuqVmyv8lX9yFrgFH4T3SYsTGnXPuRJI/wg24aJ5GqCsQTgUVAF
         506YgTLE4q4B5PqD0r0rqzFVZYPnwAPxfg5GkSilxmYFh/NDg7dXOlfCrtxrcyvmX+OA
         ASlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="qc/1KMTv";
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t188si4337639yba.112.2019.06.24.17.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 17:12:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="qc/1KMTv";
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5P08RNC013007
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:12:52 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=sNQn/dOnZHgVylzBkIWRNq/AXNkb7iif//pYLPbgJ2I=;
 b=qc/1KMTvYsBus8AHq5JcKSWdamajXwVOMhECHDrdcr8x2v9V9P7a65icFGihJURUqTfW
 EWXTiFme7L9uOqgahFxEaUCPEDf4R0m9ijMiZL0g6+1F/XUMnYxAkqdPTgZn+DToSd9g
 W7hJGB09EdtzQOZoxL6zqROXb0St/40Ye6E= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2t9g0agkaj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:12:52 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Mon, 24 Jun 2019 17:12:51 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 680D962E206E; Mon, 24 Jun 2019 17:12:49 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, <hdanton@sina.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v9 0/6] Enable THP for text section of non-shmem files
Date: Mon, 24 Jun 2019 17:12:40 -0700
Message-ID: <20190625001246.685563-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250000
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes v8 => v9:
1. Fix bad use of IS_ENABLED (kbuild test robot)

Changes v7 => v8:
1. Use IS_ENABLED wherever possible (Kirill A. Shutemov);
2. Improve handling of !PageUptodate case (Kirill A. Shutemov);
3. Add comment for calling lru_add_drain (Kirill A. Shutemov);
4. Add more information about DENYWRITE dynamic (Johannes Weiner).

Changes v6 => v7:
1. Avoid accessing vma without holding mmap_sem (Hillf Dayton)
2. In collapse_file() use readahead API instead of gup API. This matches
   better with existing logic for shmem.
3. Add inline documentation for @nr_thps (kbuild test robot)

Changes v5 => v6:
1. Improve THP stats in 3/6, (Kirill).

Changes v4 => v5:
1. Move the logic to drop THP from pagecache to open() path (Rik).
2. Revise description of CONFIG_READ_ONLY_THP_FOR_FS.

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

This set (plus a few uprobe patches) is also available at

   https://github.com/liu-song-6/linux/tree/uprobe-thp

Please share your comments and suggestions on this.

Thanks!

Song Liu (6):
  filemap: check compound_head(page)->mapping in filemap_fault()
  filemap: update offset check in filemap_fault()
  mm,thp: stats for file backed THP
  khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
  mm,thp: add read-only THP support for (non-shmem) FS
  mm,thp: avoid writes to file with THP in pagecache

 drivers/base/node.c    |   6 +++
 fs/inode.c             |   3 ++
 fs/namei.c             |  23 +++++++-
 fs/proc/meminfo.c      |   4 ++
 fs/proc/task_mmu.c     |   4 +-
 include/linux/fs.h     |  32 +++++++++++
 include/linux/mmzone.h |   2 +
 mm/Kconfig             |  11 ++++
 mm/filemap.c           |   9 ++--
 mm/khugepaged.c        | 117 ++++++++++++++++++++++++++++++++---------
 mm/rmap.c              |  12 +++--
 mm/vmstat.c            |   2 +
 12 files changed, 189 insertions(+), 36 deletions(-)

--
2.17.1

