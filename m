Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7FEDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:59:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F05D218EA
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:59:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F05D218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 295F18E0002; Thu, 14 Feb 2019 10:59:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2453F8E0001; Thu, 14 Feb 2019 10:59:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10D748E0002; Thu, 14 Feb 2019 10:59:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D89FB8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:49 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k1so6070903qta.2
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 07:59:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=uzhSBb1HAXHtCDsdGH/xBua0y4IP2Fa13wIphus4x+A=;
        b=AORvcBtSfgEDqLab8+2B0800fL8TGIJozUA0t0FwdSQ2LUq4TALHMtclo6U6GfIOYM
         KdoLOFpVPsF4cFRIXWpFeBAFP6OwB5nmPrY75TVCE7Hait/yWTeKvyhX9p+6xP5aTE3A
         Q1AdOAWT7ZRop9nZOG3G4MaYpWrkjKAC9skDt3zlQyKQFgEumb3TyaHw8DWfYBQSegju
         DnccRHrjVQFzT8CFZgz6b/dDhVfMsY6wO5qWu/cdIBafMyI8TNtbeWZdzc1h3TfOjq4u
         2JVzk5O8ocx7Ee2MI6VhesdflmrgXwRFbHte1kPNkBxDwQFYoaBP550+UAuzH1dm5MLl
         OLCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZ7Y8eEvcq9KxorGFg+eFxrG2asGs2Wzzivzfr+cEJ7Q8S0xNUS
	OSkYG0MAKbMmLPV+fl35VDrWCXfm27itZjdjqqMraJpJxr62RtEP8jHqR48xAk4/505zMFw8TPI
	QzjPwjUT5Z4x37nsJy8MIDCqfqGbNxIguQ6lJL91N1XmCfyexwr3OHWgmpkaDix1rfQ==
X-Received: by 2002:a05:620a:1036:: with SMTP id a22mr3490379qkk.324.1550159989552;
        Thu, 14 Feb 2019 07:59:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia0N+lUWx0D3JtqWPMBIPV5+S4ZqCXG+kXuqdc+0TZfGmU57bgoY0Bvd+HToikNkQwM/cns
X-Received: by 2002:a05:620a:1036:: with SMTP id a22mr3490352qkk.324.1550159988931;
        Thu, 14 Feb 2019 07:59:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550159988; cv=none;
        d=google.com; s=arc-20160816;
        b=rzduE9ffMfCXRUt2p7Mr1rklT+n4ew+z+x31F5f+Opf91CNRKHrmAwq2Qcwj2D6N86
         B5TVzIL1sCTcJuFJqw2ptkKzFc2IEX2f+9GFGn1Dg5B6fkN17xNYs7qqwCpHj1MM3osF
         PpMUY4vrXS3R+uuqfiqZrso2LOs8S8bruksbslmkr8o6sfgdetx+6J1ebXQvubNrIHzo
         F4Om07yxUtzYdIMSCSw7hdrjef60CuBszj1FapE+JX6co6AiAo8qg4LkrbgpZWTFv5L2
         dndgSRvJGX9tiu+3OMS12U7CwFjbUtm5TNfCo2DFbjN5i9Et9QSI4nCgvqElKlmmxFej
         JLgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=uzhSBb1HAXHtCDsdGH/xBua0y4IP2Fa13wIphus4x+A=;
        b=zfkvH5pJnXs+uExCF4rBkiIv5B7gC4fqgu43eq5X80DT+eOFPRmYLwvgNkChtvatXT
         mVjwFpTC/+Qy9DP+6EOJlxDQLARMOodTOpCWAxS4s5GLUDKu+ix1DXPdWsPHebJWJtMJ
         eZ6UpcQ/PttkoSsawbi1QCkhhw0uV3kMTWU3o3vxMGPTD9pr6tLJdIRAGdwxHvhI50mb
         NWdX0l0nGbQsHlUJ2dBcjwvm2j/muG0oTSzadG3MZqtdAZrBU7zQp5QJXk42pUzNzrw2
         Ouwt6jZJIDexH7z6PfIw5wBW3rpzfdHP9MH2t2eexdOgoYVyO5WT9ivkS5v8lA055s73
         3j3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h1si1013340qkj.187.2019.02.14.07.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 07:59:48 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1EFhhvu057130
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:48 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qnavqb4c5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:47 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 14 Feb 2019 15:59:46 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 15:59:41 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1EFxeFs24379450
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 14 Feb 2019 15:59:40 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A434FAE063;
	Thu, 14 Feb 2019 15:59:40 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E2C0CAE058;
	Thu, 14 Feb 2019 15:59:38 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 14 Feb 2019 15:59:38 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 14 Feb 2019 17:59:38 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
        Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-riscv@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 0/4] provide a generic free_initmem implementation
Date: Thu, 14 Feb 2019 17:59:33 +0200
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19021415-0028-0000-0000-0000034898F4
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021415-0029-0000-0000-00002406C565
Message-Id: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=786 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140109
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000115, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Many architectures implement free_initmem() in exactly the same or very
similar way: they wrap the call to free_initmem_default() with sometimes
different 'poison' parameter.

These patches switch those architectures to use a generic implementation
that does free_initmem_default(POISON_FREE_INITMEM).

This was inspired by Christoph's patches for free_initrd_mem [1] and I
shamelessly copied changlog entries from his patches :)

[1] https://lore.kernel.org/lkml/20190213174621.29297-1-hch@lst.de/

Mike Rapoport (4):
  init: provide a generic free_initmem implementation
  hexagon: switch over to generic free_initmem()
  init: free_initmem: poison freed init memory
  riscv: switch over to generic free_initmem()

 arch/alpha/mm/init.c      |  6 ------
 arch/arc/mm/init.c        |  8 --------
 arch/c6x/mm/init.c        |  5 -----
 arch/h8300/mm/init.c      |  6 ------
 arch/hexagon/mm/init.c    | 10 ----------
 arch/microblaze/mm/init.c |  5 -----
 arch/nds32/mm/init.c      |  5 -----
 arch/nios2/mm/init.c      |  5 -----
 arch/openrisc/mm/init.c   |  5 -----
 arch/riscv/mm/init.c      |  5 -----
 arch/sh/mm/init.c         |  5 -----
 arch/sparc/mm/init_32.c   |  5 -----
 arch/unicore32/mm/init.c  |  5 -----
 arch/xtensa/mm/init.c     |  5 -----
 init/main.c               |  5 +++++
 15 files changed, 5 insertions(+), 80 deletions(-)

-- 
2.7.4

