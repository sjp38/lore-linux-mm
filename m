Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E342C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:27:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5212021908
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:27:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5212021908
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8C118E0031; Thu,  7 Feb 2019 09:27:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3A4F8E0002; Thu,  7 Feb 2019 09:27:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D51528E0031; Thu,  7 Feb 2019 09:27:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9231C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 09:27:36 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o17so5011pgi.14
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 06:27:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ljCLIfqHtld8sRzsi248Ov3Ic3FgnEx3WaWhMLBlOGc=;
        b=bsaE9W0gEnp/ToOExKDG9HIzUUofjhlfCJ5v1Sq2NLBy5Add0mf5pQW+Sz/6cinHds
         DO498k1RYSdS6hB/tWalvIMg0sKEPmcUE0L9cf1umoe7Yw6owAo2pjaGO9556le3VKc6
         QA1oa7+UhMCt7iK0Sk/2s2uGU2tEdoP31CwqRIwQR5TjzghfdVW7zU+l5bVcivMuafUH
         SlXNhaVbQtYnN8fAc3BaMs0CphXBZ0lRaUItxfdlcHNvZUDfeJNpvyKVoZnDenaxcbm6
         34GGnk0qaAM1pSNvDhvP+r4MkT/sIWaSicChGlLPWiWBFc0xqHGtoL9CBuIpSeGzZNi+
         c4ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuYk7bYwgM06pkEyA1Zwhq2NFZ6Y/mc7+jMba8+m3G+jSCfAXYqx
	DrCgyqXsLQsbrAZ93v0KDhZ2pYlWNCJBrklfuul0lkC1Q7mEn4iLicFdhE0ZxbhM3H9z0g8BBen
	3N8ERD4wIPycCJnzQ85cYVoczqXSEXSZtOk5m0oHObiMCBhKbaruFp0Wc+ealHe65QA==
X-Received: by 2002:a17:902:282a:: with SMTP id e39mr16855013plb.26.1549549656261;
        Thu, 07 Feb 2019 06:27:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IauYFbxcDxpxfOYuzuWRiyccYDJNMQrJlVMMIxueAg/G7BaSdsrOPUIc6HGmWpwdcBMLd5U
X-Received: by 2002:a17:902:282a:: with SMTP id e39mr16854962plb.26.1549549655490;
        Thu, 07 Feb 2019 06:27:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549549655; cv=none;
        d=google.com; s=arc-20160816;
        b=NvVH/aq0Qv3h95s7uwZF10HQ+hDWgslmKMbN5xlHGZuhFrtQVIB+kd2v5kRK3I/3QV
         4O1WSNFy6iLRcVqzizPTeiTRfoLtPBXVlfYkSLyUBaaqFCAToZ5WUfUejoSBtc4X593Y
         CVdzwKS8WdYAtwEoxuO4XFIRav4ylZwLDV2yeHHU/sCu9CnUdBfHykHS2yb/IGemLQIq
         V0Jc8g6ds05Y8NMmBCI6mIsuVFyvx7GZ8upIcviBS7Zt50sFm7VAggsmRrshPhMgraft
         7W+jt22s4hMqygF9Hcs4MV55EQUBcqKc/JT0VmNs08pBD6FXLeY3gdtgqLcBsvuxQbh4
         BVjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ljCLIfqHtld8sRzsi248Ov3Ic3FgnEx3WaWhMLBlOGc=;
        b=Fi27Fe1Jkbyy6b3OgKWnAMSc1qC+IieGm8Av6bAUDdOiXcY+oSxOLVGWzUBMYP2GA/
         aluQDqyW9nDAxzHCOEYDG9FvTQcNt2YD0Lt1Z78n/Jp5I+MaLbdOu8EvBi9bM699d9cn
         FsPXHwyDayWelzKMbmSnluR/0wEM+s5yHyU01RDhGlOwiaQ1O+6tNZ30wfrVFUejs9tI
         fo3OmiGRLhDNFHBHxUcE1zXr2x8xAvqygPkKkdHc24tqoE7RwVL/yAB0bldNeTkAttrk
         jFRDacm8CmKr+Tk/r7C2vCMm9EvRa5UQmllNRYFg5zqIWpB6LojcwUQGANAevmceolG9
         nofA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r8si1126249plo.203.2019.02.07.06.27.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 06:27:35 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x17EH6rC108635
	for <linux-mm@kvack.org>; Thu, 7 Feb 2019 09:27:34 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qgpa1gj8h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 07 Feb 2019 09:27:34 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 7 Feb 2019 14:27:31 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 7 Feb 2019 14:27:28 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x17ERRhf5505452
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 7 Feb 2019 14:27:27 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C847B42047;
	Thu,  7 Feb 2019 14:27:27 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5272D4203F;
	Thu,  7 Feb 2019 14:27:26 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  7 Feb 2019 14:27:26 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 07 Feb 2019 16:27:25 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [RESEND PATCH 0/3] docs/core-api/mm: fix return value descriptions
Date: Thu,  7 Feb 2019 16:27:21 +0200
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19020714-0016-0000-0000-00000253A4C2
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020714-0017-0000-0000-000032ADB365
Message-Id: <1549549644-4903-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-07_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=990 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902070111
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Many kernel-doc comments referenced by Documentation/core-api/mm-api.rst
have the return value descriptions misformatted or lack it completely. This
makes kernel-doc script unhappy and produces more than 100 warnings when
running 

	make htmldocs V=1

These patches fix the formatting of present return value descriptions and
add some new ones.

As these patches touch lots of mm/ files, I think it's better to merge them
via -mm tree.

Side note:
----------
I've noticed that kernel-doc produces

	warning: contents before sections

when it is parsing description of a function that has no parameters, but
does have a return value, i.e.

	unsigned long nr_free_buffer_pages(void)

As far as I can tell, the generated html is ok no matter if the detailed
description present before 'the sections', so probably this warning is not
really needed?

Mike Rapoport (3):
  docs/mm: vmalloc: re-indent kernel-doc comemnts
  docs/core-api/mm: fix user memory accessors formatting
  docs/core-api/mm: fix return value descriptions in mm/

 arch/x86/include/asm/uaccess.h |  24 +--
 arch/x86/lib/usercopy_32.c     |   8 +-
 mm/dmapool.c                   |  13 +-
 mm/filemap.c                   |  73 ++++++--
 mm/memory.c                    |  26 ++-
 mm/mempool.c                   |   8 +
 mm/page-writeback.c            |  24 ++-
 mm/page_alloc.c                |  24 ++-
 mm/readahead.c                 |   2 +
 mm/slab.c                      |  14 ++
 mm/slab_common.c               |   6 +
 mm/truncate.c                  |   6 +-
 mm/util.c                      |  37 ++--
 mm/vmalloc.c                   | 394 ++++++++++++++++++++++-------------------
 14 files changed, 409 insertions(+), 250 deletions(-)

-- 
2.7.4

