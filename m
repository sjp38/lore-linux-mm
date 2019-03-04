Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73FC6C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 17:04:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FC192082F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 17:04:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CWqRYwOg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FC192082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C87768E0003; Mon,  4 Mar 2019 12:04:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C36728E0001; Mon,  4 Mar 2019 12:04:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4C718E0003; Mon,  4 Mar 2019 12:04:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D33C8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 12:04:51 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id s8so5561497qth.18
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 09:04:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=y9YtX+guuq4jzTb5p6KJENEt5MDOMi6rFV456jle65Q=;
        b=IF9NI1W7MbaWr1fPFzv5Xrxk3kSLiseFCYxwKuRijktLQAi947YPlurgWHlMtbqOS/
         aAEoJqIl7BfYBM8Fnpbj1aPKCblww9BkNH1OiIzQCgMHZFb1fYc3/O/Z1qjqhw7vji/C
         z6X9Vy90irzr6EXrHpnMmcRj9jKUN03ZEp16LXixwnJLGRJGC7O6OHWxpRHkzTEwbSks
         GqG965gTzwPdIMwTOGUqBFnRAoLXDX566ff63XWftAI+zwriXiNAH3Y9oHK3QM3UqS9k
         tA/U3CwfH+U6MbM7GSoAjnjNDa1Z1lGRoksWI3/ioiUoBxqSZBNPlb0HjhGm+7PjrXQy
         RvNg==
X-Gm-Message-State: APjAAAWvNXXvXu1QWQBADC15IhZJpBO3rVfAd46RJP6Xz+uXHHKlLvmx
	ZNtiGSF+sTq23H5jUbytplklsolbnQE/BcKj6TB0zGuPu8/CjwyngggP17Jk7w7pDLYEMqqFr4b
	su3KKX+5dZ4N9cJDSTNm12i/e63puFAmfudVbxkqSAnvEdc/A+ZXUn/382hDNSlqLGYJofDCOIq
	8BpLIWS1S2q9T6L3JWO+ifUB1IoYQG7a22M3e4F9trlnHWNdbonHrKsrkhrwXyNBKrFsDkChrxH
	De+AvCmXBXMrwO0WWf/xoArnGVLOhVRKeGhkVtcwAaoRZZ8WT+thTXZ6LtkrgyxFpEPJ93CkLl/
	jYuwnp7IXtIECLjPKdhxZzkIeh1SzsKlTA7hqmLUEs/EABRrbuYoQgHqVNRKe6oGPCL761sTOOt
	8
X-Received: by 2002:aed:3608:: with SMTP id e8mr4425442qtb.31.1551719091194;
        Mon, 04 Mar 2019 09:04:51 -0800 (PST)
