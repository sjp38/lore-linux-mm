Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDB7FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:18:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A49972075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:18:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="IGPkThvK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A49972075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53E378E0018; Wed, 13 Mar 2019 15:18:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 515B78E0001; Wed, 13 Mar 2019 15:18:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 404E68E0018; Wed, 13 Mar 2019 15:18:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 005328E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:18:34 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u19so3274964pfn.1
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:18:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X+0l/21nnF8OwI3h1KN4ErydF4UEhJQhx8/TC2xFgNY=;
        b=Z8rSs8B3QYeHnGqdp4U/kkqge14BheytTXCxmUQDjBuVZkVfIsqdAPsJHq3t/dPUAb
         r5S7G7dLyAkNXgcGtSycx471QJI2K1xRaWkvLKFKAB362pem+4yAh7XdoHHtpmIXg7yW
         gkG5EAqOlUjXVb4kl0vKcGJcMbGc7NVuBaxQQNssFJ5VapDY/eujp7MJij/xB1cBmE3p
         ZxgjuCWkU9WzfGezGqQXNRmrWRlXK0Ky12bDsJr38CrKlZIiKMprr1HWmo2i3M6BgY9e
         zvmXkC9yGSlRRSz7dWZBKJRBUeh4mJ2oxbXM/XoTNYpNGkIHlWHBTL2BQkS+jZSxiwMN
         NDlA==
X-Gm-Message-State: APjAAAX3PaNrUOf2XWEV04jrb/Dd7MGD1qPDnWXqr0OrrQlR7+3HZBKp
	34UR6c1MOPdnxIhzoUcjNU/lqgaHWpZiVBsI+G7HUqxuZoLEpeIilv24iaiAaal44lvVE52KR+r
	3xhLHrcxC/NoiYSW7u/XzV+Kfbs4oh6xrmJ/KeVHsmNJPxGUwEDKFurnIoW90KVdXTw==
X-Received: by 2002:a63:2a86:: with SMTP id q128mr14820229pgq.424.1552504713602;
        Wed, 13 Mar 2019 12:18:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9ffhMjaZom8QR5jl1sytBTSflMomissCZiWQ4gObS/E8uDas8KwKZXuiyalAeSDvv9/dv
X-Received: by 2002:a63:2a86:: with SMTP id q128mr14820168pgq.424.1552504712855;
        Wed, 13 Mar 2019 12:18:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504712; cv=none;
        d=google.com; s=arc-20160816;
        b=n9XBQmr3YhoNW0vQCsW//l6d3k1jY7YwrOFV0hwX9Av9egliBjJk0ftUdbe44hOsrs
         bKEN64rKY1znUG3iNo4HlhDHsJuxSSV22W6WqRstXkq3OaYacPdBI1f8XmaTHoG/wFFD
         6B53ZvujWRp3nTNYmdN4GW8oYczBH73ZOiLcVOT4/OPC55rYBURx0qkdomFY1V3YoUVl
         MtcTDKn2MV4G7MatiEAh8vHcVKV6NbcqryHfC9G0S2L4/NgrG/aldSykbbxcjV/KCCgY
         NOtdEAYn5JlGpWV9sfzmgllqjC6iL/4fKDtux1u/tKdgPc2oS44iAxLnwP3Y3NpUsvs4
         3V3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=X+0l/21nnF8OwI3h1KN4ErydF4UEhJQhx8/TC2xFgNY=;
        b=xbWWWKcQ2VToq/FJWKfqNqCPXwWqV2YmqCbo1MWCF3oEfh971V524eYTKln8uRMJSr
         9pxrCom7DY/L3v2y+hnDUrK28tLmbluOI1rhif1f243xfN7/tNare+P8OXUKRn8AfxuT
         acU7GP5QyuQ8QwrmcSBHwTP/+FSI9gySBKqORFnXEvzYHg5gV9CEe+1prQjOaRFCHlwD
         GJW0tQXbxtx7WjlGO4nyQhNxURbCEarb62A+fYrAgX49fVi+A4ggZ/937W/0e/Zw0Dmc
         7Rz7otz9GxU1ROM+kwbMF6v5zFh0aw/PpdHhiJckWT9VNbnQE32M3WK09XmtokQ+rDcU
         V+xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IGPkThvK;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 59si12147967plb.405.2019.03.13.12.18.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:18:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IGPkThvK;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A7291217F5;
	Wed, 13 Mar 2019 19:18:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504712;
	bh=Gy41IntoW9zDc+4SvaYFkEzrMixdHyrMNGOPn18QZJA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=IGPkThvKUh08LEjBy45Sc0FASiCmmyh2VyO1mkBJGVTyf6DNgu1RAHHd0FHxzsQzb
	 8kUypHdCrBzt4QkO4Y243YviEYvvG70HXbqwox4PE0k4b//p7MjFhPCAcSDjUt8jBN
	 4xPrH7ULVRH4turElBSowqZlTm3Eg5UpivVrs1qc=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
	Hugh Dickins <hughd@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.4 10/15] tmpfs: fix link accounting when a tmpfile is linked in
Date: Wed, 13 Mar 2019 15:17:56 -0400
Message-Id: <20190313191806.160547-10-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191806.160547-1-sashal@kernel.org>
References: <20190313191806.160547-1-sashal@kernel.org>
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
index d902b413941a..183ed4dae219 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2299,10 +2299,14 @@ static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentr
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

