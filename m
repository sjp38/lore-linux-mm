Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03C15C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:38:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A02E1227BF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:38:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="OBXaf/q6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A02E1227BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 374D06B0003; Wed, 24 Jul 2019 04:38:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 324946B0006; Wed, 24 Jul 2019 04:38:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ED9C8E0002; Wed, 24 Jul 2019 04:38:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D91276B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:38:20 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x10so28091936pfa.23
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=fdQGaz4EpVqsr8IruEHXBQPn+tzS7bteUBGGvvH6wDw=;
        b=JAvi1VtSgx4GqjUvc/EY5MlRMKqUmos6squy0b4DAhTupVj3t22QGqtjB5fK1UbOZR
         4uXrCb66AKcgVXWQ5pK1O+jSeS83/VxGsmgSDBOEMJDHKfg15zjNsH25lezsKL6SvuuL
         Pwxsd7YOTqfR+D4hGfZ//aCuuzxTS3SGGFhyHdxJBhs4mCCCXJ2tw10glPPZfUxQa24M
         yp5/BCN6Sv1fKDbNCTu/XLe8IKUUrjWIf9t4V5LHOYjrkOlaz0IEn/V2w5HOjBOEilL5
         DFnY82hcHAHUVGnn/6NAjFgsrBvHBsTsPKSw5MeaC0rfeZJrdeYRV4oVNVxGqIqKGeLt
         HX2w==
X-Gm-Message-State: APjAAAXRiXHJ14TXgpoodFT3ptr+5fglh/TvrnSeqMp990g0BCBt4OyT
	CNTBXVAuJAdJOhYYo+p1T9hYHnyOKLoq2YIAeK5Bm4sx/WMOIuJNTQ9ucCJOB3TMgqnVpsi5CTi
	HJm1QrKZFgmwHmuN3kc1QgoCbjNZc8x6dDAuomOF3ktCtm+/J44p4E8Bn59hE4InWKQ==
X-Received: by 2002:a17:902:9a06:: with SMTP id v6mr82602508plp.71.1563957500557;
        Wed, 24 Jul 2019 01:38:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxW9FuzXflYZUx/WdyFwCI6LylBSQR9iLUXdZnH/Y3BNPX5FtlVXpZy7Tx3MvPigcmvuSBH
X-Received: by 2002:a17:902:9a06:: with SMTP id v6mr82602488plp.71.1563957499930;
        Wed, 24 Jul 2019 01:38:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563957499; cv=none;
        d=google.com; s=arc-20160816;
        b=UWnd421nmok2yOWMebOg/+EijNO2lK3O1lu9JjzJCrrS0Rk8nkmddgHNZkvXoq4tlY
         E3cu6OVA+kY1YjZxq8Jfpd1EguuP7SyIlDx5FloLzCnQhcXn0LKU1qhApZVHJeo3Nl/I
         A1mmjLwoVJdZFkYX2UEJkwoI/wCxyQQxX1HPZJH+te8kOwV+nRNXqDyNJC2KPmwNnpLn
         iZCWSA/bTuCxk2D52hffMv6nzlkxX2t9CiH1Lcz0h/gGDzSwgi84BJb+jWgdesCJy1Ip
         oxHt2t6p680+8Ud/qXhvf4YeyFKsTMAIH3hG1H0Dz51U5kdA93QpSDEV9Jl/twU3rPpN
         e9WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=fdQGaz4EpVqsr8IruEHXBQPn+tzS7bteUBGGvvH6wDw=;
        b=P2kZywqmYgkahfh/kUFq7NPtuXILepVD213qEZcjuBZif1A/PyWySfzoD2RAkdZnbx
         vtsmI5askjXDBlYaEefanMi9AX18eOcQ6HxcobmYpGQvQsdWhnCA08yXZw5zurDaPLWS
         EUjAAT6/oebGXqvyvakN7V/keDig4dEYJQi1iwalAX+Gzt1yeTN7hFqZXINN19yuxtRE
         zjhha1QW7yOB7dNt3FV9RcQlZkeREveL8HDCfzmFyefmjB48kTHWJug6xh2cVr7+4fzg
         UH+ggtUriMpk9q50FQtHHW4tX4BkVek/C8gGt2EJQm7fbpbm5oG9JFWIfMoDEVN9m10z
         pkPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="OBXaf/q6";
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a130si3970828pfa.7.2019.07.24.01.38.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:38:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="OBXaf/q6";
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6O8c5Eb009731
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:19 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=fdQGaz4EpVqsr8IruEHXBQPn+tzS7bteUBGGvvH6wDw=;
 b=OBXaf/q6D1hNWZZGG0d+m/rm3OiMOOzTivGKKNrE0restt7dQZpVq/YGozpXbGewSArm
 DlJr4i48mhMlIQHUjqBsZZsmYHwf40EarudAi1I54FBazlFqjqbf+2XTpz+R6DiVsf67
 r3ZNPh/bGCIOcFnZtoad9xxxTKOPxVX4oVc= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2txcwahabe-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:19 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 24 Jul 2019 01:38:17 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 1A04B62E30E3; Wed, 24 Jul 2019 01:36:15 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v8 4/4] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Date: Wed, 24 Jul 2019 01:36:00 -0700
Message-ID: <20190724083600.832091-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190724083600.832091-1-songliubraving@fb.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-24_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=744 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907240097
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patches uses newly added FOLL_SPLIT_PMD in uprobe. This enables easy
regroup of huge pmd after the uprobe is disabled (in next patch).

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 6b217bd031ef..7d11ea16d471 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -153,7 +153,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page_vma_mapped_walk pvmw = {
-		.page = old_page,
+		.page = compound_head(old_page),
 		.vma = vma,
 		.address = addr,
 	};
@@ -165,8 +165,6 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
 				addr + PAGE_SIZE);
 
-	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
-
 	if (!orig) {
 		err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL,
 					    &memcg, false);
@@ -483,7 +481,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
+			FOLL_FORCE | FOLL_SPLIT_PMD, &old_page, &vma, NULL);
 	if (ret <= 0)
 		return ret;
 
-- 
2.17.1

