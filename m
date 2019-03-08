Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6B6BC10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 22:48:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 881A62085A
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 22:48:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LXSg3pRS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 881A62085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 294DC8E0005; Fri,  8 Mar 2019 17:48:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 274B78E0002; Fri,  8 Mar 2019 17:48:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15A718E0005; Fri,  8 Mar 2019 17:48:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C982E8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 17:48:49 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id n10so8440583pgp.21
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 14:48:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=3IApX+ff+PN7FBEvogPd9vgxa4QqAsqb3qIGJTQfIzQ=;
        b=NRB+BcwiZSfsB2t/AVMh9BPRxjDwiV+1gBXx7ZYut/JLlfOSSdK/NhssQunCz+iNJr
         hqx2DUwsamOaoTu8Wlaoq5+dhjDaPFahljhagBcsNy8wt2x8+dDoLC1MyMe4AsXNl6lZ
         BJ7GyY54+rZnTz44ubIKjpPmTeThVmQKX6Y5JkfycL2MS6abn+pgj2DsbgFRPjye1Pro
         OJ9k02YFfEiC/aXik2SlFzx5czdtW8v9SMngKe4kCwrvhh+l1xUCi2SAoR2nF8TWKiJj
         sa7IAyxisXgrG7jnp4ACFJNyoyiiLF1LCFnqnYgFNX+mzC+yWxnPtjXeGLngODrMB3ki
         qkKg==
X-Gm-Message-State: APjAAAUXi5v8oEN/ijXfAHkuaV4gN8JJtoJtkaHPTRTI75R3n61St+pm
	2G2KAeDF5CmRfABO570+jYGzC0hLzgKWQpGlmSUSQ8v0BYxx5MglH4LiRcFzBfw18ox1Ewc0LTW
	kss8P4N4QYyN6pYXCx2zPbxiUBPHswMM5q3mGqzk1MM1DACaBq9WZz1Li2giSJothMw==
X-Received: by 2002:a17:902:403:: with SMTP id 3mr21354823ple.48.1552085329455;
        Fri, 08 Mar 2019 14:48:49 -0800 (PST)
