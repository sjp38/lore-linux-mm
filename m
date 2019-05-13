Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02310C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C9BC2084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="2ar9gUe8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C9BC2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D0C36B0271; Mon, 13 May 2019 10:39:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95C586B0272; Mon, 13 May 2019 10:39:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6ED446B0273; Mon, 13 May 2019 10:39:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC256B0271
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:38 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id q1so12293558itc.3
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=kkqkMbnz+iek9dkeudKGJuXmnkn48lWfRSXOX7tv6jE=;
        b=NiMKXPVbTLtNuPInDRiayZHjkO97F0TQteqQjDxiXn0yR8b6gqk+sZRwtTm5mNcAx/
         R9xMkakA0q12Jc9+yVtYJi4sIRT6a6axeRXdwJk9kxvu9R6LWlQJeKsA6Yeo6ujocVBN
         mqjkD09sVMnG32JsdDOo13GrxQ2E5AEiMWgdJyQJGc04DkoCYI25GfwjSLN0bIrX4Z4p
         /sCgYCichmaSE3E7P4uJsdIX/gGx8gRp2DGQeGg3PLv2bEuNn9JWQAuUWjukKp4BN2Ul
         smgXUbPRXTRs7+0JXgw27v6juAt2uTpr+W6v21zWs6IHBIu82bMDcLdqGV4YKU+gn7gm
         UYEQ==
X-Gm-Message-State: APjAAAUHV2CpbtTj/t7qZ9O1sRIK3XrZuOc8YQt8ectvbuKGt2ERviie
	bvz+1qfynzSPIv6vWFvkdusNN5bOBvSJ+7wb58XcZCqBbcvkywYRYKUlErbLFSUv+4kyHZRXWpE
	859Jq7QdkY47fX6aZMGyK18ueME80lL0CCsyUWMrsXOxLvOA4o2QTXgMoACp6bLMtNA==
X-Received: by 2002:a24:5302:: with SMTP id n2mr1594214itb.27.1557758378018;
        Mon, 13 May 2019 07:39:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmlGIflOsNIb1t35hwc1/JYO1dK1Z0yk7pUSYV3x9O1HXdG6vmERvtN8HzShv5RT7U4/GF
X-Received: by 2002:a24:5302:: with SMTP id n2mr1594141itb.27.1557758377062;
        Mon, 13 May 2019 07:39:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758377; cv=none;
        d=google.com; s=arc-20160816;
        b=Eu0MRpn5ejIXt1k00OgZix2wojIQxfx8O1qHdS7wWvjdUo2AU4+DdeznctTuwZJwAG
         cNfbbqAKwDZarPuJz5Vlno13sIvjsyVLNmMUVExUfNs1flA9ijJkvHBdq6Foej9zKNpU
         m+IumeCU8GPmggsBoOXP8RxY67DIFlciN4KvN6ieOp8FYAGACwK0a/AP/nZTiX8iXapt
         A3U0qHCMfArSHKXClfE4qBa2Bv3niwNzhXCHPcf/LkJGAdV/6TD4qrz2VBm8hql4blRt
         pMDvHQERagv+M2N0sVzmH0LjXTRpxjsCr5V4l50HWmCjzl7rnQZFna9q1OaMnjJQtGIs
         kx8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=kkqkMbnz+iek9dkeudKGJuXmnkn48lWfRSXOX7tv6jE=;
        b=uAXk1kwJG4YxTWDihseU5FstclDdTCN8i93BYN39+xlomAVtsZe14YrTurSRLrsoWX
         xwK3OCOqKwGNRPEZD2EZ7DRkAxf0Tr4vSXEV9GeJoACneyGJVN/OjrS8/iAD0kt6Cqwp
         DAO3a0njldV3/X4xtrhVoHnH5mA2l1wqt0woUI/FScn8fUonFHwgiIV4nZh8ssmXp9yp
         JzdCALgyeIr37SwbwpLMsvLmFlyFqZ0A3Z8y+0ZMJWCR2S+pB8rMBpY/NiFNQYclWPvx
         7+/milrRnCB2+otvsTeAQ9Z34IhW6fC8P8wXuHSwt89WKQhuOKk1uWL/mIQQX2FmJAtn
         TP7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=2ar9gUe8;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id f63si8070581itg.124.2019.05.13.07.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=2ar9gUe8;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd2tv193095;
	Mon, 13 May 2019 14:39:28 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=kkqkMbnz+iek9dkeudKGJuXmnkn48lWfRSXOX7tv6jE=;
 b=2ar9gUe8PEkk2N7E5R2hXBN+S8EK1bK+MAG3miC+Uo2QLiQpRtXqL81wyT3WFUlvaGIV
 yFj+PnJKxx3M+EJiG2N5Wy2Ca0GxXFOvdr9H+PUOpN9ibTPdSwSw+PUxnSclUc/j8iqx
 wwwphVvx1m+Qjgrj3A5zXZqSIA9u83IyoHXzPJ4+e91MJFKjD0UNIlFLxXBq84f1OvIs
 RoXbf7KaYRZRzbEmfMM66PYK9PkQLGNLAw9R0GErJlNjc4FdSPRQilul0tfbzsHbejxk
 biccPs2shvHGp4MSsXlJ7ox721gE8q5sCTOHoWye2NivkamyCR56V4G1+yL8MEIsUd/r kQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2sdkwdfkxs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:28 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQJ022780;
	Mon, 13 May 2019 14:39:25 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 16/27] kvm/isolation: functions to clear page table entries for a VA range
