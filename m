Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6054C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5ACE72133F
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="VC6jjd4Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5ACE72133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A7366B026A; Mon, 13 May 2019 10:39:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20B8B6B026B; Mon, 13 May 2019 10:39:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05B5E6B026C; Mon, 13 May 2019 10:39:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id D75186B026A
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:21 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id l6so10001974ioc.15
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=4cIDR6PZl2rutLAEYSA22jeItW1PJPdhgsRn6XGFWEA=;
        b=am1x7bJ5EthjY4914FelVsh5/dAlYPP3xsDd6R07wANsy+vgqwUe6+pXsmwTGRxZPU
         aD+hHP4vvsKaWHIpO9xCqyj++hidJNheZIuyzGagRbIIR3CRY9sPMlMJLucFTerjyB8s
         cVyiH5AXU9Hv/df12q10V1dia/3o/P3EA5m9LJ7ocPEME4YUwac2h4pOLY5qw/w4PXuB
         4fQeH5mdOCfsW6fLckigbUweGplEhEqRwY3nT53xJusqDwpUDUVx8ywATS7ajq2r+Bgm
         nc7XHj6TWPY0LnGMT3EeB9cdsrFGN956RREjgmedoREzQI3jnniYDYSOgpK7MzLbJPSF
         HGaw==
X-Gm-Message-State: APjAAAXALsRXv2OHiSS7HjDk8LCQG5GZp9+0YkyIjBRPIFox15U+CjCf
	v0OrkrvgSRdQ89aeNU9BmfH4gtgwAmjcgicEw+MMKDVRZJ2Ltch3rO4Ffdu/BHS+areCEtjbLGA
	6miNw3ZJIeb/eYjZWJBsOCVGnrZNkvu2UDWO/QT6Xqv30CnkoydpGcdB3XFBfMUHJYg==
X-Received: by 2002:a24:8207:: with SMTP id t7mr20260483itd.78.1557758361612;
        Mon, 13 May 2019 07:39:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzch60aIEizryxqhQSyLd0TrJaC0tQIf7wapwcNBvAEkrflEJQ6IcYVky+TUXzjiG431YwY
X-Received: by 2002:a24:8207:: with SMTP id t7mr20260434itd.78.1557758360947;
        Mon, 13 May 2019 07:39:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758360; cv=none;
        d=google.com; s=arc-20160816;
        b=fZ1gjdrClA80H4OJjzTqm6HNoSYkHdTbuRgxLEtLhOrfw8lz8AgQNN2ZHax6xbGYBo
         gx3J+rsRLOtW9uYpP6F+Cgfc6uwHv12Gvr/HMkIsMB3Ft2ZJYCbOaNWreLoZGRrbs1TS
         xUKuZ8iKjSa4h/uk6Zucrla8QV8d9gHGPsUXmQlbCmKYRMZb/cQY5gtYseMPl2iLIHcf
         8Hiy7F2XCtA0cNwkM6Y7UoB+n/4a0INa67BffH/215Cruuxn+u33MmkmNUV7xIdvFtu6
         xe0/WrxIGgVU2xWAwStishCpuWT7PvJoxaKvhjBhHis0Yout/zpilmBSco9WiQ9hqPup
         5JIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=4cIDR6PZl2rutLAEYSA22jeItW1PJPdhgsRn6XGFWEA=;
        b=arWkfpLl0zl7Rkvkj0TcHKJNJGtVaVGy9uO2RN9WyUc1DpraK1z2mh/mB1MFSs5sl2
         /fVo1CFlUuxUQ0XnptTQ+iKrn6vyDO4upx9tdPHtKvtW8Oos2yGWlSp/i9XaHyhtxJpP
         1G2DHSR04Qh8W8k6cb59tvqEQ3jGdz8U6TEVG5/bLQ8cBhdfFwyIHE9YU9YgYITCXjec
         ANxLmLSUGK7CS99Vixsp/pSiFn537buFOYx6/SBg4b/OqXyUnM0e76C9HKqk637QVmDC
         7g4ScSY5jTMnCmEUW8KY74gs5a6ytxhIKBfqDtoOxiomZJJi+IeuvYGsWbatm5lDg+QK
         huYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VC6jjd4Q;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x197si3223284itb.72.2019.05.13.07.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VC6jjd4Q;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd84M195057;
	Mon, 13 May 2019 14:39:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=4cIDR6PZl2rutLAEYSA22jeItW1PJPdhgsRn6XGFWEA=;
 b=VC6jjd4Q/95/JOy5PgCZ8AdKsMFlE4fQCQOC2dyJBtX/9iwCN4mgh4f7m5XZlJT41CUT
 CWiyU1PZYsAhyoP4PcbGhS++vcss56Xjgewi7dXzHWILBy4ssid7xPlSLghegxyz3MzM
 lRsyU6oTrYGTNnLa5CF5DZEESUPecwfArax8wnk/8fA+g1/lxpeUfKmiNGTDKimHFL0k
 BUWpMG9d2DNNstgdU8bqlCEnHiwjnEh1BuYVAwNxdf4+s9KmtLq6O/FzAGHQaEbNfMUf
 6YUvBPOPUK+XTc5r2FauxEIQJUNK5TtoYUDMw6GnP5h/kShdnJWw0oXvReVp36peQCHR rw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2sdq1q7avk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:11 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQD022780;
	Mon, 13 May 2019 14:39:08 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 10/27] kvm/isolation: add KVM page table entry free functions
Date: Mon, 13 May 2019 16:38:18 +0200
Message-Id: <1557758315-12667-11-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These functions are wrappers around the p4d/pud/pmd/pte free function
which can be used with any pointer in the directory.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index 1efdab1..61df750 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -161,6 +161,32 @@ static bool kvm_valid_pgt_entry(void *ptr)
 
 }
 
+/*
+ * kvm_pXX_free() functions are equivalent to kernel pXX_free()
+ * functions but they can be used with any PXX pointer in the
+ * directory.
+ */
+
+static inline void kvm_pte_free(struct mm_struct *mm, pte_t *pte)
+{
+	pte_free_kernel(mm, PGTD_ALIGN(pte));
+}
+
+static inline void kvm_pmd_free(struct mm_struct *mm, pmd_t *pmd)
+{
+	pmd_free(mm, PGTD_ALIGN(pmd));
+}
+
+static inline void kvm_pud_free(struct mm_struct *mm, pud_t *pud)
+{
+	pud_free(mm, PGTD_ALIGN(pud));
+}
+
+static inline void kvm_p4d_free(struct mm_struct *mm, p4d_t *p4d)
+{
+	p4d_free(mm, PGTD_ALIGN(p4d));
+}
+
 
 static int kvm_isolation_init_mm(void)
 {
-- 
1.7.1

