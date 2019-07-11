Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6EE1C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71E5B21019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5KLn6vAl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71E5B21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84BC38E00D2; Thu, 11 Jul 2019 10:26:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D87B8E00C4; Thu, 11 Jul 2019 10:26:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 650008E00D2; Thu, 11 Jul 2019 10:26:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAE08E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:49 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id u25so6882444iol.23
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=k/9Fug63afNC647KTGwGwhcj7r27BkaO1PdUgfdBHl8=;
        b=YXAhNpp9YS/+TdqYb5dFYJ9kUruCsihh3CvGHL1pk63VYK0e7Pkra02S0iqjNIkmeL
         qTM8PV8cY0B6tlk3qtYa1HA77fOo4oGBM0jzKjYiDC8WCrLvi7mb/In12Ybzd3zTqRqP
         L8GqwRa84IdZoriIRswOxhK6KPdxnQB5kBE72aaqTod1XVjQK375hGT69aeucOT9mexI
         dPvPUZ6zlWYyTVdkaXGBpBaFXzBllNG/kJPyrCPnJ+N71kMzXVULCY9uIM66h4JYx3c4
         CopKmagIUAat8yIpPwfX8tZdVRWZwH1JZ/YCM6WbIw5hqfAUecXhrYlgfaJpfI2SmIEY
         V/4g==
X-Gm-Message-State: APjAAAVFO4i7/qjoANtcBoF96e3Lbuuyykqp4IbOVENuVG6vLR9jeuot
	pBodtU0CXhsyDqFhzBZ1fidM4jscNtYPNhyfGj4Dg/Zt+2NNshfn4P27eErq8bAve2FR1a/nR1m
	P5w9J9JOwkqvjrj+3ZtX4nNo83+NKuCJlzzpp1f0VSlj9Ad866v1OsViKOetMhB687A==
X-Received: by 2002:a02:bb08:: with SMTP id y8mr4883350jan.51.1562855208991;
        Thu, 11 Jul 2019 07:26:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxG5VIsAmzjMukIltJi53jT6H8wyBOi95FPvSbiVkL5j6sBvH6rKtwftuiMSoRZ/RmMsBEx
X-Received: by 2002:a02:bb08:: with SMTP id y8mr4883278jan.51.1562855208269;
        Thu, 11 Jul 2019 07:26:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855208; cv=none;
        d=google.com; s=arc-20160816;
        b=WOyMUsXtEfoZ/qFvRPWB26Sq5lYeAWdqCSWi4u1GrtWQ5zoDS5ZzahAfHmDWafAUoB
         Navq+fZUtef4JVhJmV48TuJz28LIbuM+buCmx+MPbzgZ9qq0MFcprxorBWz8ZlDg6VuV
         XZJ/fbuO2g3VKZna0a1bTkXlOHMnpRI31rdVf4cVZYaVwtnECCQRylRXG2Nh2vUUpq4o
         Sh2Ni8nbDOUesIAO/2fOI6YJQlY8z2W+fPD0tbWTcs2/QuANCQwvwexHLl4vr+WVg3NX
         uXFI2MZ00one140y4ixUf8ashlf1WyCw3sKD/dcPFpw1fFqq9TsLLaCSM4Midu7xT0xA
         4StA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=k/9Fug63afNC647KTGwGwhcj7r27BkaO1PdUgfdBHl8=;
        b=JnqBDikoqJ00ZfueSsTEWiCC9Yqro96zP44evW/llY/f72gz5YV1Y8k9er2f52hoEZ
         Chqw8YSrvx1TsC/xMczc3QLiLgVnyZu2ZpNXwEuZvjHFzH+S7r3fYJRw86TELj3norJp
         NNsDsq9MvJBoPvj9eKmNRMhbIzIYFLiefwSDZ8U0uPR/DJqdCmy/HwXJ5Xh8Jzmv8FAm
         6q/TldkRpLghxG9JCcWfw0zCzica1THDUh9nHtXqlOlbjiybC2VrXT5pvFVatbW48KVS
         YcU1ko8dMqcYqFMt9vkDpNEg2p9Ku6KSlP7DH9hk5JckYTeGwOd/tSOFfez7qCsDbpeS
         w7qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5KLn6vAl;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id p7si8150221iob.149.2019.07.11.07.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5KLn6vAl;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO90p001480;
	Thu, 11 Jul 2019 14:26:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=k/9Fug63afNC647KTGwGwhcj7r27BkaO1PdUgfdBHl8=;
 b=5KLn6vAlS8mqB4CpSvgIU+Q+dh/FIPZ30597ShKunxhzPyWufNzv9Z2Cx08UVoBiEll/
 JBVMx/vKSYB0C0s+WVyLcIBN58ZXRTbwEhf/IwNYl7zZ7sSsGPjmF/6hyaDRwuF9hk/r
 Od3KI8aMoJde526KmMFcX2swAUblIJ6IEJr7eaGDmgCNG3lLZyVRqS3W4XYV29OC/ZVc
 4mk68QurguhhWeX8FUCmmK47mMaaLROKzVLzTFajITGGIClxoo3c+fKTYG1lt2Dpitky
 k9uYwYmfAA4lryCWr9Zg3nU9L0blXjaO/G+ZtIQSyB+mD3low+GPiTf4kzuLZVh/PRPA cg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2tjk2u0e0w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:38 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcu9021444;
	Thu, 11 Jul 2019 14:26:34 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 16/26] mm/asi: Option to map current task into ASI
Date: Thu, 11 Jul 2019 16:25:28 +0200
Message-Id: <1562855138-19507-17-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=853
 adultscore=26 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add an option to map the current task into an ASI page-table.
