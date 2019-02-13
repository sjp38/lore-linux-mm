Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBD00C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2BBB222A4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2BBB222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1F018E0001; Wed, 13 Feb 2019 18:05:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA9E98E0012; Wed, 13 Feb 2019 18:05:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A214E8E0001; Wed, 13 Feb 2019 18:05:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB288E0012
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 18:05:32 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o9so2761945pgv.19
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:05:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NxuweNm4GxL/BoOqBVX9oI0qswOBhm+J5hpwG3wNYwI=;
        b=IcwLcFOd9qjT13b3RfkHHohn0NIJ8njVUxTctrzLZnha7rc71ir1G6SNuj4ca4idbi
         sd1NczlAkyCvvWhpE0qo2a3TpvQLUN6CTlkN8S0kVQuL7/hPhvgcZPE8ZrRwrZTjwJOf
         o6QZ+fR2kAR/ize1GbcpS6T1z+8Kv0YezdHxBvu2dt5ZvZ9lPCnCR2n+uAypmCLnGkqX
         FgtzekLaXtx4kbCKprB3R8rSm2ZC9EvoVQDoLZylYLlUShsoN2yeFVXKp+dx1kyNpJMw
         96SmShhExJICaQvUm0g6WF8eHTN08Z9lGVm+UAjPLzgVcRvcvWqyxA286ATNVzjp5KWf
         dxgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZsaff82gtQQfjyI4ReHSAGNg8HxXvQ6fDA9URaVk+ruLF2UcYP
	TXPBubpHZJLz+OtZshvrRZpMsrdR1hiW4gUX5g2CYk7cPHW94rzxSlRSZg581NwpeGglMt18u8O
	aQWEZZtrpC2wVDzTTdpnYdBy6M8wGWdHIwZ5eePDpBp9FNRUlYf+dRcAjSk+KtjVYPQ==
X-Received: by 2002:a63:8bc8:: with SMTP id j191mr588663pge.234.1550099131918;
        Wed, 13 Feb 2019 15:05:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibo74VBa/ap4hzyXh3DZbvPsxNWYtRuYofAPgrOqgbBFrKVLE+2EWjoCphNi+0rAwIGKr2d
X-Received: by 2002:a63:8bc8:: with SMTP id j191mr588616pge.234.1550099131340;
        Wed, 13 Feb 2019 15:05:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550099131; cv=none;
        d=google.com; s=arc-20160816;
        b=AtOucSWVdCHPnl5ObR3W0DvXtuVBCbWbG9gYCLSJHSptdOLfrKAls5EpPEx1SZzeTK
         YitRLcm22b7jGrCdX+CytQNN48Amf7mcuRzwDVcQBBOtN7aVuTdQu1cpOHxDJOqPgLfe
         W9bzjMEok5YZ4L5/J83MI0kyQev6G3TjdB3tn1w49FQHyZ07qK9e3j3s4lCcJeolltKS
         hIu5FSGyaDAP1AK3aOUF2FY+ayMUGiAld9riA+8l37gHdCIEaUoHu0Rw9VybBRTknhOW
         jfTVPjxnkJzRUbASwzQmtREj5q3m2pVxveapySpsVOlm1v5gSqi31SQdzcMI1Q29w5lm
         mUWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NxuweNm4GxL/BoOqBVX9oI0qswOBhm+J5hpwG3wNYwI=;
        b=0DZtEx06c8nDHNgy0xMzKX+deXBAk/8hadB0hGEJz20Z9yg4lQFj5mtUExeNl6xOoY
         3K4Uo6+Fgc09pH9TLCaS+9jiYhR+XI4ceiQOdMmiODlqiijT669Y+vHlPNDW5FkS//Wg
         JHQI8Y+AL9rtZWCE1yTZC/HY31yxaoJ8rVHG3clLQX5W0Cmy1jcwQSRR5F/m0Xdk9GCO
         Ch/bukqlX+3rikaQIHH+JVrGfg5SfCIbrsTW05BXjucFcbBRYRSHf5am/suegctqlJBa
         azz5SMhiCD50IHIl7xWxIUbU63SJrJdn3MTW8aYe7pNkgzLQXTq5J7yjWDSaGUMrXYZP
         tXQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f9si574863pgh.435.2019.02.13.15.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 15:05:31 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 15:05:31 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,366,1544515200"; 
   d="scan'208";a="138415628"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 13 Feb 2019 15:05:27 -0800
From: ira.weiny@intel.com
To: linux-mips@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-fpga@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	devel@driverdev.osuosl.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org,
	linux-mm@kvack.org,
	ceph-devel@vger.kernel.org,
	rds-devel@oss.oracle.com
Cc: Ira Weiny <ira.weiny@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	David Hildenbrand <david@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Joerg Roedel <joro@8bytes.org>,
	Wu Hao <hao.wu@intel.com>,
	Alan Tull <atull@kernel.org>,
	Moritz Fischer <mdf@kernel.org>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Matt Porter <mporter@kernel.crashing.org>,
	Alexandre Bounine <alex.bou9@gmail.com>,
	=?UTF-8?q?Kai=20M=C3=A4kisara?= <Kai.Makisara@kolumbus.fi>,
	"James E.J. Bottomley" <jejb@linux.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	Rob Springer <rspringer@google.com>,
	Todd Poynor <toddpoynor@google.com>,
	Ben Chan <benchan@chromium.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Martin Brandenburg <martin@omnibond.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH V2 5/7] IB/hfi1: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Wed, 13 Feb 2019 15:04:53 -0800
Message-Id: <20190213230455.5605-6-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190213230455.5605-1-ira.weiny@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190213230455.5605-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Use the new FOLL_LONGTERM to get_user_pages_fast() to protect against
FS DAX pages being mapped.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 drivers/infiniband/hw/hfi1/user_pages.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index 78ccacaf97d0..6a7f9cd5a94e 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -104,9 +104,11 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 			    bool writable, struct page **pages)
 {
 	int ret;
+	unsigned int gup_flags = writable ? FOLL_WRITE : 0;
 
-	ret = get_user_pages_fast(vaddr, npages, writable ? FOLL_WRITE : 0,
-				  pages);
+	gup_flags |= FOLL_LONGTERM;
+
+	ret = get_user_pages_fast(vaddr, npages, gup_flags, pages);
 	if (ret < 0)
 		return ret;
 
-- 
2.20.1

