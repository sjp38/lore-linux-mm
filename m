Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 838DAC4646C
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:13:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C19120820
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:13:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="YOqjNJ1Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C19120820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFED06B0008; Mon, 24 Jun 2019 20:13:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CACDD8E0003; Mon, 24 Jun 2019 20:13:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B77A78E0002; Mon, 24 Jun 2019 20:13:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90C2A6B0008
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 20:13:04 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id t14so5300933ybt.5
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:13:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=TFx9H37w6mZg+4Tg54qFCnWnzVBpXQ/B3y/2N1lbRw0=;
        b=aU0iI5Z9B28g8Novsd3xn/CbHpY6bUN5TAO4MoTpFh+1GQUeFvRQyK6B5Fl0qDTAwu
         POnYzEl88BMibFB/C6YlhdusAPpbg1aN1lDf3c9U9+xkg+rEWR0OSVMKfzZwfS13sOao
         5FOEEgIlwY2LRgib3te2ia7cV6xMkT0BjIkW2W0KDTu+OnWM/5lRx3AOFwxqs6kLPsrS
         XxNixuVAshJW6ctAdwOI6eixeA7b4I0cWUcD37cW7UIdObLNLOLMfJlqEg4haGCk3mp4
         95wKnYgVIqwPFNRKBPhC+h8fMelXFs2y9dfRYJtH9M1R2ebxZ+t05CB1gOkWmo6yThg1
         nPzg==
X-Gm-Message-State: APjAAAWZhvCeG3daLwlT5MToVpsHXYr21nhCoCh30twEpSdSJetIughC
	hEkcVKY/eWBajqxejpSdw7DmJfCckq+phjQ4iw/o410pH2k/Kybca9s3w5YG0uOkUnrdVXXBHp4
	XPMjH6noEF6Qb3ygWyY9vwt5FzFS2XTdlSxhLGUxcRG9Cw0Q7ZtqdFKZ/CYR/f6roMQ==
X-Received: by 2002:a25:3a44:: with SMTP id h65mr80389989yba.449.1561421584345;
        Mon, 24 Jun 2019 17:13:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9B4XCfcxiej0J8kvY0i++ydzdoDMGmt6D1w0eyHX6cbzYhSGJ2yqTRhqhsmxfpu5Jw1CU
X-Received: by 2002:a25:3a44:: with SMTP id h65mr80389974yba.449.1561421583796;
        Mon, 24 Jun 2019 17:13:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561421583; cv=none;
        d=google.com; s=arc-20160816;
        b=q6e/KxGMZcGvar4lZaqW7S3eMMNKAJy6HgPG6O+T8CeQwUveGLYs3VFZV88wpikcJu
         LlXeHA1nB6EEbTGZQ+M78KuVQn2qVucit/4B6d/+BhWtvfHpb9uJCi1UnfmB+QcsGs3O
         DZP33sAkprN3BCULjZLv4iGmKBG/AeVcVvr5CMhvttLjPYNAj048l2ip1UB6eVFPUslf
         I9RdTH3bUQrjbGx2Lt2nuuRKw+LJIgpfOiGBz7+sojEksUIW8KkkPQehRRsrEIDqjHnN
         qdn0yCQpjTFv9OQvpw6PBrhdD0qeSa+RfZJfoJ8ltPvx1MRDNws8QT8vQEoavndbs+QR
         jspA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=TFx9H37w6mZg+4Tg54qFCnWnzVBpXQ/B3y/2N1lbRw0=;
        b=0pMInnnox7in2fO13kJ9kKCcbshxFdmDFkd7xXxtqDqYXJdJ0byu8OMpRBoYvB9llY
         NCb3jjDljOrBtsb7y/3EHVufmF69UP8NUlUGMpR04WZhKLOL8IwKcWJhmFMH+Nb5IazP
         ZF4ydAPosmjjlJ+vAkb7jsgmmQC3Z0iZHTzd4gqOP1EpHlEY+CtAoUgol2b2ll9IL5yz
         Mxi0fGSXk9Pw0PEM3KbAh0DZsqYxFFDPI1M5ekvczFDAgaISUDtIx4C3XCF67KI2mLhb
         y21OSgSu3TaYpPoP8Rj7zNjTtMgyxXLGzc4+hhOecA75+gbDBDP6PQbCbvJfk0A+s3I8
         WGtg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=YOqjNJ1Z;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id r6si4430973ybm.450.2019.06.24.17.13.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 17:13:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=YOqjNJ1Z;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5P09FcS031911
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:13:03 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=TFx9H37w6mZg+4Tg54qFCnWnzVBpXQ/B3y/2N1lbRw0=;
 b=YOqjNJ1ZSRhFiiRzZ6i6hCn4Q8zUNgxKC5HotrmxTrVVkvMXwz4ifQ84LDmXq0nOGIXA
 iU8/tEBk5/3yfhnUGPCqnKQsc1AQgJJpf9dHc0UoVfnoRvbOEtz/UBV4WH8VNZlhcGad
 mnvsemCNpShLGPDpOc2anHuA/kyrnoBT8oM= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2tb3gw98x1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:13:03 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Mon, 24 Jun 2019 17:13:02 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 3AA9762E206E; Mon, 24 Jun 2019 17:12:59 -0700 (PDT)
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
Subject: [PATCH v9 3/6] mm,thp: stats for file backed THP
Date: Mon, 24 Jun 2019 17:12:43 -0700
Message-ID: <20190625001246.685563-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190625001246.685563-1-songliubraving@fb.com>
References: <20190625001246.685563-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250000
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation for non-shmem THP, this patch adds a few stats and exposes
them in /proc/meminfo, /sys/bus/node/devices/<node>/meminfo, and
/proc/<pid>/task/<tid>/smaps.

