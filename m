Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 724BDC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:37:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F5C520880
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:37:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="AiQRTnJE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F5C520880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 784166B000E; Wed,  7 Aug 2019 19:37:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 739856B0010; Wed,  7 Aug 2019 19:37:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 587D06B0266; Wed,  7 Aug 2019 19:37:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 395956B000E
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 19:37:49 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id r206so5243449ybc.6
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:37:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=NLo+kUCCETQ4ngAnRD6GoEVLB9ZFwANLd+99Aj/UcOA=;
        b=den/rCogEjvyLNHE3Uv6s+dv2Bfi/sMOpSlwEb5CgT/MmiZJoSuW0IIoO4LH0o2Q4s
         TTBMkX/YU3RcHYEWHGBgPLnhHqrCD1EgsCdnpBjy8eDoFVoOUje4yGhjKN9DlkFojIRi
         HOAeFZZrxvBSJIRTHVoL214MaM9Q54rt39rgkoK0YfQRZLVqcksP0WuzKN9lJyqTIYkt
         3A0NzUd43aufbWTrIwNd9cSWJgDnfL3CMEuWOnz11sq6Rfh0Lr5mEQpohpAxNCUzPoDp
         aDiVR3QIB3EVkMNlbNJ9o32byJN7WvyPTamA4acvUaECEdnswjjLjZ+4tm4rN8OoHNkc
         jbcg==
X-Gm-Message-State: APjAAAUH2w8TekRyP4heDuQKYVoWKTFtuyjAcjRINwmBHV0XtsSaB7XA
	d13ze3J7c8y8Lyk/zFy1/qrgmzSqkYU4SEmkzhm8Gwh6OaMIk0t6tH18TRcdg2UD/uNDjVL0xG5
	1mZVVuI3IRQcX0Ii8mGm/KuI1pryK7B5AAChKmNgELW+UM8eQ6Ylz4D9EOSp6RUGxAQ==
X-Received: by 2002:a81:1188:: with SMTP id 130mr994299ywr.132.1565221068848;
        Wed, 07 Aug 2019 16:37:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSWDzX8LgKSI8LyeT39eXTPpwIYOEpy4UY0dHiq6twcuIg4U0ltR+XEcf5O/87suehoSoA
X-Received: by 2002:a81:1188:: with SMTP id 130mr994282ywr.132.1565221068324;
        Wed, 07 Aug 2019 16:37:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565221068; cv=none;
        d=google.com; s=arc-20160816;
        b=dQyTLxkvvo3bZ88gaH1nRs2i+3XcRmbdneyrGqw5ki966zjl0uR08N0+HhW9KSyjlN
         NcHl/jhdpkyA3EuKPDoXQsRoDGvozfxkrrtj/9yKarhlcomSJ10kGxSeGkg7/cOUtdfX
         FIrsA7iM/Vp5BFk7cmU4qwf7zdM1OWMsk9Qote/aNz0/t8x6ToANzPTaFypol/u7kmy4
         vFd5CAoFfsNZ7ZcXCM+DrcKq8lCW6yzVdio6tUnFJu/8f5E1RPoY74uhFQK5f5Jw9IJV
         7Ax3uPvZmH9L6Q8vO8xl2HJ1jl7ptw+p/XRC6kiKjAzpVj9YRfiJTgKvbsA2Sp+vXKo6
         K9Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=NLo+kUCCETQ4ngAnRD6GoEVLB9ZFwANLd+99Aj/UcOA=;
        b=X1PK70+lW9vBX6hIBODb/zK4zvv3f1dwA38UH1q5PA6nWw9yhu1oVQqj2rVCIOxsBC
         ZuX63szhr5erf941GzkSqErtUget0q8lYzIAodSdS1ZYMpv5LBH8RtRlBl9sZebiXC5Q
         SP7PYn7IlvdJFpIMyv541acIuuzI8DLqYxD/2SS8L9AgAaqNh0hP/EhvQsBsbHHYtigj
         BRb43J0OAYV1fER7qG1+GmhVgpTiklpaYmnCvrk05aJh9mMus+MBPaxVG4Y0AQLmYr9F
         rwYI+Ohd0br274uhUi3oYcvPuTRQhY3xCO5eiRzGOQCXdLwQO7TrXxIjtdE6VTUgjrtn
         9Cew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=AiQRTnJE;
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d67si29963435ywf.407.2019.08.07.16.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 16:37:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=AiQRTnJE;
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x77NXnwX003599
	for <linux-mm@kvack.org>; Wed, 7 Aug 2019 16:37:48 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=NLo+kUCCETQ4ngAnRD6GoEVLB9ZFwANLd+99Aj/UcOA=;
 b=AiQRTnJEbjw7LPcoxeULFKcunsOEME5Pa3F/2vM5Z9o8A3yN9qTXLKIB/3rnvNWQ8nZu
 sOMS9zfVMpLXOYDv9k4kRFAlFmBMPneHXCSFPkWPqqVTKwhMRfVADDQPtWwgXI+FDvIZ
 8gqnyjsfz/2Qj4ewiFp+jTqSEDDmofuEZ70= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2u87uf8414-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:37:48 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 7 Aug 2019 16:37:46 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 8712062E2D9E; Wed,  7 Aug 2019 16:37:45 -0700 (PDT)
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
Subject: [PATCH v12 6/6] uprobe: collapse THP pmd after removing all uprobes
Date: Wed, 7 Aug 2019 16:37:29 -0700
Message-ID: <20190807233729.3899352-7-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190807233729.3899352-1-songliubraving@fb.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-07_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=424 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908070208
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After all uprobes are removed from the huge page (with PTE pgtable), it
is possible to collapse the pmd and benefit from THP again. This patch
does the collapse by calling collapse_pte_mapped_thp().

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 27b596f14463..94d38a39d72e 100644
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
+		collapse_pte_mapped_thp(mm, vaddr);
+
 	return ret;
 }
 
-- 
2.17.1

