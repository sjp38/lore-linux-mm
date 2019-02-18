Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 576C8C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:42:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2362E217D9
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:42:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2362E217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7B7D8E0007; Mon, 18 Feb 2019 13:42:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B020A8E0002; Mon, 18 Feb 2019 13:42:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A3F78E0007; Mon, 18 Feb 2019 13:42:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 53D8F8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:42:03 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id n24so12516560pgm.17
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:42:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=7nb5sfZMKLy3F4xJmE1rTMV54PH3l/oP5gHKnkf80Q4=;
        b=tg9EcmhhDEXXy94XIpMQt/jOtgpad4T6CITcs3drMUWE5a/oO/3d8T1bo0aXpiSL18
         knrKKF9OeDOnGpOlhtPgcdpbfIZspFTa3Xz6dWeTgLYenUzwawUyld2ERkkkkttVHmPh
         R5zWcmXPbHdmXqRPE7cYw7cetzgbSrCtxH448uITfZTVk636WmlR4o1tay5T7y/xEn7d
         RnzvFGQLXRReS/ty+EJoNe266VfFbp5zN8A7HB60jSBgTFurg3bNuT2yY2OmuuEMmPlw
         yjXzEx7NZO2H0U0hrntf4Vj2kyChGnuSlU6N4PGRQUCRxF1rwgtYSl8O6bLPtWV1igm6
         tzfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaxZtBhclR0FUWaBIr3cdN1frQuSR/LTeskb30wkSVUlo11N2L/
	8NvWiTWbfKtf/9vZ8ONtue/pNXG/VO/iiJicXIf+ks2oeVcw2Pq5nAQIGNgooUyPB3wLpm7OYmn
	9D5IXbqOWN+bt2HIGe3Xpl/omB3r32JM6S3DoL8G26hrbTmJT0v+J7JblvEHFmZDukQ==
X-Received: by 2002:a63:e451:: with SMTP id i17mr23883914pgk.413.1550515323012;
        Mon, 18 Feb 2019 10:42:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbAdO0pzGHMVGptCGb0S+cvyYcfWxv9OIrw78u9P20edSR2Xfbau/dMElbp3Wet2f2MusRZ
X-Received: by 2002:a63:e451:: with SMTP id i17mr23883861pgk.413.1550515322024;
        Mon, 18 Feb 2019 10:42:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550515322; cv=none;
        d=google.com; s=arc-20160816;
        b=dRJliW+RXv6YygwTmWFgm2RehDrXEjDLoGqZAWHDGGl/H9/wLBHfkr1QFGtr9wcP9b
         fGO6E3geouKLsG9wSffJ/FRmVUkwNRmcYiDtUFYZ0SrfXlPtKtI0LR6/pcwnxqrQz8Ks
         Wl5vqYGeJ6AfmSARtOA3zoarJxX3obF+uXZ7dlPsy0OMpAuTWq2H69SfUpewnktrva8y
         Ne5rgeI+7GTZdmuBsaHTHAxZFqOxRjIs7+JNVAt30YrpCTCJw6r0AqkuLqz93T5Rtxek
         FW4IM+8lu0l6w0OzvT7Wst7TOW98jzb0aoOwU38vprXSq6nWNDqTgiqyFM4ROoDC5FJo
         ONiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=7nb5sfZMKLy3F4xJmE1rTMV54PH3l/oP5gHKnkf80Q4=;
        b=DNoLj6MwVaNqYw5BqZPp2wGOktYWm8x0cvV09UGAyw/X3ciVk6Ru2XQMfD8tHuQvpD
         S5+1awlQYMCqbYYkXb3Qym3hxhn0unAoSFMUSaT3IGx7SJWXP9dePawDVYEcrNH321ZZ
         /+Ms8MTcVptyCujxthJYtYHlcVuC1+Df1gwCuVy1Z6Pj3a9+9NpTPnG+pOpfvvu9IYI0
         zri9/P86wh4bLeq7L4RepelO3LDZfhU1AH21uGsj377SF68NNa3FuS/uF0Oovs0pbbli
         yaGV8gOl7756BlDVINz9o0VJ8z1BUGOwOw5wa/HGARrxQIgxn4m928Fko9werKQTTi6z
         +tMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r17si12725663pgv.329.2019.02.18.10.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 10:42:02 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1IIcqRR094158
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:42:01 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qr0nncpwc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:42:01 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 18 Feb 2019 18:41:59 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 18 Feb 2019 18:41:54 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1IIfrJJ55181540
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 18 Feb 2019 18:41:53 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 459D2AE051;
	Mon, 18 Feb 2019 18:41:53 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 344B7AE04D;
	Mon, 18 Feb 2019 18:41:48 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.239])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 18 Feb 2019 18:41:48 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Mon, 18 Feb 2019 20:41:46 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
        Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-riscv@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 3/4] init: free_initmem: poison freed init memory
Date: Mon, 18 Feb 2019 20:41:24 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550515285-17446-1-git-send-email-rppt@linux.ibm.com>
References: <1550515285-17446-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19021818-0008-0000-0000-000002C1EA74
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021818-0009-0000-0000-0000222E1A1E
Message-Id: <1550515285-17446-4-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-18_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=824 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902180138
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
index f0dbc0b..d02a9ae 100644
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
 void sparc_flush_page_to_ram(struct page *page)
 {
 	unsigned long vaddr = (unsigned long)page_address(page);
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

