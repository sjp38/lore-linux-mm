Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D95E7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:59:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1B21222DD
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:59:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1B21222DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB1828E0005; Thu, 14 Feb 2019 10:59:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A35518E0001; Thu, 14 Feb 2019 10:59:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D7F68E0005; Thu, 14 Feb 2019 10:59:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A72E8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:56 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id ay11so4583674plb.20
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 07:59:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=u1kX5nLZRuvbRDghmPWQsmkHe1ki2AejtDggj/I8LTQ=;
        b=g3FnFIxatu1C4a8EEty/KiCGdVRRHMV0+0YVptNvORbYRHPzSaMKt3qcXLYTTcif8z
         sYsjtx2MGnF42x0F/LQN0oTIzZYCyx5CoToEEzkPAx4BfET9xAwRIIdsw/AoHiZK4W8q
         fE3JXvIOCh14GNPOU3Vi8e5DBdJRLpbw1S6ZhJqw9UDb3KrWSeaPtLVvgz+3uDylPfGN
         1oeF1lrYszGb6xLkzT4jjzNp2Z110ewetxlNdKBtg8a2GUsiGtMLOX36T6gCpGxx1Sgp
         bc+4gBtjI6+8vYZNq9zAjMVB+WujvKLJ6mZxU/xeujatuirIxhVbm4EGl13n5YACI39o
         EucA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZeQ1upAbrpX3dVgQp2nCkJvwYuSdBjwkUqKUABaE+uvdcT2uIf
	DmtDbaxe594p6nidb6g+0ePtnBseef4N7D719iSxFAJwvrMNZ7KOt+ayN52O6qluuv1Dj6Or2B0
	3RBzxMK8LN2fhJy7cDViv3dZuCL0dQnpuYikxrdvzk0mYsqtxwn0hzfjH1NCIMzgi6Q==
X-Received: by 2002:a63:105a:: with SMTP id 26mr542034pgq.184.1550159995978;
        Thu, 14 Feb 2019 07:59:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbmU0nFWMBbKNxZR4Ij/eKORBw9U52WI+GvDIPFAfTIgtvSyxE1eEKFGo71gzKk1e3RS5gM
X-Received: by 2002:a63:105a:: with SMTP id 26mr542007pgq.184.1550159995354;
        Thu, 14 Feb 2019 07:59:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550159995; cv=none;
        d=google.com; s=arc-20160816;
        b=qPkaGWL/rpi7++dWMQoCPfvDLlq2NT6q9FLP0EkPoo1isi1UKmplNHWYW4ikhPXFAc
         IaZ7CYhmOeHUrJJfX7W7x4smcnsMnVZZ0FrptuvArimte1BWOEyroPW3PEYFWx3U5L9A
         ZxPXK3msKM0TZ/dcSYKTavUnpWtAGmT/RinrefaDN4196FBziSICYrJ6PdXO1aFw4uG1
         6wYhcXImuvzLv72gk/0+8ym6WGthRZlrewMemdespBCzwgbV9UJTIt6nzvpwL2mczDBp
         RlfXavM6s+nYasn4HxnGAx01UJflTlayNhcJsIeW4rIvNKSF6fMRd/6y8recaCfPb+2c
         lvMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=u1kX5nLZRuvbRDghmPWQsmkHe1ki2AejtDggj/I8LTQ=;
        b=NM4JwaFtFdXVqmhzOJjVzO1+yFH4Hex706RIvX/eFsDNZH1LNSb0119BaPReVXmZuq
         c9ul/Ph3WocXh5hs/mUHbE8R8qHY5pb774blKcB9RQevbv4xkbeARBEMBBIZjPernlCu
         qjWkGoEBF0E4G+fwfW7cwcTFlqfXbDRkuk7rrSmJEk0HTfRLEVJD9R5GY5BSBEvUc5uL
         nP3i1V3J+fQ5Lfjnp8U+XT9tChp5IH5psWSKn4sHCc2CvmbQcwaeAs2F9Xh6jXrQWj/d
         BRl9MNRczOEcreeXUA7wKauNXuMIplJQ/MdiwGpHGk9m8FRJop8tV+dDS/bGhME7wM8P
         HArg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u10si2667315pgi.515.2019.02.14.07.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 07:59:55 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1EFfXWs094473
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:54 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qnarp44ya-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:54 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 14 Feb 2019 15:59:52 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 15:59:49 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1EFxmF524445166
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 14 Feb 2019 15:59:48 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 00D6F11C05C;
	Thu, 14 Feb 2019 15:59:48 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 41C2311C04C;
	Thu, 14 Feb 2019 15:59:46 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 14 Feb 2019 15:59:46 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 14 Feb 2019 17:59:45 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
        Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-riscv@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 3/4] init: free_initmem: poison freed init memory
Date: Thu, 14 Feb 2019 17:59:36 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
References: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19021415-0008-0000-0000-000002C07EAB
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021415-0009-0000-0000-0000222CA1C3
Message-Id: <1550159977-8949-4-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=835 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140109
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Various architectures including x86 poison the freed init memory.
Do the same in the generic free_initmem implementation and switch sparc32
architecture that is identical to the generic code over to it now.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/sparc/mm/init_32.c | 5 -----
 init/main.c             | 2 +-
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index d900952..77e8341 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -294,11 +294,6 @@ void __init mem_init(void)
 	mem_init_print_info(NULL);
 }
 
-void free_initmem (void)
-{
-	free_initmem_default(POISON_FREE_INITMEM);
-}
-
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
diff --git a/init/main.c b/init/main.c
index 38d69e0..9a61e9c 100644
--- a/init/main.c
+++ b/init/main.c
@@ -1049,7 +1049,7 @@ static inline void mark_readonly(void)
 
 void __weak free_initmem(void)
 {
-	free_initmem_default(-1);
+	free_initmem_default(POISON_FREE_INITMEM);
 }
 
 static int __ref kernel_init(void *unused)
-- 
2.7.4