X-Google-Smtp-Source: APXvYqx4HxpfFPJznTAn1xckhFajjkmf4uXmXp8Ax2DNXprGi4odfpEfa/eeWi0NsAOJu6btptcs
X-Received: by 2002:a17:902:403:: with SMTP id 3mr21354735ple.48.1552085327747;
        Fri, 08 Mar 2019 14:48:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552085327; cv=none;
        d=google.com; s=arc-20160816;
        b=g7Ts9AD39L005pdGwdk5cUAGAuVa7ZHCC0dcoLb/0nUMO0opUchnMq6de3mmYuEuRH
         cehJXZvtSFaamFu97+dzF+vpIx+nE4fPxm2JwA9KKNG2oF4nzU6HHzqer/yql8Vn8nNm
         Q/Im4F+x2MsxfNrjxX6wpuxEHx2oAxwo8kDwPov6Z2TtCgunAhdYZj91PiaqwCrxKf1x
         w2sWrA2MFMdWCZ3Maixg815tjIj7mDywY/MK/U9RNQh0Brfhky9Qk8GvLM4LwRTjtkv5
         m0X1hprjiPV4NymPYN880nUDf7GkI77ipBBaIw6Cox0DiokcmrLYmKCreYO6VM6cynGE
         jyng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=3IApX+ff+PN7FBEvogPd9vgxa4QqAsqb3qIGJTQfIzQ=;
        b=n+dDisBOQMElpkhLSjNWbvV08C7Pf8nepdYv2KWKFhJnbPvJ5YUPtRuvpf3VOUZ+yx
         v63p16+uJ/tTRBqQ/bcVm+wRuwiE2GUPQA9dhCJiK5Nj4ebVH7eFKAE64zVvCDYXN0Id
         3fIbE4ieIz4G2+HKdg7MgAKgPYrG+igARcyqVXajLRfiNUjs19xSZsFW67v5tPsbSFMa
         XczZl9oOLXr3vIjI8kpJ/g/e97MHwVI0hmEktl0/K2MYktfhjBquJnhA/BYJdWTR3F9V
         PGpiaFvELrDayySRVJ+qsPfa/HllbRLDZo+zJ8S8UYFeLy1Ps6uCFeztaXPctPLXr8nO
         F+aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LXSg3pRS;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id m7si7415229pgp.187.2019.03.08.14.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 14:48:47 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LXSg3pRS;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x28Mhaic022226;
	Fri, 8 Mar 2019 22:48:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=3IApX+ff+PN7FBEvogPd9vgxa4QqAsqb3qIGJTQfIzQ=;
 b=LXSg3pRSyzoFxVwwJJj6ZyK/EgUfqoJe1+3eSW24zye2++DcnRnvgE2e3fChV8tR7Fo6
 kEUhAv775oyvS3cu0ertrbN9BJ/xm5/L0KnMnzvhv+/rhPlziEZZomryG+SqjQhCeiC5
 okqbFeviivTh/4zG5uIkZzTUgYlWXWxoxlJaZqKiUyK5TgJ2rE6+a9RgWCu+8Ya5qPgw
 NraN1d+71QYuq8X7TeNfszD4/X2CtV3ND7GaX3kseyfCXipJIIQc5hFkBCBZ86QvxVWw
 ZEW9R+hPfSROA3AQJtVKhOLUYO6Xg047jB6TXJ9eBrW8PTtsuEWrcXXyp/xbnt1Plfwf ew== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qyjfs2r3s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 08 Mar 2019 22:48:44 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x28MmhpL009210
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 8 Mar 2019 22:48:43 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x28Mmhrh027803;
	Fri, 8 Mar 2019 22:48:43 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 08 Mar 2019 14:48:43 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Davidlohr Bueso <dave@stgolabs.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 2/2] hugetlb: use same fault hash key for shared and private mappings
Date: Fri,  8 Mar 2019 14:48:23 -0800
Message-Id: <20190308224823.15051-3-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.17.2
In-Reply-To: <20190308224823.15051-1-mike.kravetz@oracle.com>
References: <20190308224823.15051-1-mike.kravetz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9189 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=734 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903080157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hugetlb uses a fault mutex hash table to prevent page faults of the
same pages concurrently.  The key for shared and private mappings is
different.  Shared keys off address_space and file index.  Private
keys off mm and virtual address.  Consider a private mappings of a
populated hugetlbfs file.  A write fault will first map the page from
the file and then do a COW to map a writable page.

Hugetlbfs hole punch uses the fault mutex to prevent mappings of file
pages.  It uses the address_space file index key.  However, private
mappings will use a different key and could temporarily map the file
page before COW.  This causes problems (BUG) for the hole punch code
as it expects the mutex to prevent additional uses/mappings of the page.

There seems to be another potential COW issue/race with this approach
of different private and shared keys as notes in commit 8382d914ebf7
("mm, hugetlb: improve page-fault scalability").

Since every hugetlb mapping (even anon and private) is actually a file
mapping, just use the address_space index key for all mappings.  This
results in potentially more hash collisions.  However, this should not
be the common case.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 64ef640126cd..0527732c71f0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3904,13 +3904,8 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 	unsigned long key[2];
 	u32 hash;
 
-	if (vma->vm_flags & VM_SHARED) {
-		key[0] = (unsigned long) mapping;
-		key[1] = idx;
-	} else {
-		key[0] = (unsigned long) mm;
-		key[1] = address >> huge_page_shift(h);
-	}
+	key[0] = (unsigned long) mapping;
+	key[1] = idx;
 
 	hash = jhash2((u32 *)&key, sizeof(key)/sizeof(u32), 0);
 
-- 
2.17.2