This patch is mostly a rewrite of Kirill A. Shutemov's earlier version:
https://lkml.kernel.org/r/20170126115819.58875-5-kirill.shutemov@linux.intel.com/

Acked-by: Rik van Riel <riel@surriel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 drivers/base/node.c    | 6 ++++++
 fs/proc/meminfo.c      | 4 ++++
 fs/proc/task_mmu.c     | 4 +++-
 include/linux/mmzone.h | 2 ++
 mm/vmstat.c            | 2 ++
 5 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 8598fcbd2a17..71ae2dc93489 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -426,6 +426,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d AnonHugePages:  %8lu kB\n"
 		       "Node %d ShmemHugePages: %8lu kB\n"
 		       "Node %d ShmemPmdMapped: %8lu kB\n"
+		       "Node %d FileHugePages: %8lu kB\n"
+		       "Node %d FilePmdMapped: %8lu kB\n"
 #endif
 			,
 		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
@@ -451,6 +453,10 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(pgdat, NR_SHMEM_THPS) *
 				       HPAGE_PMD_NR),
 		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
+				       HPAGE_PMD_NR),
+		       nid, K(node_page_state(pgdat, NR_FILE_THPS) *
+				       HPAGE_PMD_NR),
+		       nid, K(node_page_state(pgdat, NR_FILE_PMDMAPPED) *
 				       HPAGE_PMD_NR)
 #endif
 		       );
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 568d90e17c17..bac395fc11f9 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -136,6 +136,10 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		    global_node_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR);
 	show_val_kb(m, "ShmemPmdMapped: ",
 		    global_node_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR);
+	show_val_kb(m, "FileHugePages: ",
+		    global_node_page_state(NR_FILE_THPS) * HPAGE_PMD_NR);
+	show_val_kb(m, "FilePmdMapped: ",
+		    global_node_page_state(NR_FILE_PMDMAPPED) * HPAGE_PMD_NR);
 #endif
 
 #ifdef CONFIG_CMA
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 01d4eb0e6bd1..0360e3b2ba89 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -413,6 +413,7 @@ struct mem_size_stats {
 	unsigned long lazyfree;
 	unsigned long anonymous_thp;
 	unsigned long shmem_thp;
+	unsigned long file_thp;
 	unsigned long swap;
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
@@ -563,7 +564,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 	else if (is_zone_device_page(page))
 		/* pass */;
 	else
-		VM_BUG_ON_PAGE(1, page);
+		mss->file_thp += HPAGE_PMD_SIZE;
 	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd), locked);
 }
 #else
@@ -767,6 +768,7 @@ static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss)
 	SEQ_PUT_DEC(" kB\nLazyFree:       ", mss->lazyfree);
 	SEQ_PUT_DEC(" kB\nAnonHugePages:  ", mss->anonymous_thp);
 	SEQ_PUT_DEC(" kB\nShmemPmdMapped: ", mss->shmem_thp);
+	SEQ_PUT_DEC(" kB\nFilePmdMapped: ", mss->file_thp);
 	SEQ_PUT_DEC(" kB\nShared_Hugetlb: ", mss->shared_hugetlb);
 	seq_put_decimal_ull_width(m, " kB\nPrivate_Hugetlb: ",
 				  mss->private_hugetlb >> 10, 7);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 70394cabaf4e..827f9b777938 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -234,6 +234,8 @@ enum node_stat_item {
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_SHMEM_THPS,
 	NR_SHMEM_PMDMAPPED,
+	NR_FILE_THPS,
+	NR_FILE_PMDMAPPED,
 	NR_ANON_THPS,
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_VMSCAN_WRITE,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index fd7e16ca6996..6afc892a148a 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1158,6 +1158,8 @@ const char * const vmstat_text[] = {
 	"nr_shmem",
 	"nr_shmem_hugepages",
 	"nr_shmem_pmdmapped",
+	"nr_file_hugepages",
+	"nr_file_pmdmapped",
 	"nr_anon_transparent_hugepages",
 	"nr_unstable",
 	"nr_vmscan_write",
-- 
2.17.1

