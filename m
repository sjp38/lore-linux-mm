Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73D52C282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 02:44:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22ECB20989
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 02:44:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="me9FIEgx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22ECB20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6B658E0002; Wed, 30 Jan 2019 21:44:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F0208E0001; Wed, 30 Jan 2019 21:44:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8681E8E0002; Wed, 30 Jan 2019 21:44:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4EAFF8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 21:44:44 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id q82so919022ywg.22
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 18:44:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dngGFcDbkNXh0xngR7htMF2wFliNuvjMC0Q1NHhx2Zs=;
        b=DQdDUz/rk6nvNMSw4PLtVNtTQmKffZVeJgcCGLVTIH5G+riv+bDQ2iEyx6M4MCTVOO
         Uwcz6g5DJ0rNXJv41lAIAhfqPj27QZf1pPL8gvQTfd2ZOQwfK8ojSeSl7TpFhPj1V/J5
         fOQWfRmG0eR4AMuuejDUsytdviTwRmtMU1tftTz0FySel+BUefyX0ITKwv7RQz691Sz1
         9puZFWYA7ew+TBKLhpe0I7zlbSZKC4H1MW/d2SjQ4Xf7CL2WNNjrp7lnMIjQ94hvpbA4
         z0p731TCYMLoGxXi4/LjsLyJccsKdm4XvIqqUbvB+VRsZt9GzZ4TZW8oX8dbQc6jRVV0
         UBZg==
X-Gm-Message-State: AHQUAuZGrJxSwx3X6TdraH6ozv2McJ/GT8cT6gWvSD06lqzLO0Wh88Jr
	7SuyGdYbAsUu+3N+eu/jq9CvjcJtBbFtc6oZWduEY/Vi4vQ+uR4OQZpUfRq6uabrnhwq+wsiR0K
	Cq1uHNdJhkcO/PPMFo8D33vBLJfoKYdyVd9RGTIBqiBRrXVbzHEad0EfS8j3VmlqTqA==
X-Received: by 2002:a25:b843:: with SMTP id b3mr11868617ybm.428.1548902684003;
        Wed, 30 Jan 2019 18:44:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ59CG15gOrk9aMWYxmEbrWTFt2SlxvjIUt3qap+KsAUCo5WhKQiGT3PHdAFfdvEe/PvG6p
X-Received: by 2002:a25:b843:: with SMTP id b3mr11868590ybm.428.1548902683208;
        Wed, 30 Jan 2019 18:44:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548902683; cv=none;
        d=google.com; s=arc-20160816;
        b=Hrs0fP3KqITZKXiz3XPCo9P1phSGum5aPVgQT9XcSNUuPcMnICNGC6p36mu+wBktx+
         Xg9nmdH1F8zs5KLlfph56/pz2CpQIgXZhKma0N5nudVOaRiZ6lIqSJD2zvZKHQsCUkfb
         TxQ0MtwwJh57sobnHW8F5rKWbPTbpyXzWqdHQ3MvPKYoouXn63u+P/BhDzJ2RLycGvIi
         q7igMNdE70WWHPm7RkR/wXnLRk0D3khh2ioA0AVvmZfBzpNK3uzeAWktSOzZ9+mx76Sa
         VmpRgqYObRR1sxU0ciig/6y5xikQbKbhv1DDQD69DdtRtkk0CG1xip+FOwGdJtrsQkWo
         m3gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=dngGFcDbkNXh0xngR7htMF2wFliNuvjMC0Q1NHhx2Zs=;
        b=Lz90gxuT99SofQfLhbejtS0Ega/8t3KZaCbqt+jW1/nzESD5vika4QZ53RLf3PiweM
         Nd1tw3qjaUJuXUp6ez4KlUO/BrjQv9lZHo7ffKi/JBEvDAkVXblyFrpGrWUb44bHLvcy
         Qg7USZQDWokrCqmVQqT4I5Dssl+7tyG7QwJ7kDyx51+UvahCxmwzIlk6M2g6CjbigdUU
         0RnnRyx3lhRgI+OjtAlInbt62qmyfi6G1RTx9PHxqvYsEGzr+TjTVqJsrCcM1VOwe+ZQ
         9ZLZi1Xd0eRSfPgkXB8xJtoEqSCHf59optM+EW89UTbWOluDZi2pFxP9CbXDDPKnW50M
         JgzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=me9FIEgx;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id b96si1931061ybi.261.2019.01.30.18.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 18:44:43 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=me9FIEgx;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0V2iPY9026349;
	Thu, 31 Jan 2019 02:44:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=dngGFcDbkNXh0xngR7htMF2wFliNuvjMC0Q1NHhx2Zs=;
 b=me9FIEgxKhhq/o5mar3CJsVfQ+/EIHFm5Ti0E+URIt/4WUnYVZJyeW9KvpEnVW3a1SXs
 q+B2tcu8Hocsx6sGB+Zcl3viVRVDshXMoI6upARCPglvI/C1ntAhBIkm9U6IvnjwVGqO
 qafX7avcHDKZ+KyJOazNsM2PHnE6w5dFx4JgQxH8rbyhT5Op7FFwVOzPyKFA1lpFBMx9
 xPxQX89CRMoWfi8b6dx+gQ8iCIl0Z01mc6TSjePXQvUpydqfuVJZW3eYh3xYHz1MmY57
 8CtDKR0a/7eXttwNQWgNYqlbq642YJNr5LhjUeVSjdKq2OrGbVdJse7dUxbQZ/IeJX91 Vw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2q8d2ee8wj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 02:44:25 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0V2iJfB021928
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 02:44:19 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0V2iGc6014688;
	Thu, 31 Jan 2019 02:44:16 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 30 Jan 2019 18:44:16 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: akpm@linux-foundation.org
