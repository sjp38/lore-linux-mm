Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B273EC04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:52:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DF172173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:52:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="KOZPzmF6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DF172173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D426D6B0003; Mon, 20 May 2019 21:52:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1AFD6B0005; Mon, 20 May 2019 21:52:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C31846B0006; Mon, 20 May 2019 21:52:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id A46DD6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:52:15 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id t7so12944867iod.17
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:52:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=vbv7AIPUINZEAyfqPwOa0i2aEh0aRUzbEl5llwPsSWA=;
        b=mipwhaT2beyPrT0OZG8KqB8dAKXfwHs4cRec3PeQo3Oy+5v6mA6Bwc07xL02PbxY9J
         tpu6dthhosVR7XBc4wj/piVvdrS69v6P3WjjCz0wCksRzwxPE6/bqiTyPgUTDx3PApKZ
         pQxgYqPa0pkWWRaZ4PJqebYen3i3OTUt5FHtp0mCc4r/CijNEsRjiEb+1Xt5Vmowaj6C
         i5NSSRwBRb5868gywKVvLJLD1y8BlajBILidE+/ZZ5pXqhtcR3rxp43LJhd0lbAX4fjn
         fsf86Pc2a3kuynryTnwPslaWEBj/pvqvCs7JJ68CEODGGkei5VUBr8CelWEsXK3si3Ev
         k4qw==
X-Gm-Message-State: APjAAAXAS/fVwbrlDw4f7zkb8gOoQOMaXFLh2R0H9eYI0Uw1jvBrVnvm
	opWU28nv79Cy5tfQwOycxnrR690Fjrga1FYhukZwj3Sc5i4a2fN2y1cEkz+obNDu86k1h1WMa9p
	dQdVIc6b4Ha52jXJpdJm4kO6dAX1Qyv9shEWiqutef6LkLQMX+42tEAwApKtKcgh+hw==
X-Received: by 2002:a6b:f404:: with SMTP id i4mr9926614iog.251.1558403535434;
        Mon, 20 May 2019 18:52:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4hP66xhznFSCqWF7MRNeRIgg2x5QJGi2dv1MkXTt0gVYBI6r9IUdYz4j7uek1hrdzD0LR
X-Received: by 2002:a6b:f404:: with SMTP id i4mr9926597iog.251.1558403534852;
        Mon, 20 May 2019 18:52:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558403534; cv=none;
        d=google.com; s=arc-20160816;
        b=nqTyUsbUAGB50U0WhMFVRc4fqcwlzW0HdMiHs8FP+vS3fn5/L4A9oDFYBAQSoXzxlO
         yQWnROsnYBfsFdICqRPWOHHOpJOkTaMBUH2ri31AtOdcYx7lmj35+qP006SLAnbr622C
         UiTmF5pHfIfmFUcF4g19uVzKcruFlDmrXTWtt/Oj4XJexP3bu60wrunjNXDKAbIKTj0Z
         5hxZNoRvVsGgcrIJe+iY7hoUnjBu08Ozg/2PEx2l//ihp1Et0WTIoMLPlEClMVnYVS8F
         g7HCzOI06VZmXZ44vdqn4XrOzQCHWIntMrtqUHPnrvPrsjJx7yIfBqob0AYLsqtW+GBp
         HnSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=vbv7AIPUINZEAyfqPwOa0i2aEh0aRUzbEl5llwPsSWA=;
        b=IIWCdONbJkNfxtWBFtv1zxmahLh3CuPqbs0+SKjw/SC2nqEcIjXDHZW29aekEOmz+K
         Dy39cwY/ExF8rOYwWyDTPXYZ/mWrNAEAGT7RF0LKkctcGsNuLIDLzDY5Rw57kmt6w3WR
         0rou2LLvtz2f++nOeW3HspKLpiBRepppzKAYhBygbpfLf82FAKejaOq4XyfuJIsLDS9F
         N6KJIj1Aw3VW3RRMq/LDqCjivu9jAcVUlWz48OV0/A5M6AihWjXoIcBNIB1X8Os0tXYw
         Io5pOB7s5MQZfUtToHk4qKM/2rApzrEJqkyMqfduA65fNyijqf0ePnegmqaOttZOUoxy
         kFJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=KOZPzmF6;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id s2si11408298jaa.86.2019.05.20.18.52.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 18:52:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=KOZPzmF6;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4L1nHnb053289;
	Tue, 21 May 2019 01:52:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=vbv7AIPUINZEAyfqPwOa0i2aEh0aRUzbEl5llwPsSWA=;
 b=KOZPzmF6oP2xMnGZ5P04ZDnFUPAofZ9LWiQlleQd7dXizi+HxL3f6v4Anx8g/hV+N6zv
 glDLwsAgH/oZ/Z9qS4ZPz4bw86/wkXxQUdgx9fnAL8fY5XpFtz2v+9K0D75O/iJeLNaC
 v91S7amZSGx8yA2lIRCMIx/zSdvX22MLutGflsmgqcg5D7OXSDvENs30e8PqO2lDUiOO
 CNG2fO7VNdDGEDAyuv86Q1bVS0/Tbxr/fpUzPSmp4Qm65W0068S5Ol4z2Iy6y9kdbF+C
 b3rjVYBs25ef6RsdJczksnMQKNTPRAFPptPhMQXZLPae2d5BUAfpJ+3aXVihGMpm9X9h AQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2sjapqa6y5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 21 May 2019 01:52:11 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4L1q3HU063245;
	Tue, 21 May 2019 01:52:11 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2sm046pruw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 21 May 2019 01:52:10 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4L1q99j027790;
	Tue, 21 May 2019 01:52:09 GMT
Received: from brm-x32-03.us.oracle.com (/10.80.150.35)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 21 May 2019 01:52:09 +0000
From: Jane Chu <jane.chu@oracle.com>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
Subject: [PATCH v2] mm, memory-failure: clarify error message
Date: Mon, 20 May 2019 19:52:03 -0600
Message-Id: <1558403523-22079-1-git-send-email-jane.chu@oracle.com>
X-Mailer: git-send-email 1.8.3.1
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9263 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=919
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905210009
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9263 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=960 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905210009
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Some user who install SIGBUS handler that does longjmp out
therefore keeping the process alive is confused by the error
message
  "[188988.765862] Memory failure: 0x1840200: Killing
   cellsrv:33395 due to hardware memory corruption"
Slightly modify the error message to improve clarity.

Signed-off-by: Jane Chu <jane.chu@oracle.com>
---
 mm/memory-failure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index fc8b517..c4f4bcd 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -216,7 +216,7 @@ static int kill_proc(struct to_kill *tk, unsigned long pfn, int flags)
 	short addr_lsb = tk->size_shift;
 	int ret;
 
-	pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory corruption\n",
+	pr_err("Memory failure: %#lx: Sending SIGBUS to %s:%d due to hardware memory corruption\n",
 		pfn, t->comm, t->pid);
 
 	if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
-- 
1.8.3.1

