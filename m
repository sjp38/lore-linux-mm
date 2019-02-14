Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33908C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7AF0222CE
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="P8MhcmBs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7AF0222CE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21ECE8E0001; Wed, 13 Feb 2019 19:02:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 172648E0005; Wed, 13 Feb 2019 19:02:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F089E8E0002; Wed, 13 Feb 2019 19:02:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A901C8E0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:02:35 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id ay11so2883045plb.20
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:02:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=pnPAMgXPoRW3Y+XGQjlBeFoy0dFQyjStoDUpBHTUk8o=;
        b=F/1sKKand5GMGVGhFIh2Yt9eviWHOtUEVzyowSYeQuTOHygjoxbDeebYA+as40QL7n
         6BWYTNY2AwwHnu/Zmc1+WqiIZfUio8venC16ZxcyZ4qQUZ2d9n06WgDlGgNZQC6cK2FX
         Hj+XpxK96h4Lnvju30wOas2KMkDZ1fmB7CZreQmeV03FBknrgXzKNcFGpm4q0yz3M6qy
         dGWpL0jJZ/5gmocTTaE4VgVrWL6tpRaYV7rxGqJ7p8ZCwG3KGHp+gZmfk8buI5sAzql+
         1GZ5ku+8yBhiOG5p9O9MJrh07asykYv9MIYyM77NQD86fIQ0gvw2V6bhKTr9WyUCYU/l
         u+tg==
X-Gm-Message-State: AHQUAuZMsopor5dFBZEiprLJkL5OCRRcGVM3rd2JswdWSyDPPFr6+lCj
	FPxLB9H7ubHVrDyhqpKcAtuDgKmdcwquzJIOQJr4QzkSx4+GOldJiPeU81FOogIGRxEIa6IwKvf
	9fNTjw4FsZkBKitXSn5HH9excuu/Kkhxfi2uAOJyKdV/Y4xpSOuPR/fqjEiUnbKNv7g==
X-Received: by 2002:a63:d347:: with SMTP id u7mr787744pgi.383.1550102555314;
        Wed, 13 Feb 2019 16:02:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaJxPJc4zz/jM4z1UYnLDTlDXBfimXXtelR0XPANxVQjJRR0AMTA/vp/VrCJrgU9qaq6Z8+
X-Received: by 2002:a63:d347:: with SMTP id u7mr787682pgi.383.1550102554496;
        Wed, 13 Feb 2019 16:02:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102554; cv=none;
        d=google.com; s=arc-20160816;
        b=hiocQ/au74FWa/9Ao2UwrlMSlYR8dpclTT/DqTnZpuI6QikP5LbZiX+jHIZpqtrECO
         kXFNOfbcfr0ht+y6RRs/u76oBVVnq+ScshhE4XnTzVAuJau+bropSaTywU4mMWOmeJ1Q
         D+Kx383g/Owzi3qf6/f9F7D8PdcncfP4x2SyL1F1FPYeUsrIbxtce5Tl+zQ51bd+YZF1
         v9MPBSoSqmcRjuZRZEtmLJDJYnVodilRFUjOprZb5eMOkTJczKcKDmtvoriNRrdLYgIM
         Wnhontm08L4lC0oQA7439Sgmcj0DN2AlgndgNjnUwxrFvQhc2kxAvqzOfsykYAkF6ZYR
         Q1Gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=pnPAMgXPoRW3Y+XGQjlBeFoy0dFQyjStoDUpBHTUk8o=;
        b=W05gTG2Luu95qAD/9gYJZy+uFn0B5PExTfW+GWkbPwIF+OiKlh8Qa1U4ywU+7sU8KU
         wMYS3GLJzjybYOI9PqN0Co5Lbe/3j88WkCoN8t/vjjSClwsg62k9/y4FHl4SL8Mwu2MS
         hwWjpVCiZv2NUU/ArhDoUWI+NDw+LWa6P5OSokbJkpBxxUe1HW6KZ9fKKo3ZhhdsSrIh
         PF7gnibOKK1AIoZCQl89QfNL4YWHiAc1m6YwkmUw3beeswrMTjZfxqtl07nfwgl7kWc/
         gAbsp9tlilaW15aUnMSKI7nVkXUHw4wveBCB7Ihj89bR7OWyucTD1dKMHAhRzFvt2WAx
         qxMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=P8MhcmBs;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id ct12si899208plb.422.2019.02.13.16.02.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:02:34 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=P8MhcmBs;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNwuiN100575;
	Thu, 14 Feb 2019 00:02:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=pnPAMgXPoRW3Y+XGQjlBeFoy0dFQyjStoDUpBHTUk8o=;
 b=P8MhcmBsqowTapSCWseyQXycsL6swLz4umwP9SBw6+ulLYPgQxLYPAEZ/o9AhHRJONze
 oYae3uML40WaOv1a39/aVVlZlsxyHs9WIr9DlGXDRTDq832AMS1IhnxZR/SlXqxcRSe8
 xVPdOvmpX2ulrj52wlQOEOi4pN4dGsXZqeE8pt03NqDXmySkTKp6Hnrv+rZewUQNaso7
 ele2U7dCemABJxM/iTeQAVNSeCxzWjRiyAQZB4GRIUvXED192Fn5YsV8J3mHml/c/vsR
 1A5jr/53DI9WF3/DXkm1vroHhlCMQMdkWRgRlraDEqbRGW8QDSSClGDzYcI1zO+9cv9T WQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qhre5n3uv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:12 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1E02BWR032120
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:11 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1E029p0032487;
	Thu, 14 Feb 2019 00:02:09 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:02:09 -0800
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
        linux-kernel@vger.kernel.org
