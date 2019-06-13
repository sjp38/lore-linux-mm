Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B91CC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:22:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8B1320896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:21:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="jN1MvnDh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8B1320896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72A776B0003; Thu, 13 Jun 2019 01:21:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B3F86B0005; Thu, 13 Jun 2019 01:21:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5080C6B0006; Thu, 13 Jun 2019 01:21:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 15F436B0003
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:21:59 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 59so11195765plb.14
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:21:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=wVHeuJRR2IcBs441yrNKOyI6tpwJpCepFRIyVFLc+8w=;
        b=gduiNqHDS9a0d7EFtILgDSkIQy71XibfzMc4gubUda0JeyoHDFgrpsXMgMEbxmXakG
         1mroepvd66FJa8Rp3daNaktr5AdazdnTtTJtdEuIApM52dlbpeyOUlUzvuy2/hGEV7Sp
         QuUjY9qX5RooxpZP25DKKGyXpUz+NUgeYaSiKfuVoVaPgU8VpYj1Nr3HR5R90kGiJolq
         NI/ckB8E7fSrB+vob5iMoYiwvmuM2nro+KuLrEeaXRLj1XvqCFl0xoQXmndd/x/dbfer
         QVCtfZjhKLi2cAhp8qfpTARyDOq7u8m4tiKIl97T0iosyuSVa6FY52WFqa4xuLKlXN8v
         z3UQ==
X-Gm-Message-State: APjAAAUSmZyFRs/EMoDss/VOaNdf3DpU6KZTsivNM/LKtlQS8L1kd8N5
	bQBRfCeUVl3apsIOQtxuYOoapNEV73A68YhirSHheUXDKdhp8UzgCzeo0/EvHe/TqfJeznxLUbV
	yuH2xqVS9+/532094PpcVwlRb6bKQbAlK61HSvsbTSKFDdgXgDv9vTz1ed+x2UZNkcg==
X-Received: by 2002:a17:902:4c:: with SMTP id 70mr60746299pla.308.1560403318664;
        Wed, 12 Jun 2019 22:21:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytYfw5klxthO6S392v6I5ilSmkRGIuhJEvkfluj0N2oQvAGtvui3LMi20CERyOYpzuK9KM
X-Received: by 2002:a17:902:4c:: with SMTP id 70mr60746252pla.308.1560403317862;
        Wed, 12 Jun 2019 22:21:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560403317; cv=none;
        d=google.com; s=arc-20160816;
        b=scgCtzy/eZ4y48C6Cdr/Qrs7BIqcv4PH9/z6BLLGaQaqDuS+GcYKaCmYrYN+52ZA1e
         atkMU64q7gFm4xfB5BTaQ06hhgU8rOCcgot0vTpPqJ83Gdc6+35pGq8U7OAXuYutbSdm
         /up7HZniPvrxlrkUItUhK3b2I9uiGgKPeIJZrM69WfqEDnqvJ4wnN+4viUElhgf271hG
         oIzku+CGLZfju7MNmxanXv1df21DxgCZPOM/0kFzYLcP7D74Cp9Ir9bjSmwIV79zBUXL
         BXgbA1V94whlf9QEzJHJakPO+rK7PrtSRbJPmlXZHpXfrhftiyHI/C+3hkLXEbWpcYH4
         FBDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=wVHeuJRR2IcBs441yrNKOyI6tpwJpCepFRIyVFLc+8w=;
        b=NCwCsrnu9nY0fPTBuXDyycqX9gxD0ARDLvetcRUnu5OkdLYBOlQTPQrkvkbszN2jDq
         516xlKo4+wE3f+dX+X/Ld/LPVGLfJmEVPJqNECJMOEb9lCRrsXg8SZ7EcmMHa57sCx/Y
         DzXIP2Q1sjBhTsVUichMRA0Ohbf/vR8jeszzn0oLtU2vA+CAAbt9IoLSNA+bRM5TocWA
         /YgUXWt7fxUrAipa7diOsOvSjweSc4Wp4IaW/MbiWqyAzurSmkCLGbWDJHjwiRDpcizR
         px7ql3vyncQ6HHkVUxd4hkwrxTWB6aHXPlUeVFkdr6Mum4zjKs0Okr2lic0t/d6jWJqo
         vnsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=jN1MvnDh;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id cg6si1962713plb.350.2019.06.12.22.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 22:21:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=jN1MvnDh;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5D5KRMa024276
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:21:56 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=wVHeuJRR2IcBs441yrNKOyI6tpwJpCepFRIyVFLc+8w=;
 b=jN1MvnDhGz8W8WNzD0tKO8q3xPiiYrONNwwKuXt9DnXLXryMuRS3LEl8x6Wf//COtuPt
 3sXq6VqKsaKyYf7ZITFbZRbEm9Ne50PrK8ojJXSVg8wK2rozSGgHLbXidmJ3fORHzE2w
 AwcW9tftJNGfFv/zWC2MfEWhRpMm71z1ZP8= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t365k1x14-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:21:56 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 12 Jun 2019 22:21:54 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 8EA5D62E2FC5; Wed, 12 Jun 2019 22:21:53 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <chad.mynhier@oracle.com>, <mike.kravetz@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH 0/3] Enable THP for text section of non-shmem files
Date: Wed, 12 Jun 2019 22:21:48 -0700
Message-ID: <20190613052151.3782835-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130043
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

After this call, part of the text section is splitted out and mapped to
THP:

    00400000-00425000 r-xp 00000000 00:27 2006927     app
    00600000-00e00000 r-xp 00200000 00:27 2006927     app   <<< on THP
    00e00000-074d0000 r-xp 00a00000 00:27 2006927     app

Limitations:

1. This only works for text section (vma with VM_DENYWRITE).
2. Once the application put its own pages in THP, the file is read only.
   open(file, O_WRITE) will fail with -ETXTBSY. To modify/update the file,
   it must be removed first. Here is an example case:

    root@virt-test:~/# ./app hugify
    ^C

    root@virt-test:~/# dd if=/dev/zero of=./app bs=1k count=2
    dd: failed to open './app': Text file busy

    root@virt-test:~/# cp app.backup app
    cp: cannot create regular file 'app': Text file busy

    root@virt-test:~/# rm app
    root@virt-test:~/# cp app.backup app
    root@virt-test:~/#

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

Song Liu (3):
  mm: check compound_head(page)->mapping in filemap_fault()
  mm,thp: stats for file backed THP
  mm,thp: add read-only THP support for (non-shmem) FS

 fs/proc/meminfo.c      |   4 ++
 include/linux/fs.h     |   8 +++
 include/linux/mmzone.h |   2 +
 mm/Kconfig             |  11 +++++
 mm/filemap.c           |   7 +--
 mm/khugepaged.c        | 107 +++++++++++++++++++++++++++++++++--------
 mm/rmap.c              |  12 +++--
 mm/vmstat.c            |   2 +
 8 files changed, 125 insertions(+), 28 deletions(-)

--
2.17.1

