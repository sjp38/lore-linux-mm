Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A50A1C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 18:34:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F8FC206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 18:34:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="PPotgx+T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F8FC206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08FA28E0006; Wed, 31 Jul 2019 14:34:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 041078E0001; Wed, 31 Jul 2019 14:34:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4AC08E0006; Wed, 31 Jul 2019 14:34:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0C968E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 14:34:06 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id b18so43408231pgg.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:34:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=S84BXpGsArP8gRpx4jT/dGDAfOA51Safqnff7k6UND8=;
        b=cie1l6sERKk8u8U/T6Bz5wfzZVuvozdeC37DM37Z8F3rqM9E0qZohycd8BccKiNzt9
         DV7GD22yfMFvd3j5g7gPknD4KM9eKImA9hR5ooJ+7MebWquTveYEH5CJyEB+9+KveyVi
         Ro3J7JrYUYydNItBDDjnPzHzNF5zUB089yPchchux7YeMUSaAwCAQufEfBKxEEZtPNiv
         lqRU736vH6F1t0yJrgdkeemdXX1NbYNyKa4JfdA4hK1fK7eSvrlcZ+Y6l3o6JlBc9Y4B
         xJ02bFFs3XsgxfSPQuz8Ys+sWqkdCjAfTL1c6l/We/CSmLlrdX5Fhck4bBszjQ5FHwuj
         8sOw==
X-Gm-Message-State: APjAAAUO8x9vXMc3apK+U0FP72LgQG9BqvWuKOXV2D+eGoB10XYI2PRJ
	6s2otFA8TDz7JpLwnA2hJ+N7PInm2vIM/CSONNIdQnbs76fRxl6yVZT4oVSLDwpMGBaFzOhRxFc
	YqyyVEvGTNPoGRn/tURKfkHQ+4luB1LC/kig9lUHIzjpNiltgm1W5iMXJw8NmRfS2Hw==
X-Received: by 2002:a17:902:8207:: with SMTP id x7mr122113037pln.63.1564598046302;
        Wed, 31 Jul 2019 11:34:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgaBNos6CoeotSKAHFoXEORDI0R1KkELO2hqaPDSa6rpi22hEuNOFX3O4YARsDgloJcygq
X-Received: by 2002:a17:902:8207:: with SMTP id x7mr122113001pln.63.1564598045703;
        Wed, 31 Jul 2019 11:34:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564598045; cv=none;
        d=google.com; s=arc-20160816;
        b=cC4OeG7VLCBPYK4Y5ExoBXF19mBQiDjKB7rRV6EvS9OaipHlAAyA72s5HzI34O8YNP
         c+23fZQRA4JVSeKdFJ7eervM9Nd5gUJfqCFZgJboOmRf94Bb1gBLyUhFIfN/5VTvU/VA
         v0gluRikrDy1IXbzAUB+Q2Q3QdEPelkOpyIc6mpXBkdj/eO7lJzCjb7CGBD3pTJDlIzm
         MjUIRE3rdFr+fm7ZRCLEshZTIh1eqAaSV2l3cmaSydhFMzn+5TF51WL6OkDn981rqoE5
         jh2QqhpdTmfECYMFbIaTChX64GxfEjOK0x9+o4MrukHj7b0IWONTvC0xbUdMf+r9WfyU
         G4dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=S84BXpGsArP8gRpx4jT/dGDAfOA51Safqnff7k6UND8=;
        b=fY+5zVsn2dYIAwERzK04A3Nuv+lAzQ93gwok+etm40KQU6vbg/a51QFJVpd1d/N8D7
         Qo0Vo5ECX1lGxE1zSPRIdz+Kvbci5psR33adraWQze1M11TnVuMHFtfdfsITIpEcoUg6
         rErBKjWgasBjilml9A6GgUV+c88MWs6s8hB6QSkjtRBp1Q2t1r6BOHnXMW/ccTir21WQ
         GW+5OHYu2lIvzk5C+xuYxnXMEZeR4SxuDASnFbHhYPdRE4DJYxUQBvwUIR36laZVg10+
         eiqzawidxF5oLWwzPydGpxBij6elpGW8tgWmJ1LlK9+uik1dVkoi93/qaOnerm9sVvnn
         73eA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PPotgx+T;
       spf=pass (google.com: domain of prvs=3115c6337e=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3115c6337e=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p17si28526464pgm.238.2019.07.31.11.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 11:34:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3115c6337e=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PPotgx+T;
       spf=pass (google.com: domain of prvs=3115c6337e=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3115c6337e=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6VIWkO9007320
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:34:05 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=S84BXpGsArP8gRpx4jT/dGDAfOA51Safqnff7k6UND8=;
 b=PPotgx+T02mUnkJtzfdAahQCsMtNDPcOAJE4FsfH+HW1pFFI/GAnG3RGLnj/ayFXv3Hf
 K7xVsCp9+Mb36e/m12+ceQcP2hzCvMVdNcyS5aMsmOUD9uCKSOtfJoI6wv2iHyoVHkB1
 l6YE5YpZyMsDIU/I3dIEmMpkGyxrZ9ytfAE= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u3c8bs5s9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:34:04 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 31 Jul 2019 11:33:57 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 6ABC962E1BBA; Wed, 31 Jul 2019 11:33:55 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <oleg@redhat.com>, <kernel-team@fb.com>,
        <william.kucharski@oracle.com>, <srikar@linux.vnet.ibm.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v2 2/2] uprobe: collapse THP pmd after removing all uprobes
Date: Wed, 31 Jul 2019 11:33:31 -0700
Message-ID: <20190731183331.2565608-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190731183331.2565608-1-songliubraving@fb.com>
References: <20190731183331.2565608-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-31_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=421 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907310187
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After all uprobes are removed from the huge page (with PTE pgtable), it
is possible to collapse the pmd and benefit from THP again. This patch
does the collapse by calling collapse_pte_mapped_thp().

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 27b596f14463..e5c30941ea04 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -26,6 +26,7 @@
 #include <linux/percpu-rwsem.h>
 #include <linux/task_work.h>
 #include <linux/shmem_fs.h>
+#include <linux/khugepaged.h>
 
 #include <linux/uprobes.h>
 
@@ -472,6 +473,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	struct page *old_page, *new_page;
 	struct vm_area_struct *vma;
 	int ret, is_register, ref_ctr_updated = 0;
+	bool orig_page_huge = false;
 
 	is_register = is_swbp_insn(&opcode);
 	uprobe = container_of(auprobe, struct uprobe, arch);
@@ -529,6 +531,9 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 				/* let go new_page */
 				put_page(new_page);
 				new_page = NULL;
+
+				if (PageCompound(orig_page))
+					orig_page_huge = true;
 			}
 			put_page(orig_page);
 		}
@@ -547,6 +552,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	if (ret && is_register && ref_ctr_updated)
 		update_ref_ctr(uprobe, mm, -1);
 
+	/* try collapse pmd for compound page */
+	if (!ret && orig_page_huge)
+		collapse_pte_mapped_thp(mm, vaddr & HPAGE_PMD_MASK);
+
 	return ret;
 }
 
-- 
2.17.1

