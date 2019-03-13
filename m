Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0741FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:19:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A528B2177E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:19:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="en4K4oFq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A528B2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53E0D8E001A; Wed, 13 Mar 2019 15:19:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 514F28E0001; Wed, 13 Mar 2019 15:19:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 452D58E001A; Wed, 13 Mar 2019 15:19:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 064078E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:19:09 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w4so3279537pgl.19
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:19:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2/jH88QHe/Gxcd5DDKEr6ctbBevvpQkxdwyL6lLWpmw=;
        b=WyTUBdPWrvCtf89RaROZ4NWA3X4dyHYIH6tdbP3oGRAAXgGGfcwa85BDC9Xic58TdE
         d9Wd8IByjaE1eJMtVz5M5sup7tW9gATWhPKTW6lnU9D9LX7XWdAG4CU0V3FLbffeOkx5
         Ge/nRC+9V+hS7MkELgPSKCorWeUtQRsFVXA0sL9F+m0YwbZjaeQX/A9Xeg//hdmCOrqH
         LofNxaofrEWJhUVTgouxPUr8Rg0AiCnCRIZgA9n9/Dm8h7QIFkaAxLmyBX5BfTkhF/9B
         rwxleejnB5Sxi1OP5GjmSTSw6FwlApGUOMRiRUAFGFGotraHpmXPgjaTacqK9h3bej9X
         NLYw==
X-Gm-Message-State: APjAAAVl563rsOEB+jhrzj8VDuBjPRHw3uS/qolLhgK07S6lpAO8m5SI
	fdjeWZTFOqxH2Qi9auQOYGP8ahuTPwQw/G9MiRbzWBKSft5YOVvGekI/6adjJpnqdhH0enQlgsS
	uZCQ/a3Lv2KHTpiqlZHHiFRLNe9x4xMne1Wxho12TvUBEPFZjIbWmzns06RLrBpj8KQ==
X-Received: by 2002:a17:902:b101:: with SMTP id q1mr47900995plr.296.1552504748643;
        Wed, 13 Mar 2019 12:19:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIifqFefj19uF48KRtxOM/hAGfjMVTsZF974Gbj91x91UyePY9AxbOvwe4YPTBSp9XCfuD
X-Received: by 2002:a17:902:b101:: with SMTP id q1mr47900947plr.296.1552504747928;
        Wed, 13 Mar 2019 12:19:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504747; cv=none;
        d=google.com; s=arc-20160816;
        b=HgYCWbkXRIg8gIr9ptv98VfU6qQnt6AguzKqcSpqxyi9HAE/heCvVuNg5HY4rN0R/f
         F9WuwIKYdoanVqsau+MbKZpqMz67O9OHpnB7T2t+QstvLdfe97eHvs7gh0atfslW0Q//
         N5d+swMRQzdAQjD4ujgwP1wSuFC0oFtcHEpXPH0N8YuCfmzbswSJhFP4zUE9860cbnyt
         bVsGL6Y0phDV0cjpqWExc2WSZ7sDwspNdSzOyupWvuCkZh2rJRWQtk/+Z4rji+zRBQpN
         BCTx+OsASteKVuz8oMHr67bzgEpB/cqse0Q0448nAt477iLzPANhBtsF4eoGxqzjXMhb
         tOCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2/jH88QHe/Gxcd5DDKEr6ctbBevvpQkxdwyL6lLWpmw=;
        b=TFY/HiZAKak+nAuQX0hFJooHZtcGdHYQqr7vNh/ODgzo1l3mT8yCyGlZ5dqHZQFzop
         4AQTisjISFj6zX8CHhJ0PDxc50OYB4I5Pmc7VLo400swSyHXPeZNqUmqMsebM8AYmcY7
         0DJ4nFO2vRbCJW2wZ6KB65VzJ+acF5dMRJP7e3SE8DXPJNeqDJKbqjKmGjBBtvwyRJql
         2xtMgqaSYXNc0KIWL3DRGQAF+BXW+cGFKuOVN5Ya88kvvvAFrLKWdEcf+76lHvtencSz
         g+FteQQW69Scn+O3gdTFN/GooeeA70qVveqZ19AkDUJdCjGgTjro/4ReH3I7LlsZvGN/
         3+ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=en4K4oFq;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p19si11489540plq.29.2019.03.13.12.19.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:19:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=en4K4oFq;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E15CE217F5;
	Wed, 13 Mar 2019 19:19:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504747;
	bh=tAISWTJvOVwFbYW71H8SdtJidJe7WdD08lPKl2WU0WQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=en4K4oFqHPwfJcdKrW0LJsiUjTFfqFUhP9JhZ98QMuAWQPE8j53/FzMiyh7xwswfy
	 DHL52IN++sNpccQy3SwbaVNC5JYAwpqj/JOJl34dbBl6MHd0P9O3QzL7Xq1D2/y7Or
	 0p3qxbxCeemHDH8eHNiXzTqL8Jhnj7Uw6Ii/hUwo=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
	Hugh Dickins <hughd@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 3.18 08/10] tmpfs: fix link accounting when a tmpfile is linked in
Date: Wed, 13 Mar 2019 15:18:44 -0400
Message-Id: <20190313191847.160801-8-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191847.160801-1-sashal@kernel.org>
References: <20190313191847.160801-1-sashal@kernel.org>
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
index 64c33e3dbe69..b40b13c94e03 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2286,10 +2286,14 @@ static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentr
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
 	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
-- 
2.19.1

