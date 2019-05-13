Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 622F3C04AAA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17E242084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="cackC5e/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17E242084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 988016B026D; Mon, 13 May 2019 10:39:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EB566B026E; Mon, 13 May 2019 10:39:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73CBB6B026F; Mon, 13 May 2019 10:39:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 484FE6B026D
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:27 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id l193so2755147ita.8
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=3oQZsnmQ7NshrUK5gBFOiQdwJCmvyMk7rTDgLZ4eiR8=;
        b=piDYExRTFfeUF6XkxVMbxVOtozhjY1EJGNFLHaPUBNjCrUaEZ40gDY/w/dKL2M76r4
         sGcm9llkyIHRWPJzwnJVOIY3LKsB5zpxTuGCkIXJstW0GOq80MRLap+LJZNOt9QGOKuz
         dncf7OYexlPypqL5q307QEq7FiASrTfNGDJNDb7D8x03VrkPlyEz/TcxlpmY4x1/woCN
         7c7kCnFyb3WaNJNcOjLQYYegjxAoxhCbdgOF5FXYvpvthnQTUclkbDrYVTQORYGZrZ8Z
         +GRmFGKRrdmegLGiLaUBnZ2AF0ka2L7WK1rLBT7OAvpXzecV2FAnGSll20M9Wq5jYxPe
         ksgQ==
X-Gm-Message-State: APjAAAVMRCq/4QmIcNd7g/aa3fRHgnbrERxFwZFOvPaeBjmYJJL18o9o
	ujMnHpJx0pwOhN/FuLQTwXhhU2ctq7UXD1oaqZSX/5w1u5XQGn6i+hKnTHWE0+xRy06Upuz8fwt
	xuYM6t61eG2gCXHvF9Td8ESwFdqVO7grKIhq9iqEwm3fCbVyD9LGnFccbHjnq5zPJUg==
X-Received: by 2002:a6b:14ce:: with SMTP id 197mr15661240iou.29.1557758367073;
        Mon, 13 May 2019 07:39:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQExO2FUE+CYKtkjFEET3dW29Ayk44bbP+TIruMPLyd5GcaoyGddH65NbT4h1mRqLQVZ6N
X-Received: by 2002:a6b:14ce:: with SMTP id 197mr15661192iou.29.1557758366316;
        Mon, 13 May 2019 07:39:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758366; cv=none;
        d=google.com; s=arc-20160816;
        b=I+2T+mtdXaBoCI0oknwsio7WhmYH6N2haYMa2omVmQCQcg6DSORUncOpNkAhZTdeoj
         q1QnpDC3azh9bXnhIS5PQfohfLgWzmnZ9lgMeHPtXU1hq3GoM5HvBpQwyQHNofDq7ucy
         JsmwRdQSZ8iP0lZg/9jSeOIqgKk8C6h8aDK8BjovT71Mskn5QpaO7ulYEz33nrcnjHft
         lYS1D5XsxgQTSiwl8o406qAEL0wXciTvP8OYWOH0v+zA0WqHHZBBE4NhcbPeZl8DJi8W
         VLkSeidhDDVeYH3DrcaNaeQst4izZlP/lLQHNyjQyEZSBm90NwkKhOlrGzN4JhOF7J8+
         mUPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=3oQZsnmQ7NshrUK5gBFOiQdwJCmvyMk7rTDgLZ4eiR8=;
        b=qk1WRF8rtcOYXHlINqEwmHYiv9u3zKNy6cBYRZ5gQhG7q+uT1SZVMYuC2UtQAs8mx4
         lwuBK1+0YKSUoR0nyteMY5ajImKbxRZbmg6mdwYJuGzIU/RD4iEgrVAaTkz+vOEWGA2y
         9+VhwcozHY0ftQRD1/dXKjW79VEQjnZ3yqfvr6DJjVE/6jbrf6ozJVgCkT3t6066Q1uG
         FQ1+5MsaaMJPgUz8WgczjnNqBBTz0C+jQczhisVHmWHsg2Gb05XjHoprdJ6kQs/ujTm0
         KPvPLc5JbgCh4R/AWFiINk0rbfeR/WjcKCisU87WlyktCv4MRKTDKv/rTlZPUunvMc4p
         RZUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="cackC5e/";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c17si82803itc.40.2019.05.13.07.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="cackC5e/";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd28F193025;
	Mon, 13 May 2019 14:39:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=3oQZsnmQ7NshrUK5gBFOiQdwJCmvyMk7rTDgLZ4eiR8=;
 b=cackC5e/rN14Atf5QlnsuYve24xrmHKk5OAv4LozaAp9vhiUL7E7xPH3kbnOM8VYLH+M
 qQZDMDajYAWzXDX4pYfxSi/cFR9+miTzGtpQvwsGANTuO936Hac7155wikox7cO9zHM6
 D6VSW0wFlH4kS9hhjEHDuhBzZL61Y1YPaaQ9QapuqevDj5phnii9KR4rMc6oFyvj+0cK
 chnwMcSACXVNjOAa1xqmZO14HcVVu9E4v0xi+ZQhdjbaq/Q1oelYLJg/hz12bN7CBmtg
 1H1C0ZDiqvGmCSUtMdjVlrxOudApkaffggciBhogmTfWK5aks2i24a2IdgYkJ3LSxlPk OA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2sdkwdfkwq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:16 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQF022780;
	Mon, 13 May 2019 14:39:13 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 12/27] kvm/isolation: add KVM page table entry allocation functions