Subject: [RFC PATCH v8 06/14] xpfo: add primitives for mapping underlying memory
Date: Wed, 13 Feb 2019 17:01:29 -0700
Message-Id: <c285cc243176ae5fdd22f316dc8b118c1c153434.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=956 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tycho Andersen <tycho@docker.com>

In some cases (on arm64 DMA and data cache flushes) we may have unmapped
the underlying pages needed for something via XPFO. Here are some
primitives useful for ensuring the underlying memory is mapped/unmapped in
the face of xpfo.

Signed-off-by: Tycho Andersen <tycho@docker.com>
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 include/linux/xpfo.h | 22 ++++++++++++++++++++++
 mm/xpfo.c            | 30 ++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+)

diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index cba37ffb09b1..1ae05756344d 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -38,6 +38,15 @@ void xpfo_free_pages(struct page *page, int order);
 
 bool xpfo_page_is_unmapped(struct page *page);
 
+#define XPFO_NUM_PAGES(addr, size) \
+	(PFN_UP((unsigned long) (addr) + (size)) - \
+		PFN_DOWN((unsigned long) (addr)))
+
+void xpfo_temp_map(const void *addr, size_t size, void **mapping,
+		   size_t mapping_len);
+void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
+		     size_t mapping_len);
+
 #else /* !CONFIG_XPFO */
 
 static inline void xpfo_kmap(void *kaddr, struct page *page) { }
@@ -47,6 +56,19 @@ static inline void xpfo_free_pages(struct page *page, int order) { }
 
 static inline bool xpfo_page_is_unmapped(struct page *page) { return false; }
 
+#define XPFO_NUM_PAGES(addr, size) 0
+
+static inline void xpfo_temp_map(const void *addr, size_t size, void **mapping,
+				 size_t mapping_len)
+{
+}
+
+static inline void xpfo_temp_unmap(const void *addr, size_t size,
+				   void **mapping, size_t mapping_len)
+{
+}
+
+
 #endif /* CONFIG_XPFO */
 
 #endif /* _LINUX_XPFO_H */
diff --git a/mm/xpfo.c b/mm/xpfo.c
index 67884736bebe..92ca6d1baf06 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -14,6 +14,7 @@
  * the Free Software Foundation.
  */
 
+#include <linux/highmem.h>
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/page_ext.h>
@@ -236,3 +237,32 @@ bool xpfo_page_is_unmapped(struct page *page)
 	return test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
 }
 EXPORT_SYMBOL(xpfo_page_is_unmapped);
+
+void xpfo_temp_map(const void *addr, size_t size, void **mapping,
+		   size_t mapping_len)
+{
+	struct page *page = virt_to_page(addr);
+	int i, num_pages = mapping_len / sizeof(mapping[0]);
+
+	memset(mapping, 0, mapping_len);
+
+	for (i = 0; i < num_pages; i++) {
+		if (page_to_virt(page + i) >= addr + size)
+			break;
+
+		if (xpfo_page_is_unmapped(page + i))
+			mapping[i] = kmap_atomic(page + i);
+	}
+}
+EXPORT_SYMBOL(xpfo_temp_map);
+
+void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
+		     size_t mapping_len)
+{
+	int i, num_pages = mapping_len / sizeof(mapping[0]);
+
+	for (i = 0; i < num_pages; i++)
+		if (mapping[i])
+			kunmap_atomic(mapping[i]);
+}
+EXPORT_SYMBOL(xpfo_temp_unmap);
-- 
2.17.1

