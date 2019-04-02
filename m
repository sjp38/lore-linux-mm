Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F27FC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1095E2082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:44:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="3dhzuKoW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1095E2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F183D6B0277; Tue,  2 Apr 2019 16:44:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA5DC6B0278; Tue,  2 Apr 2019 16:44:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE91B6B0279; Tue,  2 Apr 2019 16:44:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9800A6B0277
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 16:44:25 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b131so7795854ywe.21
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 13:44:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=80amkJDfmO8rQR51MIz8k/sRGV6h3aL7PZ9G0VgPgaI=;
        b=XGQOlTEZP2T+rmqlfCbZIj+NHprWbO2STgDUS82JT+suTyzrocCWZGvQYKJgNeR+xT
         QJ6FlZrB0X+c3iS4AvISs8QDh5PwzZh85WEohIyfg36bQrgMu0az2a8y832K+u9Cb1gk
         p+6tXzNrUsUz9MIp0l+Fu80Y95tbA7UDhAeMuoSD/PvqOdxGR334jHxPDZZyApkp1F6Y
         fdVnr8rQohER1d93FYssmqlb5KqOsy7/wL41DIpHu8Tg+If8U/rKYEcCFg2dvcSxd7nn
         H1KGVnZzSBH+JO+JWJ32Thz2N9BoUBeiLLN4H/DBFJo0MH7MrURLDhQcfQFzgqbwe832
         yunQ==
X-Gm-Message-State: APjAAAWSY3V7MfBpfXd5Wu8Zl6nrH+iA6t7olunVTj5gwBaHGPzT3j1E
	YhV+DysrE+KfmdL6QQSQba695jb2omspJ4bGYUKxOOQoXyF02cXAUVDu2flqE82U2RVptF+XQoT
	ZYo2jE8zgSajzeA0+lSNvIP7zJrOEUrmE9cObHI7dS5SQ2x+FR+RXoOY+kceXjyQbxQ==
X-Received: by 2002:a25:f82:: with SMTP id 124mr60265977ybp.48.1554237865368;
        Tue, 02 Apr 2019 13:44:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqLsWYpaSqQvyzS1qlDbQHPeevE1NOnNQ2SZt+RCo5EMHcmn5g6UdvKLBepBtQFZd1DA54
X-Received: by 2002:a25:f82:: with SMTP id 124mr60265936ybp.48.1554237864628;
        Tue, 02 Apr 2019 13:44:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554237864; cv=none;
        d=google.com; s=arc-20160816;
        b=t6gCv8rkutSEDzXIgiIAMJRBB8YsuGaJjaDQFTBQfv93bkKvrwd8cEN4G/Hl0w4InU
         6EpVObdqoPetSTa89IhrcL/fEezQTCS0eS2MGfNC4lU4cKDX2Z5hKuRqvu5zezJXFhJb
         lDDtrBkxzOGKEC5tDO4b5fMWnoAq5pQLac2pPKZBLQYlw2WEj4hG7KGAQsXgDufWS98O
         EtihZpeRoToFU8elw/CGURCWd7BX/Nqp7b8jIEArd/XMsM0TOBPKpdhsR2U/e8lI1+Z+
         Ejuv7INyaX8xEny2uFDuEi0PVeHi5ikendczNvANV4uUAcc5HtjcMSjoXePLcQUxmmnj
         7n7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=80amkJDfmO8rQR51MIz8k/sRGV6h3aL7PZ9G0VgPgaI=;
        b=xjiC/d6ALECvAwyEIsMnBP2aRrXBc/bZEjKz7cVqExVI2WTIDQGhJQMiwnZhrndlbv
         A0c02f4JfCoPXLNu6ctrQG6dDHVm8wKaWOKBrVDCb3ItHmvEBWGte6j6vovic8x+5pgY
         vmckDZALE1hAdtJmEtc8Qajg2+6DpWeVOv6dfj3YAoyKUpO1KiKUOirIfbreMtqYJ+AE
         Ar84EsIIKkjT/+ZO+Hz2c6OIoMK2ls0LvwoEwiqnkDYL0vE3dOV3dURuOxLN/lzBdLfp
         7Ud0nJrfcU6JGDuGQzUTKTk6PViZm3i5hvwpnCKRNZE+qi2AyAvk0kwQsPFlRki1XlWW
         t/3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3dhzuKoW;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 81si8324536ywq.79.2019.04.02.13.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 13:44:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3dhzuKoW;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32Kd3B7163968;
	Tue, 2 Apr 2019 20:42:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=80amkJDfmO8rQR51MIz8k/sRGV6h3aL7PZ9G0VgPgaI=;
 b=3dhzuKoWxKS942ub9epZAEYv9lHvjtSKguDUksCdLymSkrm4017tbZP/McvSHb7vgphg
 HG1QB1Mh/DUs2M5kG4NtQfn/NpSXSuW/JfOB9deJC8CuMJJ6BXSKb4Dc9r/dk4bYPbkq
 P/R8IH1neNmPTMdwZ4cjHRaRJeCuYXwP8IRNDyEQHjd6RFituOicmQsVLgc6AzvOXMZ2
 073tkjOQNg/UWN0G0z2uEi3ss0M9iEeF0pZfTmw0omvIW/7BX9PB9k1EJnV7GNRcOyGz
 bftpAc2WL/XOoenSSKb/on4FvPH4QftOeOijD0L4mkW56CTL89av5zBJx06UQWAi81s4 +A== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2rj0dnkyvd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:42:13 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32KfG0w064769;
	Tue, 2 Apr 2019 20:42:12 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2rm8f4yjxx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:42:12 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x32Kg9r8029935;
	Tue, 2 Apr 2019 20:42:09 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 02 Apr 2019 13:42:09 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: akpm@linux-foundation.org
