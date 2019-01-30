Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE384C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:07:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6872820989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 06:07:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6872820989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1EC58E0002; Wed, 30 Jan 2019 01:07:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF5498E0001; Wed, 30 Jan 2019 01:07:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBFD48E0002; Wed, 30 Jan 2019 01:07:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B17EF8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:40 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id t18so27789452qtj.3
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 22:07:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=0D+s2jNU3+Hkn5caLHFSiVqagkMVRlZYitkr6YLPH5U=;
        b=KKLPpuY6w+AWDVP0wGx4Qj4ieMNPfHeThWgK+4sWvPumki4ydzDJu0IBxKoDXJw1xB
         guo6UqyeyyLVedUa3YFby2TmtX+p0vDtGsJ6zFSPgOhBQCpmUfDsAHfnQOUhn7YdlBT/
         lDmn2knL+gCqJGSZlKPtyQQTmXhcfIv8yhwSIgi7GSfZHnSJ1sZUc+vQndbzNLXoqKjG
         /+7vDttnfPwvSzlE7YpB3nR1bsfsb9yqKsHPUOJYdhtSsr7J2w+krF3yC4pSPn319qgb
         gJX4DEOvQBsymM/GuPaPTg4FTrd/l0rIuxpsHNRt+GIitaZDloHx6je1S3cWnbykVY4v
         4UOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukeacX5NojF3TariafZwVtaflSQvwPlPABvx8idN9bW1C1sMLdG/
	eE9ahVRrjxBcVyAjZJjHu02bxSjGvU/kt4rW2PKTepUbTDKRumxIOa1XBO64j+U/VxuKfEGsjKQ
	MvfssWqy20iXAqVZBZzSikf5I8IVML7wvWgymEL8Pwc5LiDdgvCqlz2eH4tn1Pg6Jeg==
X-Received: by 2002:ad4:41d0:: with SMTP id a16mr27256080qvq.55.1548828460481;
        Tue, 29 Jan 2019 22:07:40 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6i+SbzdbyIaLqUZMLnpND0gXakB3az7f6+ClRoQNnLgEWklA7KeH2Vw7k5o6bPZZyz5F4p
X-Received: by 2002:ad4:41d0:: with SMTP id a16mr27256046qvq.55.1548828459734;
        Tue, 29 Jan 2019 22:07:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548828459; cv=none;
        d=google.com; s=arc-20160816;
        b=GPGS/XjjuMcHCJq+rNq04a05Rg5bxrv2m3Piy3VFoq8MlyoCvw1nHMvqDtPQDxtQra
         I7RLtqYOIFLHh5vMnFb7y/FP6/FfvlhS7/sMhZEODMNIOumgNvIm/nU0Au21kMMXWe6D
         e9iPlaEMBotC9HArcarnJzoAas4h9pjm2go2VT4nqX26eRiQbU0YHYKKmIM3RztRpMvG
         YXEvY7gyUrfsPlp18rcECXLlKYn5arAUgFqjaP0iaiccLwAyxocLYj8nEDzF8wSvkgkp
         iqxNh3Ur2VWXrPKDiPmR+d4QcD6PzPZ666hIe7v8Y5wZhDXq1qAyNIUO7FSrFm2ezfxg
         6zNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=0D+s2jNU3+Hkn5caLHFSiVqagkMVRlZYitkr6YLPH5U=;
        b=iPOAPf5tlOIO4iwUUUTq4J7K+Ydkxilso1aSdPDM+Qx7/uZFrqHYaaJiLg3mtuAom2
         9S68snvSNinui3y6H6TJL/iUjb8ZPRQm3mLedx6xVZ8frcC3RlxtwIX58MdSfHtlDNrR
         O2QMkzubUqwWmoqMVDTUNFsm3p3w71sBC282CKTgN+1PaelL5rq8trFJuG34IkuWjL95
         kwU8fb0QCuqfmaZGCz2yXs28nQjGkpoTOihWBCnA7H8m+3Adb/1qo1suAzMvr5hLtz9M
         c4DYs/xvsdaUvvMQDVqSV9+MbohuBwAqq2yaMGZhb1a+KqptTIah5eEEEYkCiZTgQn20
         N1rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p42si123937qtc.174.2019.01.29.22.07.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 22:07:39 -0800 (PST)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0U64h1M031607
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:39 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qb672rjm9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:07:38 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Wed, 30 Jan 2019 06:07:37 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 30 Jan 2019 06:07:34 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0U67Wtw53411982
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 30 Jan 2019 06:07:32 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 745875204E;
	Wed, 30 Jan 2019 06:07:32 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.36.73])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id 5C48B52065;
	Wed, 30 Jan 2019 06:07:30 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [RFC PATCH v3 0/4] kvmppc: HMM backend driver to manage pages of secure guest
Date: Wed, 30 Jan 2019 11:37:22 +0530
X-Mailer: git-send-email 2.17.1
X-TM-AS-GCONF: 00
x-cbid: 19013006-4275-0000-0000-000003079FD1
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013006-4276-0000-0000-00003815A45C
Message-Id: <20190130060726.29958-1-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-30_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=798 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901300046
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

A pseries guest can be run as a secure guest on Ultravisor-enabled
POWER platforms. On such platforms, this driver will be used to manage
the movement of guest pages between the normal memory managed by
hypervisor (HV) and secure memory managed by Ultravisor (UV).

Private ZONE_DEVICE memory equal to the amount of secure memory
available in the platform for running secure guests is created
via a HMM device. The movement of pages between normal and secure
memory is done by ->alloc_and_copy() callback routine of migrate_vma().

The page-in or page-out requests from UV will come to HV as hcalls and
HV will call back into UV via uvcalls to satisfy these page requests.

These patches apply and work on the base Ultravisor patches posted by
Ram Pai at https://www.spinics.net/lists/kvm-ppc/msg14981.html

Changes in v3
=============
- Rebased to latest kernel
- Rebased on top of Ram's base Ultravisor patches, so that all the
  dependencies are met.
- Get secure memory size from device tree.
- Fix a mm struct leak in page-in and page-out hcalls, thereby
  allowing LPID recycling (Thanks to Sukadev Bhattiprolu for pointing
  this out)

v2: https://lists.ozlabs.org/pipermail/linuxppc-dev/2018-November/181669.html

Bharata B Rao (4):
  kvmppc: HMM backend driver to manage pages of secure guest
  kvmppc: Add support for shared pages in HMM driver
  kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
  kvmppc: Handle memory plug/unplug to secure VM

 arch/powerpc/include/asm/hvcall.h           |   9 +
 arch/powerpc/include/asm/kvm_book3s_hmm.h   |  45 ++
 arch/powerpc/include/asm/kvm_host.h         |  14 +
 arch/powerpc/include/asm/ucall-api.h        |  35 ++
 arch/powerpc/include/uapi/asm/uapi_uvcall.h |   5 +
 arch/powerpc/kvm/Makefile                   |   3 +
 arch/powerpc/kvm/book3s_hv.c                |  48 ++
 arch/powerpc/kvm/book3s_hv_hmm.c            | 559 ++++++++++++++++++++
 8 files changed, 718 insertions(+)
 create mode 100644 arch/powerpc/include/asm/kvm_book3s_hmm.h
 create mode 100644 arch/powerpc/kvm/book3s_hv_hmm.c

-- 
2.17.1

