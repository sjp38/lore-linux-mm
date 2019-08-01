Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1583AC32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:43:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5AAE2084C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:43:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Es8L2Bvd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5AAE2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 724CF6B000C; Thu,  1 Aug 2019 14:43:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D4A06B000D; Thu,  1 Aug 2019 14:43:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EB7F6B000E; Thu,  1 Aug 2019 14:43:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 239BA6B000C
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:43:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e20so46351151pfd.3
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:43:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=C54ZWbJvrFTMnXF4mH3WgvCiOakGl9oWpo4pI3ucJzc=;
        b=D2DK18/5Hj73Ty7WqPWrJ5wLuzSW8qUitpu+yPyebXDLYaAYnstRr5/Lua1C6xOuEq
         qeRjPeAIU3Lk75XXa9qO7HW0tX29WIBaAN2zDYjdThyKO5mWcm39PBSoavSaceGNntlt
         jfJWrdu7IKYmjUdttCzvw9/dt4OEzxk00p/4VmnLiZLl5co72f4Rnt+srLGFhhLRjec/
         p7H2nt4uBntAG5EteGoitZlkBSP/yK87HLei1Id3elznVZjm4z5D5YPQhHSev7yOy2hQ
         gQunA26WN/4Bkl0YGpaCerZ7TB4UYyXba4m/jbNmFK+9FVFQq+IJzUbue1ViXnILacSq
         j7ng==
X-Gm-Message-State: APjAAAVMU4i81nzBFYJcic/PAE9EHghmc6bWHKlGR9TwRVFBUfzljcRT
	NMVQz4rY/akvEDNuNlE1Ncbo1H0WktOGtvQkt6ex0HsnAyMhYTE/j9tyK2ueLXZ6a6xL+ugV9mI
	SXA1Gfl38/VS7/Gr6ZxaIIw+qSFxmfn5SDweqZYENlzakUz/b3NHKwEEWJcrxvJqn7w==
X-Received: by 2002:a17:902:5ac4:: with SMTP id g4mr130475159plm.80.1564684997810;
        Thu, 01 Aug 2019 11:43:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxy8VLAHQBdTaEN/fr/qVzJoo5uu/Z4ral8CsQz+6qO883eJTBqTLGutppjMZb20bziAQSS
X-Received: by 2002:a17:902:5ac4:: with SMTP id g4mr130475120plm.80.1564684997235;
        Thu, 01 Aug 2019 11:43:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564684997; cv=none;
        d=google.com; s=arc-20160816;
        b=IDhXZgVv4qPYtY0Ae3Qt2LZYGUS4clbmEaqsGHM6WT1Gwx3LqV2afC1poAXZv6EYz+
         lWdHCGQiKMWM+MfyjhSSRmtKt4TNMEJrZ4kGbBseS/S+3zYAQSeSYnQD+lS4a8kRlUH8
         xHeQX5nFLhytlUytejsOV/2bBGLLeZu3Y+aex3UsWv16j+e39DrLI4f+qjn1rz4RpLZ5
         vpXQGrfucImO+KKvMuqYdb2nIDEWDkqaClqBXi6sit3tO+NRYn/UJkat5J6JnietoKh0
         DKuZhRLb7R44dW2kFRN8IkWGcEWiN3OnKTAKWOuU/3bm/WfgwunaXz9Tyx6j4gibj+8R
         POnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=C54ZWbJvrFTMnXF4mH3WgvCiOakGl9oWpo4pI3ucJzc=;
        b=H+OeU3yjVSjgSeFSG4P9u9K2CWYdspDAxXN2YmtRR5IzYE3VGRyC04nz091smJHepT
         afCNg+avzh+X00q0Tl1EfWrQYXsC0ZlTbF6Fv3GSpFcBWOUe2GYsEQFdQLLu9F26R1n0
         4ZVCU/oyBHT9NowQ2M73JpR/V7qXbyfPiTxO5MWmhDnx5zcY2C71yEK8eKAZlwE7ZtXa
         bWO0PPxCpNOvO1CYbgzU69kRk8gOTIJAnJNz+dKiG8JiAAM4tH3mbHFcj9oJdvBi4UQj
         Rf08PsUrLNLt3Q2C/LtqNFEN2M6Kjo6yy21BbwLxGRHTqbtLkv5WA2PH1l76OLmCjfol
         JAfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Es8L2Bvd;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id b6si37167889pfa.76.2019.08.01.11.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 11:43:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Es8L2Bvd;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x71IgjRR026770
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 11:43:16 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=C54ZWbJvrFTMnXF4mH3WgvCiOakGl9oWpo4pI3ucJzc=;
 b=Es8L2BvdNjJH76WMCKEX0o5taV5UXqTKbZYAEpMS3FMusm5Ka57nVshXyXfZY5S4ItGI
 0GVqHnJ0s42u4dyx7NbsC5B3BD8nM6uKP5q3dCJthvZgPRsScfKMuCIxsgqEBQo/phAR
 W9DROEPiHIe4vup/dCGrxEq9JvwdW0ed5po= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u438rgmnr-20
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:43:16 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 1 Aug 2019 11:43:08 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 4683062E1E18; Thu,  1 Aug 2019 11:43:05 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, <hdanton@sina.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v10 3/7] filemap: update offset check in filemap_fault()
Date: Thu, 1 Aug 2019 11:42:40 -0700
Message-ID: <20190801184244.3169074-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190801184244.3169074-1-songliubraving@fb.com>
References: <20190801184244.3169074-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=863 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010194
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With THP, current check of offset:

    VM_BUG_ON_PAGE(page->index != offset, page);

is no longer accurate. Update it to:

    VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);

Acked-by: Rik van Riel <riel@surriel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index aaee1ef96f6d..97c7b7b92c20 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2542,7 +2542,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		put_page(page);
 		goto retry_find;
 	}
-	VM_BUG_ON_PAGE(page->index != offset, page);
+	VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
 
 	/*
 	 * We have a locked page in the page cache, now we need to check
-- 
2.17.1

