Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8D56C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:50:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7355C217F5
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:50:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7355C217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF01F8E0005; Wed, 27 Feb 2019 09:50:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9E8A8E0001; Wed, 27 Feb 2019 09:50:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8E648E0005; Wed, 27 Feb 2019 09:50:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 983458E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:50:12 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id j10so9948360pfn.13
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 06:50:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=L9/MM3/AP4abQ/0RP7o2I3qg7+JXWYT+NmC3x4SG1Dg=;
        b=rMOYVFHVuUKJGaEywez0vonrH9remTXIosGcXXMV+pSIOVHXsmpOnbjvpnPLea6SrV
         5CsEoWSKK0RS+2urnLF4665ZzNdxhzz9mL1TrF+IY+DS3vKDTGuc0YrILUZ8aZG05dLM
         398N/Me+QQdYI6x2v9FIkXM6YwoEyd49rF4nU4y7dhadw1SKMpZ4ygUcnlbUVuZlR29y
         qsXb1YbiCWboYcOFD3I48dXs6wy0MOMFBSW+rNP/+TucOdnu/LNk0tP4PWtkd0+1y6K0
         h36OxvR5H14U5xLjl/wK7u5coBW4Kl3i9IiasHRb9ramO4zIJ3GqQpwlh43FlpisqRTd
         25ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuY3KkuVWPhzTUZ0aznrS1jQaG4l9FEmYIykJsUX5vvTniKyVMsO
	sLP1bGT3BjqhF5iC/w0rAKgf0mDU45I1/jnU+7tT91FoaWsnDo/2CkRp3J5jPB9XLdiyTGHAhBF
	yXY2UmsmnGHpEO5waasTUaqS9oO6/G2MR55cR2WyyNTxMKMQGXAfAFWfCjeMYC7Le1g==
X-Received: by 2002:a62:5385:: with SMTP id h127mr2022877pfb.10.1551279012147;
        Wed, 27 Feb 2019 06:50:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibr7vf6w6NfyzOVWFirKp6zdJO18APWKPktc+GTpd5Pab9a7NCfHbnEL3JVb/SiVlOUHH0W
X-Received: by 2002:a62:5385:: with SMTP id h127mr2022779pfb.10.1551279011080;
        Wed, 27 Feb 2019 06:50:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551279011; cv=none;
        d=google.com; s=arc-20160816;
        b=dd1pESp8IGjgfJtsGym3muVl7kUXgaah7QOdQ/qMfnuR5WcjNrcz68WxP/han7AJ7o
         /7cDqsmpVX+426ekwUJcJEVhcnvjfXcxG04acQIkloq0XwF4eciL9KBrU41CPcfQHsib
         CC4CsVSQCnEMmtGoQ4v79ATM1HiBcvFbCcv0/u/YsX5ehtRYYtXvBdpcL7YKImOEC1QI
         dtJtygAocKbh62L5npYy8aQvNIkf7ZSj144mzAnQk4arGrwtX/BHXmemoNC9GSRWwcP8
         kcI0jsKxIYhThg2sIbJk2ApwHN9miMapSiD0KCGtBDtU6xOVKD3qnDMIbBWDLb53IXti
         nEig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=L9/MM3/AP4abQ/0RP7o2I3qg7+JXWYT+NmC3x4SG1Dg=;
        b=rAVpJyxEeyJ19stwKdiWsKJKVqe746b37KnxEhWu1xSUIPKWw8BSEl8gcrz/Eb45aI
         Rjkbp7RDT1zMkKE9DQwLV8pEDBdl76aCxREXyYTXKgHS6gooAIut0eljNXcuFF4hk/a7
         cu4uVy9qjm4Sc0qan+f8CTRVqAwhz4cw3YwPdE9rIIPZdTlV+FH48u2IovHSXikDW5S1
         Y8IrpvvsdckXYikIt02eTDLkIBekvrBKv+fRGcCuozZ1M3btfq+KKwLYqbqZbTwYvX8C
         eH68E0zGO3Ux/afIQxHtvBIUc6dJwImW9X1zsjz6F6UZNdmcFrJdFOL1OkkpPfrIMW6e
         Ep3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f75si15630520pfh.164.2019.02.27.06.50.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 06:50:11 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1REnuxb022484
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:50:10 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qwua6cnp1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:50:01 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 27 Feb 2019 14:48:03 -0000
Received: from b03cxnp08028.gho.boulder.ibm.com (9.17.130.20)
	by e35.co.us.ibm.com (192.168.1.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 27 Feb 2019 14:48:00 -0000
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1RElxqv30474258
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 14:47:59 GMT
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EB948C6055;
	Wed, 27 Feb 2019 14:47:58 +0000 (GMT)
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9FE6BC6057;
	Wed, 27 Feb 2019 14:47:55 +0000 (GMT)
Received: from skywalker.ibmuc.com (unknown [9.199.49.135])
	by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP;
	Wed, 27 Feb 2019 14:47:55 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>,
        Alexey Kardashevskiy <aik@ozlabs.ru>,
        David Gibson <david@gibson.dropbear.id.au>,
        Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH v8 1/4] mm/cma: Add PF flag to force non cma alloc
