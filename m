Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5150FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:03:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0025D218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:03:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="2PAnanOt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0025D218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B24F8E000D; Wed, 13 Feb 2019 19:03:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 561B88E0005; Wed, 13 Feb 2019 19:03:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 479E28E000D; Wed, 13 Feb 2019 19:03:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08EDE8E0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:03:07 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r13so2888166pgb.7
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:03:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=TQlIsuP1ag8N8cWtIZarXg5qzwt4o6eHPtANA79RWaM=;
        b=FJDFL0tIt31vvIWsBhsll/glYzh2XtltNkoOr8UUzXNabRLZ+jj0Blt2+HEibQ2Ks1
         TR2jT0dzh52K/N3ao6s72UswVdEKCOtlfEUg9KLfUK+TsTkO6babC+nfJJF7PXOOHNAu
         QiRwx5NfiS5lJcuKS3E8nyYBExWT/4Gt6AlxhhmvpxFvdZQYJAFMqKZraXN6szEVR4nV
         J7vRq+zm7D7zpG5oYj/hwHEwe6nOTTMyhyatgq4Ep4Ry4/PD3XfeMULHUByZNu7aN6gm
         DlwSD6GMTVKyL6CLVt959F95bWmYFRb0qU/amjTOQ9yQG6ZbvRLM+VaDCXf5Nvw4Yrna
         guBA==
X-Gm-Message-State: AHQUAuZQ0iLEZRBzZafgIfgfo2uhdnE/ajgMTGn/eXWL36lmbAWgfZmN
	hhaJzBmE9CfDpQHpC4ku56CxC82iRXBoPgsuCIRT8Oe3helPNJ463/+GqGssbqjQoDs0dZatt0P
	kuc2LvGhpUAv/BB8iefLs6a6gpgkpLVunCUVUma5wRJcpPxqwttDb2vPEKVAv5HsVhA==
X-Received: by 2002:a65:4383:: with SMTP id m3mr817829pgp.96.1550102586685;
        Wed, 13 Feb 2019 16:03:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYK/So7VUvbD5Kl5+s3Tt5+3ItVVG+1odnNT97rD9uWH6clHWBnrlA2rj+oE5+PymD9i+mB
X-Received: by 2002:a65:4383:: with SMTP id m3mr817745pgp.96.1550102585748;
        Wed, 13 Feb 2019 16:03:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102585; cv=none;
        d=google.com; s=arc-20160816;
        b=A2HiSMhCcqMymU20980A0TPi6Mo3wmRUnGj3nmV0i5h78l53TmCqmrHjIZX9gF7EUk
         n70TNnmLHVx4E2569pVzy4Qq/ja8mXdknpAtZ2YwcnJnE5W3xfIfMs3ckbiaeU1Cmnbn
         6lAh6Ntc1ftZMKQ3bUZllqHHCzUlDTxFvRfFGgYVgfykBYgbuyBq3NdxYvr/ptsb8OFu
         h+M5oUaZN4pd1rn+U7AyezBfUOrBycJU8xb+SIWII44P/xnEbEhC2b2ybQJoi/qrcOXm
         Jd2Dj5oe0aTiWbtL8E4sqKjsM60FBoHFoIAmGC+fQYw41/bI+gspAbq1cVbdn6gfbrbG
         sYZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=TQlIsuP1ag8N8cWtIZarXg5qzwt4o6eHPtANA79RWaM=;
        b=ola4CbZ1KEa3PyKWwWJC2mvaC8dnGg9ZQISt6DBZ6wbYu0e5Ri2rRGLopvbaad6ozU
         YixUeXMS/gWFzrNlRa3tb+EGqW1LbB+KJo0wuTprjiivd+EbIj3bMlOCdPZfU9QoNsoK
         alp1N+ST2biVRfhDMD+amHoeXyOqW8ug/yMZNO2qfVUrIFLmzmzZciiTI6vRP+xM8qkE
         9gwvXfWM8InOHIntG6eEIztH+80388tT7mxfwmMH1SjL+C5s4ugzX7mtM0XjPp2wMRRg
         nvQ6+2f+qwDIsS0cMox17u5wfYXEwLGHhSe9Li5dIZgoZtwa//GF7QWvIuMci0vhlA1r
         FFog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=2PAnanOt;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id bb3si744153plb.160.2019.02.13.16.03.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:03:05 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=2PAnanOt;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNx9xx093658;
	Thu, 14 Feb 2019 00:02:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=TQlIsuP1ag8N8cWtIZarXg5qzwt4o6eHPtANA79RWaM=;
 b=2PAnanOtADcxei1cy8BlTb/qU5ZZ7i0wqibFXPa9bnInPG/bvReURBWdV7oqlHHKB04P
 eJe2e67nu+luxcdvC3UBRDtvbK4t0fpRO4v+csDCFP/QjO2HMEGx/ANYI0/HgjyJOXBQ
 A+HhQpvU1Zm+os48RbnhGhjXf13nrybGW9Q+s+JqmKbNdQ6NQ9nWd7faph98x/U5WFsQ
 GP3HR7Iu2pYrMuqLFfE3A+sddb/2CPIRd3PP80otI32ENy8xTiH9Z0CLXt9neXDuvRjw
 swjC9f3y4oeNAID085G4bmwvjmiQzHs2QY3PeVUXmX6gdeHyJcTl0BfB9Kn9iJyjhaP4 ZQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2qhrekn4kv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:20 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1E02I6f026212
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:19 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1E02Hqw032540;
	Thu, 14 Feb 2019 00:02:17 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:02:16 -0800
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com
Cc: Tycho Andersen <tycho@docker.com>, deepa.srinivasan@oracle.com,
        chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk,
        andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com,
        kanth.ghatraju@oracle.com, oao.m.martins@oracle.com,
        jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com,
        tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de,
        steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
        dave.hansen@intel.com, peterz@infradead.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v8 09/14] mm: add a user_virt_to_phys symbol