Date: Mon, 13 May 2019 16:38:20 +0200
Message-Id: <1557758315-12667-13-git-send-email-alexandre.chartre@oracle.com>
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

These functions allocate p4d/pud/pmd/pte pages and ensure that
pages are in the KVM page table.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   94 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 94 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index b29a09b..6ec86df 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -248,6 +248,100 @@ static inline void kvm_p4d_free(struct mm_struct *mm, p4d_t *p4d)
 	p4d_free(mm, PGTD_ALIGN(p4d));
 }
 
+/*
+ * kvm_pXX_alloc() functions are equivalent to kernel pXX_alloc()
+ * functions but, in addition, they ensure that page table pointers
+ * are in the KVM page table. Otherwise an error is returned.
+ */
+
+static pte_t *kvm_pte_alloc(struct mm_struct *mm, pmd_t *pmd,
+			    unsigned long addr)
+{
+	pte_t *pte;
+
+	if (pmd_none(*pmd)) {
+		pte = pte_alloc_kernel(pmd, addr);
+		if (!pte) {
+			pr_debug("PTE: ERR ALLOC\n");
+			return ERR_PTR(-ENOMEM);
+		}
+		if (!kvm_add_pgt_directory(pte, PGT_LEVEL_PTE)) {
+			kvm_pte_free(mm, pte);
+			return ERR_PTR(-EINVAL);
+		}
+	} else {
+		pte = kvm_pte_offset(pmd, addr);
+	}
+
+	return pte;
+}
+
+static pmd_t *kvm_pmd_alloc(struct mm_struct *mm, pud_t *pud,
+			    unsigned long addr)
+{
+	pmd_t *pmd;
+
+	if (pud_none(*pud)) {
+		pmd = pmd_alloc(mm, pud, addr);
+		if (!pmd) {
+			pr_debug("PMD: ERR ALLOC\n");
+			return ERR_PTR(-ENOMEM);
+		}
+		if (!kvm_add_pgt_directory(pmd, PGT_LEVEL_PMD)) {
+			kvm_pmd_free(mm, pmd);
+			return ERR_PTR(-EINVAL);
+		}
+	} else {
+		pmd = kvm_pmd_offset(pud, addr);
+	}
+
+	return pmd;
+}
+
+static pud_t *kvm_pud_alloc(struct mm_struct *mm, p4d_t *p4d,
+			    unsigned long addr)
+{
+	pud_t *pud;
+
+	if (p4d_none(*p4d)) {
+		pud = pud_alloc(mm, p4d, addr);
+		if (!pud) {
+			pr_debug("PUD: ERR ALLOC\n");
+			return ERR_PTR(-ENOMEM);
+		}
+		if (!kvm_add_pgt_directory(pud, PGT_LEVEL_PUD)) {
+			kvm_pud_free(mm, pud);
+			return ERR_PTR(-EINVAL);
+		}
+	} else {
+		pud = kvm_pud_offset(p4d, addr);
+	}
+
+	return pud;
+}
+
+static p4d_t *kvm_p4d_alloc(struct mm_struct *mm, pgd_t *pgd,
+			    unsigned long addr)
+{
+	p4d_t *p4d;
+
+	if (pgd_none(*pgd)) {
+		p4d = p4d_alloc(mm, pgd, addr);
+		if (!p4d) {
+			pr_debug("P4D: ERR ALLOC\n");
+			return ERR_PTR(-ENOMEM);
+		}
+		if (!kvm_add_pgt_directory(p4d, PGT_LEVEL_P4D)) {
+			kvm_p4d_free(mm, p4d);
+			return ERR_PTR(-EINVAL);
+		}
+	} else {
+		p4d = kvm_p4d_offset(pgd, addr);
+	}
+
+	return p4d;
+}
+
 
 static int kvm_isolation_init_mm(void)
 {
-- 
1.7.1

