Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2CD8C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86DA320656
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:17:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86DA320656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E1E96B000C; Thu, 20 Jun 2019 05:17:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26AA28E0002; Thu, 20 Jun 2019 05:17:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10D578E0001; Thu, 20 Jun 2019 05:17:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB70B6B000C
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:17:35 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a13so1380381pgw.19
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 02:17:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=E3eS2eemKiR8duN0iVNt7Ev75B+RwT8FCoH3qIkQA+E=;
        b=pbktIRf3G+DV55JPCiOM86MQaYeqlPHsVdHMfykKij/QX+asjnckJCLUl7RdiuGZUQ
         v/54Uati6PcVhYHdJM0DXM5IkQT7XHIAty3yCB1tqkhlTuLCx4mk4Pk26qFa/apk7+By
         I7myj2hqq6muQFbEiw6GhqUyCZE+6S6e00Ctr3DvWI+vznjqmI/7jrxwTWsWFIV5lvOo
         D7tK6Nl7N/M2wfTpTATKJnbs3NfKUBzjpQc/4OsXBtAMruw+4ue8+3iVKXK1Rygq0d1Q
         v2i1Zpwv4mcXSVOpOSlncT1OVtXejABHhhJ9HWgKj5/KEZf1GVfYUmajyup2WmWN2HG3
         UK2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUak/WhsIMf8INvhNDzyUL5ijQOVcjM4C01u9NRlxSuuMqzRITV
	nymA0LxDvovRcjLWWBlUyRH/FUQvo5pfXPCVIMLA6BFDoBRKPm6ff0S5A0BhuHmXjjJQLGF24pg
	gdjdBH6jn0p+KD3saD5+rif3X/nMmESudaP5vw1T6BnVPP1tkidjkEaYod+JKhPJWWw==
X-Received: by 2002:a17:902:7d8d:: with SMTP id a13mr10628620plm.98.1561022255504;
        Thu, 20 Jun 2019 02:17:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjUdbjhJCNiGxvscnHEFk2ArYfBJN22YU5hLMpXmfOiseUxqPRAwgYo7SD7E4nvsuo7yRu
X-Received: by 2002:a17:902:7d8d:: with SMTP id a13mr10628545plm.98.1561022254231;
        Thu, 20 Jun 2019 02:17:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561022254; cv=none;
        d=google.com; s=arc-20160816;
        b=OAcqvlcpVihbhaTBQ39H/Nz6EdYNP5xPhT1tkb8Ab38oJS2k9W5JZk/jYrPVvzywEr
         wXlUB16RpD1OkpXN6F7bbGn2nTF09PAkhcAqHiJ0OA7hoRngEmee69WzJ+H9QAx2giLt
         32N9OaCyu0U7tSTXJeyqqy3qkrNpEcceBlD/HQhQd71xupb5BV+qDZLmZ3F40V8x960Q
         niDrSal4KarUI+4uwTv1lZJUyMobum0Ka89YkVLGKu8XL4OSDNFPPxbdmLSImU/Gc8XY
         cSnAu886wyhJHElgrZXkHTWD5QR6VpWr4K2QbkXB1B4k7npSXdXjX4ploia1emMaqJBJ
         5mSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=E3eS2eemKiR8duN0iVNt7Ev75B+RwT8FCoH3qIkQA+E=;
        b=cBcZBD2I9Kjl00LaKc1rWH+nfekwa3PmC2nY+mLl/iOpbeZ3JIQ7/5K3ohlx3T6SN4
         rOsD21u7ktmzoJWhIoS7EdxrgCpP0LVdMIDkErVZ7kZIz53nq9bDy+MwPwgroWgzi2Gb
         oBRoaPIMVEiaXT4dRjaWqth9WabmIzTMNd24/O3aP9yzQ+FIGu/+GMTv5jltWw6+skLy
         XK+G6C/2d9wIktfO45yvuGc64gqEdeuYzWcE2ErvlxF8SO5YDRF5LGjzpUEmC+o+KUBy
         xYFo8+CEew3Tctu4w+xHxbwjuDjX2XUWYNy87QlxBstTohybyq00RXfV77Ea/eDSdSy/
         47tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n8si19296951pfa.223.2019.06.20.02.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 02:17:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5K9DwXT019986;
	Thu, 20 Jun 2019 05:17:23 -0400
