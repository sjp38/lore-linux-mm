Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F9CAC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:58:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 178992175B
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:57:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="PfQXkQIX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 178992175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C2C88E0003; Thu, 13 Jun 2019 13:57:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 873168E0002; Thu, 13 Jun 2019 13:57:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73C508E0003; Thu, 13 Jun 2019 13:57:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 509008E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:57:59 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id 77so21748203ywp.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:57:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=SN9bJYBvVZmjIY7TQwW3dcHWX2b73J5/DqqXtyPOt5g=;
        b=Zno44YX1NLOBEu1oeu5vVEwPgPamBzyyUSOel4+QHT1o/Bft+ZJZNBj+ABUw4oGlfG
         wZt1K7dMvAtYkqTwR0wuKDBsSZ0MPP0kSOS/qO19fqnGpfz/+UFqzjxFQPPZJN1/pUDu
         wEAvuS+9U+4Gp69RRFHnC8fivONNDHnyech1jTayeZMg0rjrSmeocPaJkmujF2ccA+8b
         klCdiQlfhjCuZV1oKmvXN8dpbqcJMN67HlloiydkDroa8GGoRAL5KNTi/zJXC+J8EMJL
         yypxU50vm4zErXtE0bcreEtVv3lQZpsZQMCg4EJvJsjkrcCNjqUaxtzL3ecf3PRX5XmR
         tXeg==
X-Gm-Message-State: APjAAAXZjhj1CdlaOROqVPJ8R6rkSRbd2RTas9K2wgOT6WACGN1qOtIS
	ckcdl3EBUsPcZcULS7+eWFgCQ8a/bJsqbDvtiOIMYxGth45ylvysfeQ3ByGFJIwgOsDBKqQYG9j
	L6ey0nHaHWtYDrmNADsj6rF5z8ErMVBFKsxsFN5AhswwcfzkKlHiepEb5ASonzA/oww==
X-Received: by 2002:a25:d10d:: with SMTP id i13mr5166552ybg.169.1560448679043;
        Thu, 13 Jun 2019 10:57:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqye8i8fFd+BZSuZKIvuPT34OsbWOl67LbnMjaBEi05eStTxo5FETqsXEVKmODklt7wEIqAK
X-Received: by 2002:a25:d10d:: with SMTP id i13mr5166508ybg.169.1560448678224;
        Thu, 13 Jun 2019 10:57:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560448678; cv=none;
        d=google.com; s=arc-20160816;
        b=e6bxnS9Fhk3vEY1L/xDcBBEZspctESwKy+U9/Pqj5YpwBKSQj4stw+mPjNU5CeCtoe
         bXGBxc/OV7AVNt45A/5E21eYWLQZR1fnGYuJw/jSwRnyO22elc5e4l6OUVEadvvl8l+C
         M90srza4mkUliU2ekUpuea6Qs3otR7z0bOwD+xTgfg47KKRIKX5cZxypLum/+vSKrOXO
         GDGzUtreIY2c7C27QelguftYrrFk7wLpKT9oYEnbCy46bUN2+nSsMX05Q4rmOVb27Vpx
         gF2VDX5c687Q4Sblbl7LHdv0lbUTsYEfNRwYO/IyO/Uyo0DCSG+bFLf3Lw1vO1qivA3h
         eTLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=SN9bJYBvVZmjIY7TQwW3dcHWX2b73J5/DqqXtyPOt5g=;
        b=rO2Xq7YWbKZ3rC/UFuZ+sw3uwYqRsKgjnGMoIkmz7663LXeHzFPVOUYwEvT6eqgK8h
         SYEb+a1UcTFKP1aIt03hK9Ljkrxei0GjLf5TC9nHmdMermYie/d47wM5RZbwsGWwH5r0
         f4MQsU/8kK092Y9+C8sRVp70shNY0szQVszuaXhAg2ofI+LSobiW7YwHxxa4cj9rggCL
         YWXEUXAJm9UO+8Y++14SQO6q5StEnT3irhFEfPWKFULaLPOPNf9bH33cvPFE03gtSRDo
         8Vq0kDH2AVPmwm/kKCFX6x0tQQunqIHNslUGON0WqEdk9uIhJe5//7WTREp5NRZ3z3Mo
         I95A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PfQXkQIX;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id h6si209871ywm.381.2019.06.13.10.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 10:57:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PfQXkQIX;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5DHpnxn001518
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:57:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=SN9bJYBvVZmjIY7TQwW3dcHWX2b73J5/DqqXtyPOt5g=;
 b=PfQXkQIXJKJYZzYLK2K6BK+Mcwkf22sy+R8ogNnL5euBKlXTZdZh6uBUfvrIEjf6xLFF
 jBqMf2Z3I1TEuaNXdU2U6zAW5c7JfcRtkGEU3aZPsWh3woDfucKpJpSHzuDh/YJuq99C
 u6HPiugIHARcUnKwy8BwfvqMgpFVL2Xf2eE= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t3py212uu-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:57:57 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 13 Jun 2019 10:57:55 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 3DA8762E1C18; Thu, 13 Jun 2019 10:57:55 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <oleg@redhat.com>, <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 0/5] THP aware uprobe
Date: Thu, 13 Jun 2019 10:57:42 -0700
Message-ID: <20190613175747.1964753-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130131
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
FOLL_SPLIT_PMD, which only split PMD for uprobe. After all uprobes within
the THP are removed, the PTEs are regrouped into huge PMD.

Note that, with uprobes attached, the process runs with PTEs for the huge
page. The performance benefit of THP is recovered _after_ all uprobes on
the huge page are detached.

This set (plus a few THP patches) is also available at

   https://github.com/liu-song-6/linux/tree/uprobe-thp

Changes since v3:
1. Simplify FOLL_SPLIT_PMD case in follow_pmd_mask(), (Kirill A. Shutemov)
2. Fix try_collapse_huge_pmd() to match change in follow_pmd_mask().

Changes since v2:
1. For FOLL_SPLIT_PMD, populated the page table in follow_pmd_mask().
2. Simplify logic in uprobe_write_opcode. (Oleg Nesterov)
3. Fix page refcount handling with FOLL_SPLIT_PMD.
4. Much more testing, together with THP on ext4 and btrfs (sending in
   separate set).
5. Rebased up on Linus's tree:
   commit 35110e38e6c5 ("Merge tag 'media/v5.2-2' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-media")

Changes since v1:
1. introduces FOLL_SPLIT_PMD, instead of modifying split_huge_pmd*();
2. reuse pages_identical() from ksm.c;
3. rewrite most of try_collapse_huge_pmd().

Song Liu (5):
  mm: move memcmp_pages() and pages_identical()
  uprobe: use original page when all uprobes are removed
  mm, thp: introduce FOLL_SPLIT_PMD
  uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
  uprobe: collapse THP pmd after removing all uprobes

 include/linux/huge_mm.h |  7 +++++
 include/linux/mm.h      |  8 +++++
 kernel/events/uprobes.c | 54 +++++++++++++++++++++++++-------
 mm/gup.c                |  9 ++++--
 mm/huge_memory.c        | 69 +++++++++++++++++++++++++++++++++++++++++
 mm/ksm.c                | 18 -----------
 mm/util.c               | 13 ++++++++
 7 files changed, 146 insertions(+), 32 deletions(-)

--
2.17.1

