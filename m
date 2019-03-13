Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 870B9C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:16:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 327622184D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:16:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zcpKNgkS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 327622184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D32398E0010; Wed, 13 Mar 2019 15:16:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBA0A8E0001; Wed, 13 Mar 2019 15:16:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCEAA8E0010; Wed, 13 Mar 2019 15:16:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 769E18E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:16:05 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e5so3184855pfi.23
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:16:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/27LNRmOb8FlDyxP7zqJPKtVFwBbV0/Z5NOs4TfxTec=;
        b=pEZgbytnDndzhR7GsvMT5vFNJH53tFnjYZhKtN4MRCLUIK70P3/vfBDg1j+K83itsO
         avupWlZypelDn+Gj6WFYAtC3QeWGIWEKV4vqCWsO5tKVT8ikBWP24bTzeRFKd4Q9idMy
         f6w5a1yEuLdmtxbQx/xsMnUWh+lWw3QBBFqGx4SAUeUkq0jZAAcBGbTuoI7ochrf1mTu
         EF/sAJZuDkDa7zVxCH8cWDVdCHkfrFHDTsa6HppB2zZqlPMyhozw8gxr7mksr9Z+TGaV
         CCbmCePuOvuI7KbOEibwG5ym+s69caZIwT5DtAll1zF5m6qnH9loowmF2qAWrypFmFeN
         PNyA==
X-Gm-Message-State: APjAAAX9LCzNx0ccS0ga8+DVfUQoKVjO/g8+37LM29JGnliz8b4B0FuY
	RHxbiV0JS0SrBSDpQMo5In2N5jAmDhWEA96s/09T0LDKAUVzMcJNPaCRCtuUp3LyWNCyHQf4Q/r
	Q3Gh/mjFOWHWGsPoF3tNYsv9torR8V/yuJw4d5xpy7h4gBkWA+HFLClKBvJRqwxAS4A==
X-Received: by 2002:a62:8c:: with SMTP id 134mr44977680pfa.27.1552504565140;
        Wed, 13 Mar 2019 12:16:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxR5NrmXmWMSSRxtwgtv4sXotQEcr+6cDAnueZ/E2zZCkU9aRMdMF02Lx34cJLm7T2wbrA/
X-Received: by 2002:a62:8c:: with SMTP id 134mr44977614pfa.27.1552504564372;
        Wed, 13 Mar 2019 12:16:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504564; cv=none;
        d=google.com; s=arc-20160816;
        b=IsZ5YS1u1n6CxzsWSUieflr2gfwhfJ8YnQL2zG+D1Xs74sGcY7twAQvXdv8uR8h9td
         Pse369RRsGiuYYEouVhMsHmuAXHTdsCnKSd5lXVc0+05/yUT3GevXuTokJ9gng4NHXdh
         4Yke9fULpHElJnwe+d9pd1LRfn1tz+awuACDgisPShAy5csDHUNdltcGMfbDODVtBkiS
         fOtKTFXh261dMjMNW+wfG1h6MJl4xH5QhAm8+7LKnCZ0atqAPCiPJ44SUoW77T/GYMYa
         d9JAgIoKKeEa8G0nUtX4s+Sy1wDPCDEoSaRL3n35MI/ZQ9zhF6xN8QWXeHkjRYrQoPjN
         QGlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/27LNRmOb8FlDyxP7zqJPKtVFwBbV0/Z5NOs4TfxTec=;
        b=tu/TiYq3QzjlfrX9gvWKJJh2r7pqCeGHuooKWVhjY0KRL37ZvTJIO3V6fe9r3JALLB
         iPVIDpOXbUSMwajyglowUG7bwTSbcL6xao45cTYdd2gUf361Txhz+jndPKLEG2u/Qszf
         /Cn8AK9E20PNTG5EdpJc+t9KhMpWHc7Y2Qji9AqwPzUmC17EOlHF0nX6v1UV9uwISvub
         VsT2Di2p88liv7F8QjP9ReG1pOLvsjLXoYc/TA1Z7JxXkfVZdItVE3eiFHwHS4YQc1Mv
         8yxt0GqNww9c+fiL8vuStVz56vVO8WTmqYbEIY7l7BjTE8OZByD9fR6Kq/rWNv8PsQjA
         dTBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zcpKNgkS;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j187si11232228pfc.251.2019.03.13.12.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:16:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zcpKNgkS;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 42275213A2;
	Wed, 13 Mar 2019 19:16:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504564;
	bh=osq9wRmZfHMZ39lms34CAmDC6/s0jG8diM+w/yE3gdg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=zcpKNgkS7b93nqJDVvFyqgF5kvrirHl6gDldOXo/1umNGYmjmsfRb2AXLa+5skVZK
	 weY5e5zqgW2BMOCk8QSMO38YVMBVU/FYUf8T5SAIEF4pYUQK8GwJiWb1glQzoq49St
	 MtVI4TAy3WR/+8GOwY7ekqCPGlzoeFoWbnyVXdXE=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
	Hugh Dickins <hughd@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 20/33] tmpfs: fix link accounting when a tmpfile is linked in
Date: Wed, 13 Mar 2019 15:14:53 -0400
Message-Id: <20190313191506.159677-20-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191506.159677-1-sashal@kernel.org>
References: <20190313191506.159677-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Darrick J. Wong" <darrick.wong@oracle.com>

[ Upstream commit 1062af920c07f5b54cf5060fde3339da6df0cf6b ]

tmpfs has a peculiarity of accounting hard links as if they were
separate inodes: so that when the number of inodes is limited, as it is
by default, a user cannot soak up an unlimited amount of unreclaimable
dcache memory just by repeatedly linking a file.

But when v3.11 added O_TMPFILE, and the ability to use linkat() on the
fd, we missed accommodating this new case in tmpfs: "df -i" shows that
an extra "inode" remains accounted after the file is unlinked and the fd
closed and the actual inode evicted.  If a user repeatedly links
tmpfiles into a tmpfs, the limit will be hit (ENOSPC) even after they
are deleted.

Just skip the extra reservation from shmem_link() in this case: there's
a sense in which this first link of a tmpfile is then cheaper than a
hard link of another file, but the accounting works out, and there's
still good limiting, so no need to do anything more complicated.

Link: http://lkml.kernel.org/r/alpine.LSU.2.11.1902182134370.7035@eggly.anvils
Fixes: f4e0c30c191 ("allow the temp files created by open() to be linked to")
Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Reported-by: Matej Kupljen <matej.kupljen@gmail.com>
Acked-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/shmem.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 6c10f1d92251..9b78c04f532b 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3102,10 +3102,14 @@ static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentr
 	 * No ordinary (disk based) filesystem counts links as inodes;
 	 * but each new link needs a new dentry, pinning lowmem, and
 	 * tmpfs dentries cannot be pruned until they are unlinked.
+	 * But if an O_TMPFILE file is linked into the tmpfs, the
+	 * first link must skip that, to get the accounting right.
 	 */
-	ret = shmem_reserve_inode(inode->i_sb);
-	if (ret)
-		goto out;
+	if (inode->i_nlink) {
+		ret = shmem_reserve_inode(inode->i_sb);
+		if (ret)
+			goto out;
+	}
 
 	dir->i_size += BOGO_DIRENT_SIZE;
 	inode->i_ctime = dir->i_ctime = dir->i_mtime = current_time(inode);
-- 
2.19.1