Date: Wed, 27 Feb 2019 20:17:33 +0530
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227144736.5872-1-aneesh.kumar@linux.ibm.com>
References: <20190227144736.5872-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19022714-0012-0000-0000-000017116D18
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010674; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01167143; UDB=6.00609716; IPR=6.00947753;
 MB=3.00025765; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-27 14:48:02
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022714-0013-0000-0000-000056591AE2
Message-Id: <20190227144736.5872-2-aneesh.kumar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-27_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902270100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds PF_MEMALLOC_NOCMA which make sure any allocation in that context
is marked non-movable and hence cannot be satisfied by CMA region.

This is useful with get_user_pages_longterm where we want to take a page pin by
migrating pages from CMA region. Marking the section PF_MEMALLOC_NOCMA ensures
that we avoid unnecessary page migration later.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 include/linux/sched.h    |  1 +
 include/linux/sched/mm.h | 48 +++++++++++++++++++++++++++++++++-------
 2 files changed, 41 insertions(+), 8 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index f9b43c989577..dfa90088ba08 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1403,6 +1403,7 @@ extern struct pid *cad_pid;
 #define PF_UMH			0x02000000	/* I'm an Usermodehelper process */
 #define PF_NO_SETAFFINITY	0x04000000	/* Userland is not allowed to meddle with cpus_allowed */
 #define PF_MCE_EARLY		0x08000000      /* Early kill for mce process policy */
+#define PF_MEMALLOC_NOCMA	0x10000000 /* All allocation request will have _GFP_MOVABLE cleared */
 #define PF_MUTEX_TESTER		0x20000000	/* Thread belongs to the rt mutex tester */
 #define PF_FREEZER_SKIP		0x40000000	/* Freezer should not count it as freezable */
 #define PF_SUSPEND_TASK		0x80000000      /* This thread called freeze_processes() and should not be frozen */
diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index 3bfa6a0cbba4..0cd9f10423fb 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -148,17 +148,25 @@ static inline bool in_vfork(struct task_struct *tsk)
  * Applies per-task gfp context to the given allocation flags.
  * PF_MEMALLOC_NOIO implies GFP_NOIO
  * PF_MEMALLOC_NOFS implies GFP_NOFS
+ * PF_MEMALLOC_NOCMA implies no allocation from CMA region.
  */
 static inline gfp_t current_gfp_context(gfp_t flags)
 {
-	/*
-	 * NOIO implies both NOIO and NOFS and it is a weaker context
-	 * so always make sure it makes precedence
-	 */
-	if (unlikely(current->flags & PF_MEMALLOC_NOIO))
-		flags &= ~(__GFP_IO | __GFP_FS);
-	else if (unlikely(current->flags & PF_MEMALLOC_NOFS))
-		flags &= ~__GFP_FS;
+	if (unlikely(current->flags &
+		     (PF_MEMALLOC_NOIO | PF_MEMALLOC_NOFS | PF_MEMALLOC_NOCMA))) {
+		/*
+		 * NOIO implies both NOIO and NOFS and it is a weaker context
+		 * so always make sure it makes precedence
+		 */
+		if (current->flags & PF_MEMALLOC_NOIO)
+			flags &= ~(__GFP_IO | __GFP_FS);
+		else if (current->flags & PF_MEMALLOC_NOFS)
+			flags &= ~__GFP_FS;
+#ifdef CONFIG_CMA
+		if (current->flags & PF_MEMALLOC_NOCMA)
+			flags &= ~__GFP_MOVABLE;
+#endif
+	}
 	return flags;
 }
 
@@ -248,6 +256,30 @@ static inline void memalloc_noreclaim_restore(unsigned int flags)
 	current->flags = (current->flags & ~PF_MEMALLOC) | flags;
 }
 
+#ifdef CONFIG_CMA
+static inline unsigned int memalloc_nocma_save(void)
+{
+	unsigned int flags = current->flags & PF_MEMALLOC_NOCMA;
+
+	current->flags |= PF_MEMALLOC_NOCMA;
+	return flags;
+}
+
+static inline void memalloc_nocma_restore(unsigned int flags)
+{
+	current->flags = (current->flags & ~PF_MEMALLOC_NOCMA) | flags;
+}
+#else
+static inline unsigned int memalloc_nocma_save(void)
+{
+	return 0;
+}
+
+static inline void memalloc_nocma_restore(unsigned int flags)
+{
+}
+#endif
+
 #ifdef CONFIG_MEMCG
 /**
  * memalloc_use_memcg - Starts the remote memcg charging scope.
-- 
2.20.1

