Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AAE6C04AAA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F9372133F
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="hG+Eotkw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F9372133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F0476B026B; Mon, 13 May 2019 10:39:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47C186B026C; Mon, 13 May 2019 10:39:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2303C6B026D; Mon, 13 May 2019 10:39:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFDE36B026B
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:23 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id x143so12246879itb.9
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=gIeFN0ziPc52a8KLvMF4BYUuKgdMORhtc90dfJFFcK8=;
        b=YUaDAaKEVGhQWcOTfDNZw4XPtQF980jgJbtBuaMX/QLCmEfl7jI6MvFHtRUzQjEV7+
         ZnX1Qw3PVceCWpa9tb0AkS0kld7yz0UrX+WNNdgW9IJQ75Zl7r+jcb4N0IbVNoHQfJri
         HTiDr6b1ZSGQYprb6ZGjK79aRFD5M7elfP9hawBXlsaYsnDNWz8Ti6lwKhAya03h0bGR
         e87QTdRJ8ZR3bbOmZZct5J5feoWSky3lmiPfIs3M3AnvBpkByNpDXNucv1dDmqcjHdBI
         v3ZVCJWtW9FHb36FoDKdFGkmSUBmInZpj3W8HcRG4VCBdeYwBS6o1c1WyhVRTQAlG50w
         wk7Q==
X-Gm-Message-State: APjAAAWr1PdD2K5paU3t6bFcQOp04/GyUHqmzXxTYDYGs1B3kWVcL8+p
	hO/toC1QkXwSzdQywViYyeSQt7rPO3h9e9WmrDXzyx2mKeZID90zjQd5Ps5msmY5dSJytjCD5t7
	eo7lTMFuZWv+2XynkHZB7jMxeH2ZPnJjAKIgHWT1jyqwgYKz3jEygzNL66yMwdMctVw==
X-Received: by 2002:a6b:e917:: with SMTP id u23mr7822275iof.136.1557758363746;
        Mon, 13 May 2019 07:39:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxB3yzRIYngYNpxOJrkCbxEDtVS7mx19z/PkLRqDIWlNd95HOmobZp4LqiAacAJhp+N6XYN
X-Received: by 2002:a6b:e917:: with SMTP id u23mr7822238iof.136.1557758363077;
        Mon, 13 May 2019 07:39:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758363; cv=none;
        d=google.com; s=arc-20160816;
        b=J6rozUWPKS5PVmeCQxjJ9YaCrVU5hLkkVP6Sbr5O1ygFJ5jmHy/2zo27vKYOmg90QY
         rdyGNm00Gu+4OwawKscO67DScAJlGaYfdbrDAT9sBjQjIFTl9rpkps+qAiRXmQZ0XKUJ
         0dcet0PdirNEnynSRxANsxx+Oia+Tbxud0FXENMnyi4svn463YquZ8m6KTg6f+a2bNyt
         hYjIwLu1G3R/Wg8/Nm+0ThkOqkvzDeKbqH4+GTjJen+0QRxNHBIssavUFZZ+wkp1TLF8
         BYk8eOWH2HCX5C6GtU8J9apWKvzNZ+XzlHzba8IdGIq8xg/2wmK60H2WFWauMnOS1CJX
         V0dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=gIeFN0ziPc52a8KLvMF4BYUuKgdMORhtc90dfJFFcK8=;
        b=PFQQHb/cDlK0+31KIAxLNdC0vlcQ4QoHeXwWnGM0UlCeCZj25WsV5aIfIveY6hpl6e
         P0oXzK/EjP9LmJbqaK6mmseI6DmJStLCxROiDDsl0m3dR6ELNkhXCZxJt05pWvZt+Oxz
         WvVhtQFmJLQ/zNKWh9HqiNwl2RoROED+t5jdnb8ONkn2Rt6vUuyr+q34oKejJEuUEAHw
         FqIosVGOU9OW7BRNwZfn8Z0a+S9sy2WWRSV90EFnqcOcP41ouU+7dVXmjvb8X6fA3Job
         oRn9GWw8nIEUQnvDGlRj/ulccUnJZWW2UT4hyH0Rm6IVwL2X4O44t/OwB2STUQrHELIG
         Belw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=hG+Eotkw;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z7si7144987ioc.47.2019.05.13.07.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=hG+Eotkw;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd4lg195008;
	Mon, 13 May 2019 14:39:14 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=gIeFN0ziPc52a8KLvMF4BYUuKgdMORhtc90dfJFFcK8=;
 b=hG+EotkwfW0afgyQ6GQFcjNoUZvzVSUEOYaoXlfVoV2cUsog6OXPvWLhJn7Oel/wqLNU
 q93k3vhzcUlchxQbCpQ1datYttq5bU2CVnCcfgAzotf47Y8hQH+8rBgoN2OmMBnGwcKO
 LEQEsJMpMtvD5hREw/USDtI1pRBmvG/plElU+Xrot/aCMJUcLyH6vUNMyX9iYSD4MPrI
 Y0R0Lk4RBx9aTbJnKTE11caIJKBYXFjCKw9NZy0zBsZERP6ZtLnDVZy0YizHnM93iBtI
 eV66j3vQdt+zdewHBfSeob4gdmSsVVx7BhZaz3q+MBojcv1hUk06rRc6rPcuwhVdDGFV rg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2sdq1q7avt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:14 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQE022780;
	Mon, 13 May 2019 14:39:11 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 11/27] kvm/isolation: add KVM page table entry offset functions
