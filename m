Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E761C3A5AA
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 09:49:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7D6421874
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 09:49:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bda+Pq49"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7D6421874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B1896B0006; Mon,  2 Sep 2019 05:49:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 562866B0007; Mon,  2 Sep 2019 05:49:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4503F6B0008; Mon,  2 Sep 2019 05:49:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0008.hostedemail.com [216.40.44.8])
	by kanga.kvack.org (Postfix) with ESMTP id 258116B0006
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 05:49:29 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C97316131
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:49:28 +0000 (UTC)
X-FDA: 75889508016.04.gate59_6fcf8ecbf3416
X-HE-Tag: gate59_6fcf8ecbf3416
X-Filterd-Recvd-Size: 4211
Received: from mail-lf1-f65.google.com (mail-lf1-f65.google.com [209.85.167.65])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:49:28 +0000 (UTC)
Received: by mail-lf1-f65.google.com with SMTP id w67so9961610lff.4
        for <linux-mm@kvack.org>; Mon, 02 Sep 2019 02:49:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=k2z623VUchf7dmtqaMObbgBBjHMdeVEZr8ifyE6cuHk=;
        b=bda+Pq49ZaMyZ6CEUMoT3fIyEh6zav/dR6ldS9zbSe/FrYsD0HCe5Zln86t8joUO8w
         QutUneK+4J9JCMISfTsq1SsCGREtR83s6He7IH7XibySlaRZ2Pi9RGLB8BFdEii7d00+
         LUDueinKYAYAfYzqP5pma+V4b8QEq8ojkJ4QbU6u0LlKWpXgjuhUQqrRoWiOWeJ8te8Q
         3OOOG3OqANxeMhRy6zfdGTeuVFreb9yu5JzIvFAje+6KiG/8qPbw/+ftFgBi7QzL2fhM
         hWtO7lvp9KnnkedASb2/miDK9u43jOqF//6+GpL2ygQ0o/l8OYK+2q10ak2jl+UCKhXc
         f5Ww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=k2z623VUchf7dmtqaMObbgBBjHMdeVEZr8ifyE6cuHk=;
        b=dOM9rQCV/VSABgIq/ebd5vs/jsxmiLvOylbEiwoW1exuvQyh717UkEERoCf9Xv0coC
         eMcvBYOL1EreNe3YyFxXtDrU/Hy4RgvCzC5Mg49ywBUHqxRyJ+8YSZRwZeqPQ7SBOMfw
         HLydMJ/Tpv6ribHuQM6kWZTL7VWqWFbNfeIpuuAK2AZsA1Jg9ITDv24IJEWF4i5Fq9Bv
         DEiMKJsZIfZukZDkwj10mLKrNyXTDl9VmNgRmIC0QSnbZaJzAnX9Xmj+iCm5nXnzg8/J
         tCurFHH0BJwZ6rDWUc/7NhPieLmni4HR7TsBowlab42efLNtsrWjx3ZvPa0tNiG1Y+/4
         BECw==
X-Gm-Message-State: APjAAAVs1kqDtFykyns2aooA3W2PI597AwvJn+d4Cinx1qXhNKbtHELP
	HPL0DbVgQbIMT/jqGfBjA7Y=
X-Google-Smtp-Source: APXvYqx/iUItC4YvD87H8Wb2U1ObFRvxrcV97Xh4Z56hWqhd8c+J/kBMLQ14dtNrD2hfhoFjtmpihA==
X-Received: by 2002:ac2:5297:: with SMTP id q23mr9787630lfm.78.1567417767019;
        Mon, 02 Sep 2019 02:49:27 -0700 (PDT)
Received: from localhost.localdomain (mobile-user-2e84ba-175.dhcp.inet.fi. [46.132.186.175])
        by smtp.gmail.com with ESMTPSA id h1sm771635lja.18.2019.09.02.02.49.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Sep 2019 02:49:26 -0700 (PDT)
From: Janne Karhunen <janne.karhunen@gmail.com>
To: linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	zohar@linux.ibm.com,
	linux-mm@kvack.org,
	viro@zeniv.linux.org.uk
Cc: Janne Karhunen <janne.karhunen@gmail.com>,
	Konsta Karsisto <konsta.karsisto@gmail.com>
Subject: [PATCH 2/3] ima: update the file measurement on truncate
Date: Mon,  2 Sep 2019 12:45:39 +0300
Message-Id: <20190902094540.12786-2-janne.karhunen@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190902094540.12786-1-janne.karhunen@gmail.com>
References: <20190902094540.12786-1-janne.karhunen@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000011, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let IMA know when a file is being opened with truncate
or truncated directly.

Depends on commit 72649b7862a7 ("ima: keep the integrity state of open files up to date")'

Signed-off-by: Janne Karhunen <janne.karhunen@gmail.com>
Signed-off-by: Konsta Karsisto <konsta.karsisto@gmail.com>
---
 fs/namei.c | 5 ++++-
 fs/open.c  | 3 +++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index 209c51a5226c..0994fe26bef1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3418,8 +3418,11 @@ static int do_last(struct nameidata *nd,
 		goto out;
 opened:
 	error = ima_file_check(file, op->acc_mode);
-	if (!error && will_truncate)
+	if (!error && will_truncate) {
 		error = handle_truncate(file);
+		if (!error)
+			ima_file_update(file);
+	}
 out:
 	if (unlikely(error > 0)) {
 		WARN_ON(1);
diff --git a/fs/open.c b/fs/open.c
index a59abe3c669a..98c2d4629371 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -63,6 +63,9 @@ int do_truncate(struct dentry *dentry, loff_t length, unsigned int time_attrs,
 	/* Note any delegations or leases have already been broken: */
 	ret = notify_change(dentry, &newattrs, NULL);
 	inode_unlock(dentry->d_inode);
+
+	if (filp)
+		ima_file_update(filp);
 	return ret;
 }
 
-- 
2.17.1