X-Received: by 2002:aed:3608:: with SMTP id e8mr4425366qtb.31.1551719090125;
        Mon, 04 Mar 2019 09:04:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551719090; cv=none;
        d=google.com; s=arc-20160816;
        b=ftB1BFRTqKJtSmnq1e2jk2LbptTdIWQWU9TDbHPcK6sEk0i2XUcFeBws2LjXhg7DQH
         tPpJ2VbPCM5xILT520LxwhwlWTO0IPWRosJwwnbHHz+uMpm40/fosoZOaMxYcqUuJtwH
         EeG65bq0pXyZZgwvdkF783btXsokM/l8a6XqAaZ2R4AJYqViSIijHvNQo3pLDRAidG3I
         4RB0TBvS+Mb/cinPU1PCOGHPd3YHc6f+eOc5iUv4HcKdZyFbpJvDo7oy3x2Eg/UUqfBy
         3PMfY2I0LeS9eGvgpOvFCASOOoibx2InDxNWGpyVApdA5AbpSpIVixUuJx8HMdituxEf
         bCow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=y9YtX+guuq4jzTb5p6KJENEt5MDOMi6rFV456jle65Q=;
        b=xgjU/uPZ7mtW1z7nXHL+wZgQRXYufSSpwSEmcL8248Y31H62SpZBVhpfa9XgzsNfNx
         2v1Jj06LPWtY0yrPqIjisrmvpWwYekWpvN+ZYjWc3aqrhfzBjUnVUFzj93bskxpm0Tet
         XYZrRUaranQqRo1sZDXIBv94mJfgwn2Mkgn88RCePWzytKPr7mtjiWraX8qZjVWvneYW
         ZLQRKqOYKhdUvlf6QJROZNV0HaomQxdludW0iig2rrz4Vo2dQjGBSHurHLkpXN83UoYz
         RRFxgw/unzg2UUGIe1mYbNfi45MHDiC5nHAqP87mLuWazRkrpqf4pWtbJUN5e3Rekss4
         OWfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CWqRYwOg;
       spf=pass (google.com: domain of 3svp9xaokceyivlzm6sv3towwotm.kwutqv25-uus3iks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3sVp9XAoKCEYivlzm6sv3towwotm.kwutqv25-uus3iks.wzo@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id e31sor7558394qte.64.2019.03.04.09.04.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 09:04:50 -0800 (PST)
Received-SPF: pass (google.com: domain of 3svp9xaokceyivlzm6sv3towwotm.kwutqv25-uus3iks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CWqRYwOg;
       spf=pass (google.com: domain of 3svp9xaokceyivlzm6sv3towwotm.kwutqv25-uus3iks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3sVp9XAoKCEYivlzm6sv3towwotm.kwutqv25-uus3iks.wzo@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=y9YtX+guuq4jzTb5p6KJENEt5MDOMi6rFV456jle65Q=;
        b=CWqRYwOgcRdTy/1Zuf8A3CD/jL6JjEg15KYHyTccY8wV9VTBQZFKPDp7YcXEOJ24fR
         MSdmCSL73tkBebZK9OULfdflqqbl8LZsrwI17gQTN8ko6agIOf/R4gBl/HiR07eTdbER
         BaKm8iyStIOkCK7UjmOug4DEMbA+SZXW64b0UHxsMx7QR7LuZx6DYzI9kA52c99QZkuj
         +fdLeqGmGuzjo/8YIKNUuAqkd28EmzlINQz118sDfQJsa7kNKx5FPov5yz1VsMLkpI7Z
         Vx0NFv+uUFcHtx4VehXMJz8fL9q/Fq/o4b2kTqjb+cVZWg1o5vBMXZzzr3wZ8Fk+hgCY
         Ri7g==
X-Google-Smtp-Source: APXvYqxtwN3Nu40niShYMTIoBxqcCBnOl1jnM4/HsXPlf1g0bpaPMXqeZBH1+ePQ3SuwTRGJ7sGylO2mohh48XlI
X-Received: by 2002:ac8:2539:: with SMTP id 54mr11239168qtm.45.1551719089934;
 Mon, 04 Mar 2019 09:04:49 -0800 (PST)
Date: Mon,  4 Mar 2019 18:04:45 +0100
Message-Id: <1fa6fadf644859e8a6a8ecce258444b49be8c7ee.1551716733.git.andreyknvl@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.352.gf09ad66450-goog
Subject: [PATCH] kasan: fix coccinelle warnings in kasan_p*_table
From: Andrey Konovalov <andreyknvl@google.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Andrey Konovalov <andreyknvl@google.com>, 
	kbuild test robot <lkp@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kasan_p4d_table, kasan_pmd_table and kasan_pud_table are declared as
returning bool, but return 0 instead of false, which produces a coccinelle
warning. Fix it.

Fixes: 0207df4fa1a8 ("kernel/memremap, kasan: make ZONE_DEVICE with work with KASAN")
Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/init.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/kasan/init.c b/mm/kasan/init.c
index 45a1b5e38e1e..fcaa1ca03175 100644
--- a/mm/kasan/init.c
+++ b/mm/kasan/init.c
@@ -42,7 +42,7 @@ static inline bool kasan_p4d_table(pgd_t pgd)
 #else
 static inline bool kasan_p4d_table(pgd_t pgd)
 {
-	return 0;
+	return false;
 }
 #endif
 #if CONFIG_PGTABLE_LEVELS > 3
@@ -54,7 +54,7 @@ static inline bool kasan_pud_table(p4d_t p4d)
 #else
 static inline bool kasan_pud_table(p4d_t p4d)
 {
-	return 0;
+	return false;
 }
 #endif
 #if CONFIG_PGTABLE_LEVELS > 2
@@ -66,7 +66,7 @@ static inline bool kasan_pmd_table(pud_t pud)
 #else
 static inline bool kasan_pmd_table(pud_t pud)
 {
-	return 0;
+	return false;
 }
 #endif
 pte_t kasan_early_shadow_pte[PTRS_PER_PTE] __page_aligned_bss;
-- 
2.21.0.352.gf09ad66450-goog