Date: Mon, 13 May 2019 16:38:19 +0200
Message-Id: <1557758315-12667-12-git-send-email-alexandre.chartre@oracle.com>
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

These functions are wrappers are the p4d/pud/pmd/pte offset functions
which ensure that page table pointers are in the KVM page table.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index 61df750..b29a09b 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -162,6 +162,67 @@ static bool kvm_valid_pgt_entry(void *ptr)
 }
 
 /*
+ * kvm_pXX_offset() functions are equivalent to kernel pXX_offset()
+ * functions but, in addition, they ensure that page table pointers
+ * are in the KVM page table. Otherwise an error is returned.
+ */
+
+static pte_t *kvm_pte_offset(pmd_t *pmd, unsigned long addr)
+{
+	pte_t *pte;
+
+	pte = pte_offset_map(pmd, addr);
+	if (!kvm_valid_pgt_entry(pte)) {
+		pr_err("PTE %px is not in KVM page table\n", pte);
+		return ERR_PTR(-EINVAL);
+	}
+
+	return pte;
+}
+
+static pmd_t *kvm_pmd_offset(pud_t *pud, unsigned long addr)
+{
+	pmd_t *pmd;
+
+	pmd = pmd_offset(pud, addr);
+	if (!kvm_valid_pgt_entry(pmd)) {
+		pr_err("PMD %px is not in KVM page table\n", pmd);
+		return ERR_PTR(-EINVAL);
+	}
+
+	return pmd;
+}
+
+static pud_t *kvm_pud_offset(p4d_t *p4d, unsigned long addr)
+{
+	pud_t *pud;
+
+	pud = pud_offset(p4d, addr);
+	if (!kvm_valid_pgt_entry(pud)) {
+		pr_err("PUD %px is not in KVM page table\n", pud);
+		return ERR_PTR(-EINVAL);
+	}
+
+	return pud;
+}
+
+static p4d_t *kvm_p4d_offset(pgd_t *pgd, unsigned long addr)
+{
+	p4d_t *p4d;
+
+	p4d = p4d_offset(pgd, addr);
+	/*
+	 * p4d is the same has pgd if we don't have a 5-level page table.
+	 */
+	if ((p4d != (p4d_t *)pgd) && !kvm_valid_pgt_entry(p4d)) {
+		pr_err("P4D %px is not in KVM page table\n", p4d);
+		return ERR_PTR(-EINVAL);
+	}
+
+	return p4d;
+}
+
+/*
  * kvm_pXX_free() functions are equivalent to kernel pXX_free()
  * functions but they can be used with any PXX pointer in the
  * directory.
-- 
1.7.1