Received: from ppma01wdc.us.ibm.com (fd.55.37a9.ip4.static.sl-reverse.com [169.55.85.253])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t87b3g49y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 05:17:23 -0400
Received: from pps.filterd (ppma01wdc.us.ibm.com [127.0.0.1])
	by ppma01wdc.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x5K94kg7032616;
	Thu, 20 Jun 2019 09:17:22 GMT
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by ppma01wdc.us.ibm.com with ESMTP id 2t4ra70nu6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 09:17:22 +0000
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5K9HLb334865502
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 09:17:21 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 979C9AE063;
	Thu, 20 Jun 2019 09:17:21 +0000 (GMT)
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D7F42AE05C;
	Thu, 20 Jun 2019 09:17:19 +0000 (GMT)
Received: from skywalker.in.ibm.com (unknown [9.124.35.143])
	by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 20 Jun 2019 09:17:19 +0000 (GMT)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
        Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v4 6/6] =?UTF-8?q?mm/nvdimm:=20Fix=20endian=20conversion?= =?UTF-8?q?=20issues=C2=A0?=
Date: Thu, 20 Jun 2019 14:46:26 +0530
Message-Id: <20190620091626.31824-7-aneesh.kumar@linux.ibm.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190620091626.31824-1-aneesh.kumar@linux.ibm.com>
References: <20190620091626.31824-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200068
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

nd_label->dpa issue was observed when trying to enable the namespace created
with little-endian kernel on a big-endian kernel. That made me run
`sparse` on the rest of the code and other changes are the result of that.

Fixes: d9b83c756953 ("libnvdimm, btt: rework error clearing")
Fixes: 9dedc73a4658 ("libnvdimm/btt: Fix LBA masking during 'free list' population")

Reviewed-by: Vishal Verma <vishal.l.verma@intel.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 drivers/nvdimm/btt.c            | 8 ++++----
 drivers/nvdimm/namespace_devs.c | 7 ++++---
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
index a8d56887ec88..3e9f45aec8d1 100644
--- a/drivers/nvdimm/btt.c
+++ b/drivers/nvdimm/btt.c
@@ -392,9 +392,9 @@ static int btt_flog_write(struct arena_info *arena, u32 lane, u32 sub,
 	arena->freelist[lane].sub = 1 - arena->freelist[lane].sub;
 	if (++(arena->freelist[lane].seq) == 4)
 		arena->freelist[lane].seq = 1;
-	if (ent_e_flag(ent->old_map))
+	if (ent_e_flag(le32_to_cpu(ent->old_map)))
 		arena->freelist[lane].has_err = 1;
-	arena->freelist[lane].block = le32_to_cpu(ent_lba(ent->old_map));
+	arena->freelist[lane].block = ent_lba(le32_to_cpu(ent->old_map));
 
 	return ret;
 }
@@ -560,8 +560,8 @@ static int btt_freelist_init(struct arena_info *arena)
 		 * FIXME: if error clearing fails during init, we want to make
 		 * the BTT read-only
 		 */
-		if (ent_e_flag(log_new.old_map) &&
-				!ent_normal(log_new.old_map)) {
+		if (ent_e_flag(le32_to_cpu(log_new.old_map)) &&
+		    !ent_normal(le32_to_cpu(log_new.old_map))) {
 			arena->freelist[i].has_err = 1;
 			ret = arena_clear_freelist_error(arena, i);
 			if (ret)
diff --git a/drivers/nvdimm/namespace_devs.c b/drivers/nvdimm/namespace_devs.c
index 007027202542..839da9e43572 100644
--- a/drivers/nvdimm/namespace_devs.c
+++ b/drivers/nvdimm/namespace_devs.c
@@ -1987,7 +1987,7 @@ static struct device *create_namespace_pmem(struct nd_region *nd_region,
 		nd_mapping = &nd_region->mapping[i];
 		label_ent = list_first_entry_or_null(&nd_mapping->labels,
 				typeof(*label_ent), list);
-		label0 = label_ent ? label_ent->label : 0;
+		label0 = label_ent ? label_ent->label : NULL;
 
 		if (!label0) {
 			WARN_ON(1);
@@ -2322,8 +2322,9 @@ static struct device **scan_labels(struct nd_region *nd_region)
 			continue;
 
 		/* skip labels that describe extents outside of the region */
-		if (nd_label->dpa < nd_mapping->start || nd_label->dpa > map_end)
-			continue;
+		if (__le64_to_cpu(nd_label->dpa) < nd_mapping->start ||
+		    __le64_to_cpu(nd_label->dpa) > map_end)
+				continue;
 
 		i = add_namespace_resource(nd_region, nd_label, devs, count);
 		if (i < 0)
-- 
2.21.0