The task is mapped when entering isolation and unmapped on
abort/exit.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/asi.h  |    2 ++
 arch/x86/mm/asi.c           |   25 +++++++++++++++++++++----
 arch/x86/mm/asi_pagetable.c |    4 ++--
 3 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/asi.h b/arch/x86/include/asm/asi.h
index 1ac8fd3..a277e43 100644
--- a/arch/x86/include/asm/asi.h
+++ b/arch/x86/include/asm/asi.h
@@ -17,6 +17,7 @@
  */
 #define ASI_MAP_STACK_CANARY	0x01	/* map stack canary */
 #define ASI_MAP_CPU_PTR		0x02	/* for get_cpu_var()/this_cpu_ptr() */
+#define ASI_MAP_CURRENT_TASK	0x04	/* map the current task */
 
 enum page_table_level {
 	PGT_LEVEL_PTE,
@@ -31,6 +32,7 @@ enum page_table_level {
 struct asi {
 	spinlock_t		lock;		/* protect all attributes */
 	pgd_t			*pgd;		/* ASI page-table */
+	int			mapping_flags;	/* map flags */
 	struct list_head	mapping_list;	/* list of VA range mapping */
 
 	/*
diff --git a/arch/x86/mm/asi.c b/arch/x86/mm/asi.c
index f049438..acd1135 100644
--- a/arch/x86/mm/asi.c
+++ b/arch/x86/mm/asi.c
@@ -28,6 +28,7 @@ struct asi_map_option {
 struct asi_map_option asi_map_percpu_options[] = {
 	{ ASI_MAP_STACK_CANARY, &fixed_percpu_data, sizeof(fixed_percpu_data) },
 	{ ASI_MAP_CPU_PTR, &this_cpu_off, sizeof(this_cpu_off) },
+	{ ASI_MAP_CURRENT_TASK, &current_task, sizeof(current_task) },
 };
 
 static void asi_log_fault(struct asi *asi, struct pt_regs *regs,
@@ -96,8 +97,9 @@ bool asi_fault(struct pt_regs *regs, unsigned long error_code,
 	return true;
 }
 
-static int asi_init_mapping(struct asi *asi, int flags)
+static int asi_init_mapping(struct asi *asi)
 {
+	int flags = asi->mapping_flags;
 	struct asi_map_option *option;
 	int i, err;
 
@@ -164,8 +166,9 @@ struct asi *asi_create(int map_flags)
 	spin_lock_init(&asi->lock);
 	spin_lock_init(&asi->fault_lock);
 	asi_init_backend(asi);
+	asi->mapping_flags = map_flags;
 
-	err = asi_init_mapping(asi, map_flags);
+	err = asi_init_mapping(asi);
 	if (err)
 		goto error;
 
@@ -248,6 +251,15 @@ int asi_enter(struct asi *asi)
 		goto err_clear_asi;
 
 	/*
+	 * Optionally, also map the current task.
+	 */
+	if (asi->mapping_flags & ASI_MAP_CURRENT_TASK) {
+		err = asi_map(asi, current, sizeof(struct task_struct));
+		if (err)
+			goto err_unmap_stack;
+	}
+
+	/*
 	 * Instructions ordering is important here because we should be
 	 * able to deal with any interrupt/exception which will abort
 	 * the isolation and restore CR3 to its original value:
@@ -269,7 +281,7 @@ int asi_enter(struct asi *asi)
 	if (!original_cr3) {
 		WARN_ON(1);
 		err = -EINVAL;
-		goto err_unmap_stack;
+		goto err_unmap_task;
 	}
 	asi_session->original_cr3 = original_cr3;
 
@@ -286,6 +298,9 @@ int asi_enter(struct asi *asi)
 
 	return 0;
 
+err_unmap_task:
+	if (asi->mapping_flags & ASI_MAP_CURRENT_TASK)
+		asi_unmap(asi, current);
 err_unmap_stack:
 	asi_unmap(asi, current->stack);
 err_clear_asi:
@@ -345,8 +360,10 @@ void asi_exit(struct asi *asi)
 	 */
 	asi_session->abort_depth = 0;
 
-	/* unmap stack */
+	/* unmap stack and task */
 	asi_unmap(asi, current->stack);
+	if (asi->mapping_flags & ASI_MAP_CURRENT_TASK)
+		asi_unmap(asi, current);
 }
 EXPORT_SYMBOL(asi_exit);
 
diff --git a/arch/x86/mm/asi_pagetable.c b/arch/x86/mm/asi_pagetable.c
index bcc95f2..8076626 100644
--- a/arch/x86/mm/asi_pagetable.c
+++ b/arch/x86/mm/asi_pagetable.c
@@ -714,7 +714,7 @@ int asi_map_range(struct asi *asi, void *ptr, size_t size,
 	 * Don't log info the current stack because it is mapped/unmapped
 	 * everytime we enter/exit isolation.
 	 */
-	if (ptr != current->stack) {
+	if (ptr != current->stack && ptr != current) {
 		pr_debug("ASI %p: MAP %px/%lx/%d -> %lx-%lx\n",
 			 asi, ptr, size, level, map_addr, map_end);
 		if (map_addr < addr)
@@ -1001,7 +1001,7 @@ void asi_unmap(struct asi *asi, void *ptr)
 	 * Don't log info the current stack because it is mapped/unmapped
 	 * everytime we enter/exit isolation.
 	 */
-	if (ptr != current->stack) {
+	if (ptr != current->stack && ptr != current) {
 		pr_debug("ASI %p: UNMAP %px/%lx/%d\n", asi, ptr,
 			 range_mapping->size, range_mapping->level);
 	}
-- 
1.7.1

