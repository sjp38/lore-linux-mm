Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D31EAC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:43:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A784206C2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:43:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A784206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39F6A6B0003; Tue, 13 Aug 2019 09:43:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 350186B0006; Tue, 13 Aug 2019 09:43:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23F096B0007; Tue, 13 Aug 2019 09:43:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0138.hostedemail.com [216.40.44.138])
	by kanga.kvack.org (Postfix) with ESMTP id 043156B0003
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:43:46 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id AD1A5180AD805
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:43:46 +0000 (UTC)
X-FDA: 75817522452.25.sink54_783bf9bfb8107
X-HE-Tag: sink54_783bf9bfb8107
X-Filterd-Recvd-Size: 4183
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:43:46 +0000 (UTC)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7DDfuBN104685
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:43:44 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ubwm6tch7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:43:44 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 13 Aug 2019 14:43:42 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 13 Aug 2019 14:43:39 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7DDhcuT43712912
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 13 Aug 2019 13:43:38 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 65CAB42042;
	Tue, 13 Aug 2019 13:43:38 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1E4B842045;
	Tue, 13 Aug 2019 13:43:37 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.59])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 13 Aug 2019 13:43:37 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Tue, 13 Aug 2019 16:43:36 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] mm: use CPU_BITS_NONE to initialize init_mm.cpu_bitmask
Date: Tue, 13 Aug 2019 16:43:35 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19081313-0020-0000-0000-0000035F2C7B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19081313-0021-0000-0000-000021B4414D
Message-Id: <1565703815-8584-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-13_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=918 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908130145
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace open-coded bitmap array initialization of init_mm.cpu_bitmask with
neat CPU_BITS_NONE macro.

And, since init_mm.cpu_bitmask is statically set to zero, there is no way
to clear it again in start_kernel().

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 init/main.c  | 1 -
 mm/init-mm.c | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/init/main.c b/init/main.c
index 96f8d5a..e29becc 100644
--- a/init/main.c
+++ b/init/main.c
@@ -594,7 +594,6 @@ asmlinkage __visible void __init start_kernel(void)
 	page_address_init();
 	pr_notice("%s", linux_banner);
 	setup_arch(&command_line);
-	mm_init_cpumask(&init_mm);
 	setup_command_line(command_line);
 	setup_nr_cpu_ids();
 	setup_per_cpu_areas();
diff --git a/mm/init-mm.c b/mm/init-mm.c
index a787a31..fb1e150 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -35,6 +35,6 @@ struct mm_struct init_mm = {
 	.arg_lock	=  __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
 	.user_ns	= &init_user_ns,
-	.cpu_bitmap	= { [BITS_TO_LONGS(NR_CPUS)] = 0},
+	.cpu_bitmap	= CPU_BITS_NONE,
 	INIT_MM_CONTEXT(init_mm)
 };
-- 
2.7.4