Date: Mon, 13 May 2019 16:38:24 +0200
Message-Id: <1557758315-12667-17-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These functions will be used to unmapped memory from the KVM
address space.

When clearing mapping in the KVM page table, check that the clearing
effectively happens in the KVM page table and there is no crossing of
the KVM page table boundary (with references to the kernel page table),
so that the kernel page table isn't mistakenly modified.

Information (address, size, page table level) about address ranges
mapped to the KVM page table is tracked, so mapping clearing is done
with just specified the start address of the range.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |  172 ++++++++++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/isolation.h |    1 +
 2 files changed, 173 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index c8358a9..e494a15 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -758,6 +758,178 @@ int kvm_copy_ptes(void *ptr, unsigned long size)
 }
 EXPORT_SYMBOL(kvm_copy_ptes);
 
+static void kvm_clear_pte_range(pmd_t *pmd, unsigned long addr,
+				unsigned long end)
+{
+	pte_t *pte;
+
+	pte = kvm_pte_offset(pmd, addr);
+	if (IS_ERR(pte)) {
+		pr_debug("PTE not found, skip clearing\n");
+		return;
+	}
+	do {
+		pr_debug("PTE: %lx/%lx clear[%lx]\n", addr, end, (long)pte);
+		pte_clear(NULL, addr, pte);
+	} while (pte++, addr += PAGE_SIZE, addr < end);
+}
+
+static void kvm_clear_pmd_range(pud_t *pud, unsigned long addr,
+				unsigned long end, enum page_table_level level)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = kvm_pmd_offset(pud, addr);
+	if (IS_ERR(pmd)) {
+		pr_debug("PMD not found, skip clearing\n");
+		return;
+	}
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(*pmd))
+			continue;
+		BUG_ON(!pmd_present(*pmd));
+		if (level == PGT_LEVEL_PMD || pmd_trans_huge(*pmd) ||
+		    pmd_devmap(*pmd)) {
+			pr_debug("PMD: %lx/%lx clear[%lx]\n",
+			    addr, end, (long)pmd);
+			pmd_clear(pmd);
+			continue;
+		}
+		kvm_clear_pte_range(pmd, addr, next);
+	} while (pmd++, addr = next, addr < end);
+}
+
+static void kvm_clear_pud_range(p4d_t *p4d, unsigned long addr,
+				unsigned long end, enum page_table_level level)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = kvm_pud_offset(p4d, addr);
+	if (IS_ERR(pud)) {
+		pr_debug("PUD not found, skip clearing\n");
+		return;
+	}
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none(*pud))
+			continue;
+		if (level == PGT_LEVEL_PUD || pud_trans_huge(*pud) ||
+		    pud_devmap(*pud)) {
+			pr_debug("PUD: %lx/%lx clear[%lx]\n",
+			    addr, end, (long)pud);
+			pud_clear(pud);
+			continue;
+		}
+		kvm_clear_pmd_range(pud, addr, next, level);
+	} while (pud++, addr = next, addr < end);
+}
+
+static void kvm_clear_p4d_range(pgd_t *pgd, unsigned long addr,
+				unsigned long end, enum page_table_level level)
+{
+	p4d_t *p4d;
+	unsigned long next;
+
+	p4d = kvm_p4d_offset(pgd, addr);
+	if (IS_ERR(p4d)) {
+		pr_debug("P4D not found, skip clearing\n");
+		return;
+	}
+
+	do {
+		next = p4d_addr_end(addr, end);
+		if (p4d_none(*p4d))
+			continue;
+		if (level == PGT_LEVEL_P4D) {
+			pr_debug("P4D: %lx/%lx clear[%lx]\n",
+			    addr, end, (long)p4d);
+			p4d_clear(p4d);
+			continue;
+		}
+		kvm_clear_pud_range(p4d, addr, next, level);
+	} while (p4d++, addr = next, addr < end);
+}
+
+static void kvm_clear_pgd_range(struct mm_struct *mm, unsigned long addr,
+				unsigned long end, enum page_table_level level)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(*pgd))
+			continue;
+		if (level == PGT_LEVEL_PGD) {
+			pr_debug("PGD: %lx/%lx clear[%lx]\n",
+			    addr, end, (long)pgd);
+			pgd_clear(pgd);
+			continue;
+		}
+		kvm_clear_p4d_range(pgd, addr, next, level);
+	} while (pgd++, addr = next, addr < end);
+}
+
+/*
+ * Clear page table entries in the KVM page table. The level parameter
+ * specifies the page table level (PGD, P4D, PUD PMD, PTE) at which the
+ * clear should be done.
+ *
+ * WARNING: The KVM page table can have direct references to the kernel
+ * page table, at different levels (PGD, P4D, PUD, PMD). When clearing
+ * such references, if the level is incorrect (for example, clear at the
+ * PTE level while the mapping was done at PMD level), then the clearing
+ * will occur in the kernel page table and the system will likely crash
+ * on an unhandled page fault.
+ */
+static void kvm_clear_mapping(void *ptr, size_t size,
+			      enum page_table_level level)
+{
+	unsigned long start = (unsigned long)ptr;
+	unsigned long end = start + ((unsigned long)size);
+
+	pr_debug("CLEAR %px, %lx [%lx,%lx], level=%d\n",
+	    ptr, size, start, end, level);
+	kvm_clear_pgd_range(&kvm_mm, start, end, level);
+}
+
+/*
+ * Clear a range mapping in the KVM page table.
+ */
+void kvm_clear_range_mapping(void *ptr)
+{
+	struct kvm_range_mapping *range_mapping;
+	bool subset;
+
+	mutex_lock(&kvm_range_mapping_lock);
+
+	range_mapping = kvm_get_range_mapping_locked(ptr, &subset);
+	if (!range_mapping) {
+		mutex_unlock(&kvm_range_mapping_lock);
+		pr_debug("CLEAR %px - range not found\n", ptr);
+		return;
+	}
+	if (subset) {
+		mutex_unlock(&kvm_range_mapping_lock);
+		pr_debug("CLEAR %px - ignored, subset of %px/%lx/%d\n",
+			 ptr, range_mapping->ptr, range_mapping->size,
+			 range_mapping->level);
+		return;
+	}
+
+	kvm_clear_mapping(range_mapping->ptr, range_mapping->size,
+	    range_mapping->level);
+	list_del(&range_mapping->list);
+	mutex_unlock(&kvm_range_mapping_lock);
+
+	kfree(range_mapping);
+}
+EXPORT_SYMBOL(kvm_clear_range_mapping);
+
 
 static int kvm_isolation_init_mm(void)
 {
diff --git a/arch/x86/kvm/isolation.h b/arch/x86/kvm/isolation.h
index e8c018a..7d3c985 100644
--- a/arch/x86/kvm/isolation.h
+++ b/arch/x86/kvm/isolation.h
@@ -17,5 +17,6 @@ static inline bool kvm_isolation(void)
 extern void kvm_isolation_exit(void);
 extern void kvm_may_access_sensitive_data(struct kvm_vcpu *vcpu);
 extern int kvm_copy_ptes(void *ptr, unsigned long size);
+extern void kvm_clear_range_mapping(void *ptr);
 
 #endif
-- 
1.7.1

