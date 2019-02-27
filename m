Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5908DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:48:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FD2C2083D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:48:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FD2C2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FDCD8E0003; Wed, 27 Feb 2019 09:48:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AC8E8E0001; Wed, 27 Feb 2019 09:48:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 774558E0003; Wed, 27 Feb 2019 09:48:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5424B8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:48:02 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id i67so5059862oia.22
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 06:48:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=KqEnAh7qzgwFQ4mWimAppSOEJrWyDJ2ylREBe/UmJtA=;
        b=RvwoH72GxfNpUTZKi9i8uqrrGaPjSUsg9EHWW4MgtK4MRQAuThJ+ezF1dvNChOz5Wu
         /rWwx5C90w9X6B3zqrdAOLDF2EPMSqSc/lsi+OtLT7IXD58kC5z1ZcUyMuTaMyz6pBEN
         YvIQvY7TLEZibg90CnzRO21Vvdzr3Fbl5qKymF2HghoHFd2OO8ghjuBwgeeitfIzj80d
         vpofoOIhQtPVGI46rG+lLc4UI/Y2KOdxaB1wyPB97JVXkkgiL2k+oJuQ015mNyz0zlI1
         5O1e6UGjD6pPipsMloxdAlmLDb/P+NAuSyhT/2DTEoBx1mJxK3MCcNzgjRdKGfhyyWpn
         tRig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubyux5Mjf7XwFbxn8QYWWUOn6gUvIMUQPONcIjJ/CbZ4Dq6eOHc
	tssN6pYOK5PUstEyEKEulAGOVjh5gfAzIKSmJkIJfu0fh/iDOpsJ0ps/iPykembO/EgJjBmY6qf
	WWVU8z7ocGjZAau5q88XAzWUxY2IsE23Y1MuKhLrVXQsq6k07MXwwflVf7tKpwlx5tA==
X-Received: by 2002:aca:aa07:: with SMTP id t7mr1083362oie.126.1551278881709;
        Wed, 27 Feb 2019 06:48:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYzEr8mKq8bg2dqGSd1+ZiBXrDJhH86y8QdWX+FTc3ss7eoq9tS/rB0+NSmbo6ehe2QEFSb
X-Received: by 2002:aca:aa07:: with SMTP id t7mr1083310oie.126.1551278880508;
        Wed, 27 Feb 2019 06:48:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551278880; cv=none;
        d=google.com; s=arc-20160816;
        b=pulXhykKTeUTrnfVSdRga4y+8cVIHZAg3gyDUOt/cBcfUPWCvD5r5H6/1AbkPE44YM
         zg17tBit/wL9u66JAugNCLQ3AXuSg6NsS/LL8ud/b+JHqBPU8GV0JVskWYrOkb2cED17
         VlAXwagwDbll6ZmJDbEq0JgLI9xV/2nELiEsVTsKxQxHPIubFPGteuO9uEkB5TD3TElH
         hsdZM7hXrI+B6Whvmtxot9mJreVActQU1JIPDLfREKHbG7OTC4EVbfbjDn7/BCziNi5i
         euWJmgVkM+f8njtgOckgBiclNt2CrQg5Ov50ckr7EPai6feQFCKdZa/wSK24Tez6IdZw
         n/ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=KqEnAh7qzgwFQ4mWimAppSOEJrWyDJ2ylREBe/UmJtA=;
        b=MBb7J294USZjyxGpNYLtuT7lU14Z2DpFr0Gvwjq7SXAvxEFK53CLKOnt7szH7EURsD
         F4KEhrAIL6dpygh+WNmhCGIC7Fw57qJh8B+x6a099EknO2/dtrbl0DFDm0EqIH/d0392
         5Jju/ojLOnQT+CRLYaG6Cj2u1ApsWA//Z/aURfCRTVAaUeOjQ16/royNgjup9tv2Oc7k
         epn3d+JEWWL9vPiQRMXZFysoY1SOtH1jkbH0sAzVwmZzgu9BaQnnMOeGes+1uDIu2czI
         A0VzOgD18wZx5TELxdHru0YIXDky8W0y/AUghT+hz960Htad+iANhDsdnqCIa+etYU3b
         M5qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t2si6195823oth.58.2019.02.27.06.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 06:48:00 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1RElkZe097018
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:47:59 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qwva513kp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:47:59 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 27 Feb 2019 14:47:58 -0000
Received: from b03cxnp07029.gho.boulder.ibm.com (9.17.130.16)
	by e34.co.us.ibm.com (192.168.1.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 27 Feb 2019 14:47:55 -0000
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1RElsVb25428054
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 14:47:54 GMT
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 104E2C6057;
	Wed, 27 Feb 2019 14:47:54 +0000 (GMT)
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B6FC9C6055;
	Wed, 27 Feb 2019 14:47:50 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.199.49.135])
	by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP;
	Wed, 27 Feb 2019 14:47:50 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>,
        Alexey Kardashevskiy <aik@ozlabs.ru>,
        David Gibson <david@gibson.dropbear.id.au>,
        Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v8 0/4] mm/kvm/vfio/ppc64: Migrate compound pages out of CMA region
Date: Wed, 27 Feb 2019 20:17:32 +0530
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19022714-0016-0000-0000-00000989BC81
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010674; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01167143; UDB=6.00609716; IPR=6.00947752;
 MB=3.00025765; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-27 14:47:57
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022714-0017-0000-0000-00004249F18A
Message-Id: <20190227144736.5872-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-27_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=897 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902270100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ppc64 use CMA area for the allocation of guest page table (hash page table). We won't
be able to start guest if we fail to allocate hash page table. We have observed
hash table allocation failure because we failed to migrate pages out of CMA region
because they were pinned. This happen when we are using VFIO. VFIO on ppc64 pins
the entire guest RAM. If the guest RAM pages get allocated out of CMA region, we
won't be able to migrate those pages. The pages are also pinned for the lifetime of the
guest.

Currently we support migration of non-compound pages. With THP and with the addition of
 hugetlb migration we can end up allocating compound pages from CMA region. This
patch series add support for migrating compound pages. 

Changes from V7:
* update commit descrption for patch 3
* Address review feedback.
* Move PF_MEMALLOC_NOCMA to a different value.

Changes from V6:
* use get_user_pages_longterm instead of get_user_pages_cma_migrate()

Changes from V5:
* Add PF_MEMALLOC_NOCMA
* remote __GFP_THISNODE when allocating target page for migration

Changes from V4:
* use __GFP_NOWARN when allocating pages to avoid page allocation failure warnings.

Changes from V3:
* Move the hugetlb check before transhuge check
* Use compound head page when isolating hugetlb page



*** BLURB HERE ***

Aneesh Kumar K.V (4):
  mm/cma: Add PF flag to force non cma alloc
  mm: Update get_user_pages_longterm to migrate pages allocated from CMA
    region
  powerpc/mm/iommu: Allow migration of cma allocated pages during
    mm_iommu_do_alloc
  powerpc/mm/iommu: Allow large IOMMU page size only for hugetlb backing

 arch/powerpc/mm/mmu_context_iommu.c | 145 ++++++--------------
 include/linux/hugetlb.h             |   2 +
 include/linux/mm.h                  |   3 +-
 include/linux/sched.h               |   1 +
 include/linux/sched/mm.h            |  48 +++++--
 mm/gup.c                            | 200 ++++++++++++++++++++++++----
 mm/hugetlb.c                        |   4 +-
 7 files changed, 266 insertions(+), 137 deletions(-)

-- 
2.20.1

