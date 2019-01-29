Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABB7AC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:27:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6739921473
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:27:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6739921473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=il.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18F148E0005; Tue, 29 Jan 2019 08:27:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1405C8E0001; Tue, 29 Jan 2019 08:27:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F24B68E0005; Tue, 29 Jan 2019 08:27:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF37F8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:27 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id bj3so14197579plb.17
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:27:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:content-transfer-encoding:mime-version;
        bh=KNQuQ/i6LpP4YiHQCU3plyBpvSk35G6uUsMS+en535k=;
        b=OCHNvE9wBG87vko/zIsuWOpp6mVej2Ii9CMXmOV0cjl5nmAW6tGVApb95OdQwoQt42
         szTzMTDh8ESvngZ0/MWXHCeBtp09+kysBYMaX/WvLJogZdZprXpqxu6UgmVsnK/yOO0S
         r3LAIXXv1RqXkPkrFzHn9BEDFrqdcDXJeHNz8VMGOCPgAhqBAyI0RNa+mB2+SkRq+bBF
         bRryDEAWQBP7yiFnGr2M1pO662GDGivV49xvU0C1wwXKpVymtoIDW2hf1NZeoI1s0ehV
         TSqxUU3qKbtYV4gu7RNqR/S5PAvS6uJtpTkVMGZ2fsOSWlH+Stb06DCsgljqWxU6Rdrm
         4UbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukfBa7Z25Se9LfjZQtNwnSQowU8Wh3yesrO68GU++ydfkfqjdOGB
	QbyP8Auf/tXpV1TTuZ069r2/Jz3+Ciqg2MbGPyaiYhykaOvJ8TAYdbp7ZiHkla/LRCCbAQckEeM
	2Sg6NhEMZZe/Y4f6d3iQ8rhqX26AZeO3ycsT06I6mvyxnpQnBjxt+anE6DRjth6j1Hg==
X-Received: by 2002:a17:902:145:: with SMTP id 63mr25872498plb.256.1548768447388;
        Tue, 29 Jan 2019 05:27:27 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4IOz46yc0OuO3IrwHCMo7dHW/OAychbk/gcP/rfUN/aJsSTAjDGzJa4mRqMbUdHDoj/OZh
X-Received: by 2002:a17:902:145:: with SMTP id 63mr25872461plb.256.1548768446709;
        Tue, 29 Jan 2019 05:27:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548768446; cv=none;
        d=google.com; s=arc-20160816;
        b=edTa/BKJbRF9g7zThXGc3v9iiyA2UX+P9tT1I0chU3poe6qmTft703pKdS+H2hBRkG
         nhnNeGdGZeP87FgdeYgTj0JLTEsCRtZF3GHZatWszMoVYatgJ8LSJbmGmMFZS3rsBxIn
         OQEnQiEL7CF7tbaoEAObUFxGdqTmk+KzjmCrsT12GhFzHzzDmFDRqk5KUjdWkPWXJNuU
         lv8iB78aUJbNeVHFEV6ZiF5F869o94OGc0V6ZXmnC7Gpi+tYVrVEDS33l6K23TvrT9Bh
         QPMJp0wb4unyV+RQ2dlMiVMOqTdVX1rJtCyHT8tk8u4iDZ+s3JNX4vohzlksD4RpPW1m
         9jKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:message-id:date:subject:cc
         :to:from;
        bh=KNQuQ/i6LpP4YiHQCU3plyBpvSk35G6uUsMS+en535k=;
        b=P472bPMm1JeITVsfn78u7aMPLZc65oNuuuE4ltVSTR4fyLA8UVnVKm5almqh0i3ptQ
         ja4Nc4DIXdC2574OM9A4ssmX86GDTyO8Z3iazpkn06oe2CZE8udNmt9h+315Oq/GRmJX
         /8NFwpU5vUsMr5Pi9/fwXZXaM/imeWdw8Eaht8rH6TXLvwtc/dufNrrg0iP0OJRvYaKw
         nuCXRxqYC0pzWpPGptHRSo/HULxf01RmvoaHcxpZ5w7yXDA0NoEfD7g7UcoL3jGy1AIU
         AXtAwEx3xMVH/1W39dn7uVOMvTDL1W/9wDkY2ZjRPulSAAXXiQgt4vAwRUppw53k7JLp
         xHaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d40si11879824pla.427.2019.01.29.05.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 05:27:26 -0800 (PST)
Received-SPF: pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0TDKkgu062964
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:26 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qamdd3a3n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:22 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <joeln@il.ibm.com>;
	Tue, 29 Jan 2019 13:26:53 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 29 Jan 2019 13:26:50 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0TDQmEw46727234
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 29 Jan 2019 13:26:48 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9B432A404D;
	Tue, 29 Jan 2019 13:26:48 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 03E10A4040;
	Tue, 29 Jan 2019 13:26:47 +0000 (GMT)
Received: from tal (unknown [9.148.32.96])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 29 Jan 2019 13:26:46 +0000 (GMT)
Received: by tal (sSMTP sendmail emulation); Tue, 29 Jan 2019 15:26:46 +0200
From: Joel Nider <joeln@il.ibm.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Leon Romanovsky <leon@kernel.org>, Doug Ledford <dledford@redhat.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Joel Nider <joeln@il.ibm.com>,
        linux-mm@kvack.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 0/5] RDMA: reg_remote_mr