Cc: dan.carpenter@oracle.com, andrea.parri@amarulasolutions.com,
        shli@kernel.org, ying.huang@intel.com, dave.hansen@linux.intel.com,
        sfr@canb.auug.org.au, osandov@fb.com, tj@kernel.org,
        ak@linux.intel.com, linux-mm@kvack.org,
        kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com,
        stern@rowland.harvard.edu, peterz@infradead.org, will.deacon@arm.com,
        daniel.m.jordan@oracle.com
Subject: [PATCH v2] mm, swap: bounds check swap_info array accesses to avoid NULL derefs
Date: Wed, 30 Jan 2019 21:44:10 -0500
Message-Id: <20190131024410.29859-1-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190131015231.e6lggsi2ug77qr6c@ca-dmjordan1.us.oracle.com>
References: <20190131015231.e6lggsi2ug77qr6c@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9152 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901310020
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Carpenter reports a potential NULL dereference in
get_swap_page_of_type:

  Smatch complains that the NULL checks on "si" aren't consistent.  This
  seems like a real bug because we have not ensured that the type is
  valid and so "si" can be NULL.

Add the missing check for NULL, taking care to use a read barrier to
ensure CPU1 observes CPU0's updates in the correct order:

     CPU0                           CPU1
     alloc_swap_info()              if (type >= nr_swapfiles)
       swap_info[type] = p              /* handle invalid entry */
       smp_wmb()                    smp_rmb()
       ++nr_swapfiles               p = swap_info[type]

Without smp_rmb, CPU1 might observe CPU0's write to nr_swapfiles before
CPU0's write to swap_info[type] and read NULL from swap_info[type].

Ying Huang noticed other places in swapfile.c don't order these reads
properly.  Introduce swap_type_to_swap_info to encourage correct usage.

Use READ_ONCE and WRITE_ONCE to follow the Linux Kernel Memory Model
(see tools/memory-model/Documentation/explanation.txt).

This ordering need not be enforced in places where swap_lock is held
(e.g. si_swapinfo) because swap_lock serializes updates to nr_swapfiles
and the swap_info array.

Fixes: ec8acf20afb8 ("swap: add per-partition lock for swapfile")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Suggested-by: "Huang, Ying" <ying.huang@intel.com>
Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Andrea Parri <andrea.parri@amarulasolutions.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Omar Sandoval <osandov@fb.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Tejun Heo <tj@kernel.org>
Cc: Will Deacon <will.deacon@arm.com>
---

v1 -> v2
 - Rebased to latest mainline per Andrew
 - Added tags from Andrea and Peter (thanks)
 - Fixed loop conditions as Peter suggested and converted a few more
   places to use swap_type_to_swap_info; retained tags since changes
   were minor
 - Added a Suggested-by for Ying
 - Amended changelog after Dan's comment

 mm/swapfile.c | 51 +++++++++++++++++++++++++++++----------------------
 1 file changed, 29 insertions(+), 22 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index dbac1d49469d..67f60e051814 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -98,6 +98,15 @@ static atomic_t proc_poll_event = ATOMIC_INIT(0);
 
 atomic_t nr_rotate_swap = ATOMIC_INIT(0);
 