Cc: daniel.m.jordan@oracle.com, Alan Tull <atull@kernel.org>,
        Alexey Kardashevskiy <aik@ozlabs.ru>,
        Alex Williamson <alex.williamson@redhat.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Lameter <cl@linux.com>, Davidlohr Bueso <dave@stgolabs.net>,
        Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
        Paul Mackerras <paulus@ozlabs.org>, Wu Hao <hao.wu@intel.com>,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 0/6] convert locked_vm from unsigned long to atomic64_t
Date: Tue,  2 Apr 2019 16:41:52 -0400
Message-Id: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904020138
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904020138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

From patch 1:

  Taking and dropping mmap_sem to modify a single counter, locked_vm, is
  overkill when the counter could be synchronized separately.
  
  Make mmap_sem a little less coarse by changing locked_vm to an atomic,
  the 64-bit variety to avoid issues with overflow on 32-bit systems.

This is a more conservative alternative to [1] with no user-visible
effects.  Thanks to Alexey Kardashevskiy for pointing out the racy
atomics and to Alex Williamson, Christoph Lameter, Ira Weiny, and Jason
Gunthorpe for their comments on [1].

Davidlohr Bueso recently did a similar conversion for pinned_vm[2].

Testing
 1. passes LTP mlock[all], munlock[all], fork, mmap, and mremap tests in an
    x86 kvm guest
 2. a VFIO-enabled x86 kvm guest shows the same VmLck in
    /proc/pid/status before and after this change
 3. cross-compiles on powerpc

The series is based on v5.1-rc3.  Please consider for 5.2.

Daniel

[1] https://lore.kernel.org/linux-mm/20190211224437.25267-1-daniel.m.jordan@oracle.com/
[2] https://lore.kernel.org/linux-mm/20190206175920.31082-1-dave@stgolabs.net/

Daniel Jordan (6):
  mm: change locked_vm's type from unsigned long to atomic64_t
  vfio/type1: drop mmap_sem now that locked_vm is atomic
  vfio/spapr_tce: drop mmap_sem now that locked_vm is atomic
  fpga/dlf/afu: drop mmap_sem now that locked_vm is atomic
  powerpc/mmu: drop mmap_sem now that locked_vm is atomic
  kvm/book3s: drop mmap_sem now that locked_vm is atomic

 arch/powerpc/kvm/book3s_64_vio.c    | 34 ++++++++++--------------
 arch/powerpc/mm/mmu_context_iommu.c | 28 +++++++++-----------
 drivers/fpga/dfl-afu-dma-region.c   | 40 ++++++++++++-----------------
 drivers/vfio/vfio_iommu_spapr_tce.c | 37 ++++++++++++--------------
 drivers/vfio/vfio_iommu_type1.c     | 31 +++++++++-------------
 fs/proc/task_mmu.c                  |  2 +-
 include/linux/mm_types.h            |  2 +-
 kernel/fork.c                       |  2 +-
 mm/debug.c                          |  5 ++--
 mm/mlock.c                          |  4 +--
 mm/mmap.c                           | 18 ++++++-------
 mm/mremap.c                         |  6 ++---
 12 files changed, 89 insertions(+), 120 deletions(-)


base-commit: 79a3aaa7b82e3106be97842dedfd8429248896e6
-- 
2.21.0

