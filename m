Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0EA6C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:53:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 719EA20869
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:53:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="jVEKlY6S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 719EA20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06F848E0002; Tue, 25 Jun 2019 19:53:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01FD58E0003; Tue, 25 Jun 2019 19:53:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E29878E0002; Tue, 25 Jun 2019 19:53:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id C46F46B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:53:35 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id c15so1566506ybk.2
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=p/ITaQov8uTsl/nAqC+1DU4B903f9YJq14wWIWwsNWY=;
        b=il0yh5d0pFMucDWt3yHChRupxvfqEUTc6mDfWvKkRvmzOHS7BNCMw7C2oaxlJVaYws
         wl/UtIUc/bcW9opYxEphKVO9rggahqYe7WUyXO8Ay4LIX4CJ/K5eTUJsy2FnKddTgoaB
         Uixw9V28fg6t2ejCMgF6r+X3eB5RQ/wxdQzT7UacLXUeluhPRA3JeYgPcYqjfIZUsyOj
         BEfKZ2CvmWK85Np5kTvmRuHF165NUcGLtPTp1mYImWzKKbsHoYJUQE2oLsld4msCQuCg
         IFQWSSUDaJf57+vZFk02cxMCvJTwj69sGcHXLf7rSGhOPTacFBkAHFSK794hlnx9AjYh
         A6Qw==
X-Gm-Message-State: APjAAAUK18Ty6dSGq0n5a0IL7H+IeEJ1o0+kBui9sqBGd2sK6SHHJLLD
	oPelt0GHI1LWXI6Tkb7fUlsUcTfuaDOtkgKEfbpryq0OFdEE8VVKvlIQVxK8cNbqo4Yt9JSXeez
	PMwNhuzeUcbup5R4Gwp3PLQ9CQgK28gTxEugodgzGoRA72eoHJQFaIiD6cRtfkAkc6w==
X-Received: by 2002:a25:d2d2:: with SMTP id j201mr741258ybg.157.1561506815469;
        Tue, 25 Jun 2019 16:53:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuFgWRdVs7FxActD7EhlKL9s9YD4xaDiOJVtOwIenD9xItvJNjQVD3RAiUT5hzRKvgvwS8
X-Received: by 2002:a25:d2d2:: with SMTP id j201mr741238ybg.157.1561506814791;
        Tue, 25 Jun 2019 16:53:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561506814; cv=none;
        d=google.com; s=arc-20160816;
        b=foTpimzTuRF1fKS5PR/9BTRewE5L6l81o18y+FXoZntR8nfcmiC13wqPbKEsCkBK3o
         Vt6PC0VLI5v971LWGXwcT+LI88y2SJIMuhpEz8RebNoU3eXTNHGikvcEQsXJFrVYUDv0
         2pf7mw5w2Kcr2lQsq6SIc3/kV8kZCiP3lZi5IKE2PnLci8HwvsX7sNdyKSWvl8aqL9rA
         lTDASSWqIUpmgETqaQ/9UJ6mm9olX9HVsI4kwQSUtsPT6DOOckLPMeT8rv3Pn2xEjDP4
         aC8uWSeK0/kIdiIiK5pG9MDb3XkLU6GQbEfAhE6etvjj7iZcqZV9OUNIhc/0COr4nb1d
         32lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=p/ITaQov8uTsl/nAqC+1DU4B903f9YJq14wWIWwsNWY=;
        b=GgdI8V7l7NY7rX4IV7n0nV/WbgRuawevxX95RTTz4JjJOLbbkQnHZX20yuWuT+Mjho
         D4Ip+I4bF9icCTsBabDyZXXf01q1jG2KeSgH1r9JJjJYMcQZpQK5srtOB66dsZIZgFmP
         M2jcFq6BDxTbvz+SQaIPI1zFhgW/uYuPVSDJzaKAfZJB1MqPdNuleEIXIgUJVCfAKPd8
         Wl5uHzZwx/pHiYfH7wkR+gbdzM+kL7fRyLGiYOXibxKFlTfP/h8Otm3f+AepITlTIabW
         8cy0VQMOrbfK58QvA5HK/KDWwuPAcwpfMKZQGZbv+POMg2k01BMtAFT/sBEzk3eWI4NM
         BmBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=jVEKlY6S;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 203si5514340ybz.50.2019.06.25.16.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 16:53:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=jVEKlY6S;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5PNqZpj032119
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:34 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=p/ITaQov8uTsl/nAqC+1DU4B903f9YJq14wWIWwsNWY=;
 b=jVEKlY6SwrMdq1UrJ8wuC9IJRo0PxGLvI69+XEmtP1fcedbrDxwkf7CJe8hSFW9URS57
 zblIW6mS5v1kh1tPuUTopbpJpce8ghFHrzNam5XoIW8n9VkG+CtNZqRu2eDmCcAfT/KE
 oLFsLpBume/Cogngk8iQfKIdvD1PEc+QFoc= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2tbpv81mvg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:34 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 25 Jun 2019 16:53:32 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 661F962E1F8B; Tue, 25 Jun 2019 16:53:31 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v7 0/4] THP aware uprobe
Date: Tue, 25 Jun 2019 16:53:21 -0700
Message-ID: <20190625235325.2096441-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-25_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250196
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

TODO (temporarily removed in v7):
After all uprobes within the THP are removed, regroup the PTE-mapped pages
into huge PMD.

This set (plus a few THP patches) is also available at

   https://github.com/liu-song-6/linux/tree/uprobe-thp

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

Song Liu (4):
  mm: move memcmp_pages() and pages_identical()
  uprobe: use original page when all uprobes are removed
  mm, thp: introduce FOLL_SPLIT_PMD
  uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT

 include/linux/mm.h      |  8 +++++++
 kernel/events/uprobes.c | 51 +++++++++++++++++++++++++++++++----------
 mm/gup.c                |  8 +++++--
 mm/ksm.c                | 18 ---------------
 mm/util.c               | 13 +++++++++++
 5 files changed, 66 insertions(+), 32 deletions(-)

--
2.17.1