+static struct swap_info_struct *swap_type_to_swap_info(int type)
+{
+	if (type >= READ_ONCE(nr_swapfiles))
+		return NULL;
+
+	smp_rmb();	/* Pairs with smp_wmb in alloc_swap_info. */
+	return READ_ONCE(swap_info[type]);
+}
+
 static inline unsigned char swap_count(unsigned char ent)
 {
 	return ent & ~SWAP_HAS_CACHE;	/* may include COUNT_CONTINUED flag */
@@ -1044,12 +1053,14 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[], int entry_size)
 /* The only caller of this function is now suspend routine */
 swp_entry_t get_swap_page_of_type(int type)
 {
-	struct swap_info_struct *si;
+	struct swap_info_struct *si = swap_type_to_swap_info(type);
 	pgoff_t offset;
 
-	si = swap_info[type];
+	if (!si)
+		goto fail;
+
 	spin_lock(&si->lock);
-	if (si && (si->flags & SWP_WRITEOK)) {
+	if (si->flags & SWP_WRITEOK) {
 		atomic_long_dec(&nr_swap_pages);
 		/* This is called for allocating swap entry, not cache */
 		offset = scan_swap_map(si, 1);
@@ -1060,6 +1071,7 @@ swp_entry_t get_swap_page_of_type(int type)
 		atomic_long_inc(&nr_swap_pages);
 	}
 	spin_unlock(&si->lock);
+fail:
 	return (swp_entry_t) {0};
 }
 
@@ -1071,9 +1083,9 @@ static struct swap_info_struct *__swap_info_get(swp_entry_t entry)
 	if (!entry.val)
 		goto out;
 	type = swp_type(entry);
-	if (type >= nr_swapfiles)
+	p = swap_type_to_swap_info(type);
+	if (!p)
 		goto bad_nofile;
-	p = swap_info[type];
 	if (!(p->flags & SWP_USED))
 		goto bad_device;
 	offset = swp_offset(entry);
@@ -1697,10 +1709,9 @@ int swap_type_of(dev_t device, sector_t offset, struct block_device **bdev_p)
 sector_t swapdev_block(int type, pgoff_t offset)
 {
 	struct block_device *bdev;
+	struct swap_info_struct *si = swap_type_to_swap_info(type);
 
-	if ((unsigned int)type >= nr_swapfiles)
-		return 0;
-	if (!(swap_info[type]->flags & SWP_WRITEOK))
+	if (!si || !(si->flags & SWP_WRITEOK))
 		return 0;
 	return map_swap_entry(swp_entry(type, offset), &bdev);
 }
@@ -2258,7 +2269,7 @@ static sector_t map_swap_entry(swp_entry_t entry, struct block_device **bdev)
 	struct swap_extent *se;
 	pgoff_t offset;
 
-	sis = swap_info[swp_type(entry)];
+	sis = swp_swap_info(entry);
 	*bdev = sis->bdev;
 
 	offset = swp_offset(entry);
@@ -2700,9 +2711,7 @@ static void *swap_start(struct seq_file *swap, loff_t *pos)
 	if (!l)
 		return SEQ_START_TOKEN;
 
-	for (type = 0; type < nr_swapfiles; type++) {
-		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
-		si = swap_info[type];
+	for (type = 0; (si = swap_type_to_swap_info(type)); type++) {
 		if (!(si->flags & SWP_USED) || !si->swap_map)
 			continue;
 		if (!--l)
@@ -2722,9 +2731,7 @@ static void *swap_next(struct seq_file *swap, void *v, loff_t *pos)
 	else
 		type = si->type + 1;
 
-	for (; type < nr_swapfiles; type++) {
-		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
-		si = swap_info[type];
+	for (; (si = swap_type_to_swap_info(type)); type++) {
 		if (!(si->flags & SWP_USED) || !si->swap_map)
 			continue;
 		++*pos;
@@ -2831,14 +2838,14 @@ static struct swap_info_struct *alloc_swap_info(void)
 	}
 	if (type >= nr_swapfiles) {
 		p->type = type;
-		swap_info[type] = p;
+		WRITE_ONCE(swap_info[type], p);
 		/*
 		 * Write swap_info[type] before nr_swapfiles, in case a
 		 * racing procfs swap_start() or swap_next() is reading them.
 		 * (We never shrink nr_swapfiles, we never free this entry.)
 		 */
 		smp_wmb();
-		nr_swapfiles++;
+		WRITE_ONCE(nr_swapfiles, nr_swapfiles + 1);
 	} else {
 		kvfree(p);
 		p = swap_info[type];
@@ -3358,7 +3365,7 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 {
 	struct swap_info_struct *p;
 	struct swap_cluster_info *ci;
-	unsigned long offset, type;
+	unsigned long offset;
 	unsigned char count;
 	unsigned char has_cache;
 	int err = -EINVAL;
@@ -3366,10 +3373,10 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 	if (non_swap_entry(entry))
 		goto out;
 
-	type = swp_type(entry);
-	if (type >= nr_swapfiles)
+	p = swp_swap_info(entry);
+	if (!p)
 		goto bad_file;
-	p = swap_info[type];
+
 	offset = swp_offset(entry);
 	if (unlikely(offset >= p->max))
 		goto out;
@@ -3466,7 +3473,7 @@ int swapcache_prepare(swp_entry_t entry)
 
 struct swap_info_struct *swp_swap_info(swp_entry_t entry)
 {
-	return swap_info[swp_type(entry)];
+	return swap_type_to_swap_info(swp_type(entry));
 }
 
 struct swap_info_struct *page_swap_info(struct page *page)
-- 
2.20.1

