Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8F6DC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54C562080C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54C562080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD1B76B0003; Thu, 20 Jun 2019 05:17:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5B308E0002; Thu, 20 Jun 2019 05:17:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D41A8E0001; Thu, 20 Jun 2019 05:17:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 528886B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:17:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x18so1612211pfj.4
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 02:17:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=mlof7Y82mScWCXP0ezqjFFy0phQ3/0dtFpnOxyU9W3E=;
        b=JjKJc21W3j1NcfdhlxidbR/LwRtICib8ZxC1sgYHOV769PE22J0NZWvR5lykAfLrdU
         HE2pnfBtMl7DD/vEcLchw+iHuLuWIQ6FtDS4W9A3yCorkYD8v/u2oD7d6SQzgkLpGy99
         0Mf7QeeZmw8NW7AnBgwnZnFwfMIt20P5cx8BlpwVz47Lf5UeBiQ7ccjF2wHijF++77Y7
         UY84bLdLTYm49rOOXMIyOeWbuy49pbxCin/ydis4GHg3/2uekRdPVkzrgkEvPEljbgfQ
         4EYgYnC8RKzKxNeYjJZE3tkBB3JDZbSMIaLUT6eCjsEHWVrjTro3gsuHQBfNhbIZmGq1
         iYUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVYXu5TglK1YvzvTMISNcjFsMunBdd4BglEELTYtVzawUOYmU+b
	SHMGpqiNhPSW+yrRoxY0pzPYZyF+TEOEDM29p+55ALuxrDVDpqHCTF1Noy3QMylzo2nzOQ+zbfw
	YQzFGoFdiTxTySbn7xSBMmojDUvFI2mOpEyPgy0QuH12yhgTQG8Ycm31d6EP6Nbde7A==
X-Received: by 2002:a65:408d:: with SMTP id t13mr11973845pgp.373.1561022235900;
        Thu, 20 Jun 2019 02:17:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTGmd7PG+fZKU7KMfIN4UXaKi/4iLcTLU4ZSmyCUPJi4HSvKVvCwxn0ZubcyIHUwCsz6y8
X-Received: by 2002:a65:408d:: with SMTP id t13mr11973793pgp.373.1561022235089;
        Thu, 20 Jun 2019 02:17:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561022235; cv=none;
        d=google.com; s=arc-20160816;
        b=DOWsc1nzEdv6IrgehXibHm+PwzAfMprVRg/6i5/8hYQQTvBlIDsT4IaVeCfwf5K5gq
         M1mwuZW6Ple4mU6hUIGiR9JphfwuDqOaHstO+OS4aqpOdZeOgvCfP6lhRzzSwhNi+OlP
         ZdSFxbI7FLQpj35T0izsKdkY74AHLvzQdhDFIxwy4T6OsgtwN8wrJwkvUIvk62VSzXv9
         bcqEIkrfxr4Br2SdHYOT4d5hLam6IE2kX1oaWFoE3UOyRn01vaFC0R1U9gBZa6GOqXsR
         YF2sZ6Yf/cazEjUz1rP7Guk58kmxsyjhQfZOOncLG6TC1j9TnqWQ19T4KyHogh+4uPJr
         JmnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=mlof7Y82mScWCXP0ezqjFFy0phQ3/0dtFpnOxyU9W3E=;
        b=uNghlS/YfCu/JshK2NcP3ETF1MjvYy55E7d/cqpFuzc79fKx4i/ghte435M1cg1Yy6
         D2F90muG33PQP/0uMdr2aJ7ymtHod+axYurUyTQK2AeXqSlrLywRU2KeE/NWlFd9vIVp
         BtUYR/vFrZtA2RuCG1tUDxLP1Ma5MRScBB11DONdbTHGbcjh1NYmJmtXEO/0hWMpDG3e
         CYE5013mo2ZGps1WLQUSERaIlSE+JcjPv3+zKD2WO2FF3+HjUm7HyiKQ9a1oj2Mf8jfM
         i4MgmYAlEk4avpzcbnb0zDIQ+qZTgpUx5e6jbG854qChHtoncNgA/TkiPxVqcLT2zIXI
         OZzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 14si5612327pgl.594.2019.06.20.02.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 02:17:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5K9DqMs019188
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:17:14 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t87b3g445-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:17:14 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 20 Jun 2019 10:17:13 +0100
Received: from b01cxnp22036.gho.pok.ibm.com (9.57.198.26)
	by e11.ny.us.ibm.com (146.89.104.198) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 20 Jun 2019 10:17:10 +0100
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5K9H9aw35389804
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 09:17:09 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A4140AE05C;
	Thu, 20 Jun 2019 09:17:09 +0000 (GMT)
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 23904AE063;
	Thu, 20 Jun 2019 09:17:08 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.143])
	by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 20 Jun 2019 09:17:07 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v4 0/6] Fixes related namespace alignment/page size/big endian
Date: Thu, 20 Jun 2019 14:46:20 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19062009-2213-0000-0000-000003A20120
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011296; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01220629; UDB=6.00642131; IPR=6.01001767;
 MB=3.00027390; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-20 09:17:12
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19062009-2214-0000-0000-00005EED0B0C
Message-Id: <20190620091626.31824-1-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=887 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200068
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series handle configs where hugepage support is not enabled by default.
Also, we update some of the information messages to make sure we use PAGE_SIZE instead
of SZ_4K. We now store page size and struct page size in pfn_sb and do extra check
before enabling namespace. There also an endianness fix.

The patch series is on top of subsection v10 patchset

http://lore.kernel.org/linux-mm/156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com

Changes from V3:
* Dropped the change related PFN_MIN_VERSION
* for pfn_sb minor version < 4, we default page_size to PAGE_SIZE instead of SZ_4k.

Aneesh Kumar K.V (6):
  nvdimm: Consider probe return -EOPNOTSUPP as success
  mm/nvdimm: Add page size and struct page size to pfn superblock
  mm/nvdimm: Use correct #defines instead of open coding
  mm/nvdimm: Pick the right alignment default when creating dax devices
  mm/nvdimm: Use correct alignment when looking at first pfn from a
    region
  mm/nvdimm: Fix endian conversion issues 

 arch/powerpc/include/asm/libnvdimm.h |  9 ++++
 arch/powerpc/mm/Makefile             |  1 +
 arch/powerpc/mm/nvdimm.c             | 34 +++++++++++++++
 arch/x86/include/asm/libnvdimm.h     | 19 +++++++++
 drivers/nvdimm/btt.c                 |  8 ++--
 drivers/nvdimm/bus.c                 |  4 +-
 drivers/nvdimm/label.c               |  2 +-
 drivers/nvdimm/namespace_devs.c      | 13 +++---
 drivers/nvdimm/nd-core.h             |  3 +-
 drivers/nvdimm/nd.h                  |  6 ---
 drivers/nvdimm/pfn.h                 |  5 ++-
 drivers/nvdimm/pfn_devs.c            | 62 ++++++++++++++++++++++++++--
 drivers/nvdimm/pmem.c                | 26 ++++++++++--
 drivers/nvdimm/region_devs.c         | 27 ++++++++----
 include/linux/huge_mm.h              |  7 +++-
 kernel/memremap.c                    |  8 ++--
 16 files changed, 194 insertions(+), 40 deletions(-)
 create mode 100644 arch/powerpc/include/asm/libnvdimm.h
 create mode 100644 arch/powerpc/mm/nvdimm.c
 create mode 100644 arch/x86/include/asm/libnvdimm.h

-- 
2.21.0