Date: Tue, 29 Jan 2019 15:26:21 +0200
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19012913-0008-0000-0000-000002B77689
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19012913-0009-0000-0000-00002223B946
Message-Id: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-29_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=707 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901290101
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As discussed at LPC'18, there is a need to be able to register a memory
region (MR) on behalf of another process. One example is the case of
post-copy container migration, in which CRIU is responsible for setting
up the migration, but the contents of the memory are from the migrating
process. In this case, we want all RDMA READ requests to be served by
the address space of the migration process directly (not by CRIU). This
patchset implements a new uverbs command which allows an application to
register a memory region in the address space of another process.

Joel Nider (5):
  mm: add get_user_pages_remote_longterm function
  RDMA/uverbs: add owner parameter to reg_user_mr
  RDMA/uverbs: add owner parameter to ib_umem_get
  RDMA/uverbs: add owner parameter to ib_umem_odp_get
  RDMA/uverbs: add UVERBS_METHOD_REG_REMOTE_MR

 drivers/infiniband/core/umem.c                |  26 ++++--
 drivers/infiniband/core/umem_odp.c            |  50 +++++-----
 drivers/infiniband/core/uverbs_cmd.c          |   2 +-
 drivers/infiniband/core/uverbs_std_types_mr.c | 129 +++++++++++++++++++++++++-
 drivers/infiniband/hw/bnxt_re/ib_verbs.c      |  11 ++-
 drivers/infiniband/hw/bnxt_re/ib_verbs.h      |   1 +
 drivers/infiniband/hw/cxgb3/iwch_provider.c   |   6 +-
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h        |   1 +
 drivers/infiniband/hw/cxgb4/mem.c             |   6 +-
 drivers/infiniband/hw/hns/hns_roce_cq.c       |   2 +-
 drivers/infiniband/hw/hns/hns_roce_db.c       |   2 +-
 drivers/infiniband/hw/hns/hns_roce_mr.c       |   4 +-
 drivers/infiniband/hw/hns/hns_roce_qp.c       |   2 +-
 drivers/infiniband/hw/hns/hns_roce_srq.c      |   2 +-
 drivers/infiniband/hw/i40iw/i40iw_verbs.c     |   3 +-
 drivers/infiniband/hw/mlx4/cq.c               |   2 +-
 drivers/infiniband/hw/mlx4/doorbell.c         |   2 +-
 drivers/infiniband/hw/mlx4/mlx4_ib.h          |   1 +
 drivers/infiniband/hw/mlx4/mr.c               |   3 +-
 drivers/infiniband/hw/mlx4/qp.c               |   2 +-
 drivers/infiniband/hw/mlx4/srq.c              |   2 +-
 drivers/infiniband/hw/mlx5/cq.c               |   4 +-
 drivers/infiniband/hw/mlx5/devx.c             |   2 +-
 drivers/infiniband/hw/mlx5/doorbell.c         |   2 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h          |   4 +-
 drivers/infiniband/hw/mlx5/mr.c               |  17 ++--
 drivers/infiniband/hw/mlx5/odp.c              |  11 ++-
 drivers/infiniband/hw/mlx5/qp.c               |   4 +-
 drivers/infiniband/hw/mlx5/srq.c              |   2 +-
 drivers/infiniband/hw/mthca/mthca_provider.c  |   5 +-
 drivers/infiniband/hw/nes/nes_verbs.c         |   5 +-
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.c   |   6 +-
 drivers/infiniband/hw/ocrdma/ocrdma_verbs.h   |   3 +-
 drivers/infiniband/hw/qedr/verbs.c            |   8 +-
 drivers/infiniband/hw/usnic/usnic_ib_verbs.c  |   1 +
 drivers/infiniband/hw/usnic/usnic_ib_verbs.h  |   1 +
 drivers/infiniband/hw/vmw_pvrdma/pvrdma_cq.c  |   2 +-
 drivers/infiniband/hw/vmw_pvrdma/pvrdma_mr.c  |   2 +-
 drivers/infiniband/hw/vmw_pvrdma/pvrdma_qp.c  |   5 +-
 drivers/infiniband/hw/vmw_pvrdma/pvrdma_srq.c |   2 +-
 drivers/infiniband/sw/rdmavt/mr.c             |   3 +-
 drivers/infiniband/sw/rdmavt/mr.h             |   1 +
 drivers/infiniband/sw/rxe/rxe_mr.c            |   3 +-
 drivers/infiniband/sw/rxe/rxe_verbs.c         |   4 +-
 include/linux/mm.h                            |  28 +++++-
 include/rdma/ib_umem.h                        |   3 +-
 include/rdma/ib_umem_odp.h                    |   6 +-
 include/rdma/ib_verbs.h                       |   9 ++
 include/uapi/rdma/ib_user_ioctl_cmds.h        |  13 +++
 mm/gup.c                                      |  15 ++-
 50 files changed, 327 insertions(+), 103 deletions(-)

-- 
2.7.4