Date: Wed, 13 Feb 2019 17:01:32 -0700
Message-Id: <b96108404af22ac25a0b62b81d338bf511002f63.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tycho Andersen <tycho@docker.com>

We need someting like this for testing XPFO. Since it's architecture
specific, putting it in the test code is slightly awkward, so let's make it
an arch-specific symbol and export it for use in LKDTM.

CC: linux-arm-kernel@lists.infradead.org
CC: x86@kernel.org
Signed-off-by: Tycho Andersen <tycho@docker.com>
Tested-by: Marco Benatto <marco.antonio.780@gmail.com>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
v6: * add a definition of user_virt_to_phys in the !CONFIG_XPFO case
v7: * make user_virt_to_phys a GPL symbol

 arch/x86/mm/xpfo.c   | 57 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/xpfo.h |  8 +++++++
 2 files changed, 65 insertions(+)

diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
index 6c7502993351..e13b99019c47 100644
--- a/arch/x86/mm/xpfo.c
+++ b/arch/x86/mm/xpfo.c
@@ -117,3 +117,60 @@ inline void xpfo_flush_kernel_tlb(struct page *page, int order)
 
 	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
 }
+
+/* Convert a user space virtual address to a physical address.
+ * Shamelessly copied from slow_virt_to_phys() and lookup_address() in
+ * arch/x86/mm/pageattr.c
+ */
+phys_addr_t user_virt_to_phys(unsigned long addr)
+{
+	phys_addr_t phys_addr;
+	unsigned long offset;
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	pgd = pgd_offset(current->mm, addr);
+	if (pgd_none(*pgd))
+		return 0;
+
+	p4d = p4d_offset(pgd, addr);
+	if (p4d_none(*p4d))
+		return 0;
+
+	if (p4d_large(*p4d) || !p4d_present(*p4d)) {
+		phys_addr = (unsigned long)p4d_pfn(*p4d) << PAGE_SHIFT;
+		offset = addr & ~P4D_MASK;
+		goto out;
+	}
+
+	pud = pud_offset(p4d, addr);
+	if (pud_none(*pud))
+		return 0;
+
+	if (pud_large(*pud) || !pud_present(*pud)) {
+		phys_addr = (unsigned long)pud_pfn(*pud) << PAGE_SHIFT;
+		offset = addr & ~PUD_MASK;
+		goto out;
+	}
+
+	pmd = pmd_offset(pud, addr);
+	if (pmd_none(*pmd))
+		return 0;
+
+	if (pmd_large(*pmd) || !pmd_present(*pmd)) {
+		phys_addr = (unsigned long)pmd_pfn(*pmd) << PAGE_SHIFT;
+		offset = addr & ~PMD_MASK;
+		goto out;
+	}
+
+	pte =  pte_offset_kernel(pmd, addr);
+	phys_addr = (phys_addr_t)pte_pfn(*pte) << PAGE_SHIFT;
+	offset = addr & ~PAGE_MASK;
+
+out:
+	return (phys_addr_t)(phys_addr | offset);
+}
+EXPORT_SYMBOL_GPL(user_virt_to_phys);
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 8b029918a958..117869991d5b 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -24,6 +24,10 @@ struct page;
 
 #ifdef CONFIG_XPFO
 
+#include <linux/dma-mapping.h>
+
+#include <linux/types.h>
+
 extern struct page_ext_operations page_xpfo_ops;
 
 void set_kpte(void *kaddr, struct page *page, pgprot_t prot);
@@ -49,6 +53,8 @@ void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
 
 bool xpfo_enabled(void);
 
+phys_addr_t user_virt_to_phys(unsigned long addr);
+
 #else /* !CONFIG_XPFO */
 
 static inline void xpfo_kmap(void *kaddr, struct page *page) { }
@@ -73,6 +79,8 @@ static inline void xpfo_temp_unmap(const void *addr, size_t size,
 
 static inline bool xpfo_enabled(void) { return false; }
 
+static inline phys_addr_t user_virt_to_phys(unsigned long addr) { return 0; }
+
 #endif /* CONFIG_XPFO */
 
 #endif /* _LINUX_XPFO_H */
-- 
2.17.1

