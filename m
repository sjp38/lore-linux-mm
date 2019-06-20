Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66701C48BE4
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:18:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E99B20675
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:18:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="KL5ut//f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E99B20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 888888E0002; Thu, 20 Jun 2019 11:18:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 860708E0001; Thu, 20 Jun 2019 11:18:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 774D98E0002; Thu, 20 Jun 2019 11:18:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 565938E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:18:51 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id m1so5725894iop.1
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:18:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=cjD1oM5q5tMvxLtnHLi6QjIV6Kzj0WhrdaBw8sxqP6E=;
        b=DrMvxhpHGv0iMlHYxupa53lh0oC6zHIdWVOW7dcnDJANPuuEqJhFFEeiBnvpK3qtIx
         YajHNTIOhqeQWpDI4mIk3OVQ3NXoAxwPyPiVKtxhsGXXmTPnduzgb8H2k0tTeTziiZPW
         NabJFh2tvnrwqk8LbBatWRcsIbnAjupVI7ZSlOqTf/cCEQAWuX0SjR47jDJ7C1SLlPDS
         EWswhZVSZq3j8hqaGI2+1rVU8+1XCn9GnK6FZdcV/P/0M7aFkdQR91WjiW6U+kiiyi2L
         qCXL0Wc/XVLThkg1KWu6Dyych0OW4QY18mN8Y/LGaCmeBqOkX+b1/yEScSuPem1G0RCL
         MyDw==
X-Gm-Message-State: APjAAAWuU+s3WlLo1Dqku9+AWCj/jozkLjQcZPk4IyVVMLbodfDqhXaz
	Rq4lfuqxl2f02GSugbuLkWjm8QP4QQLn9/5k6XTQV3Ibo3qHXpYDqY71wEv4q5fW3l2xf01uJ+Q
	VFsPE+BwoKLTLKrxzS7vj0WWToLzvfV96EdpBiVf/efJC4j9jplZJTmif0T/0MBYaYg==
X-Received: by 2002:a5d:924e:: with SMTP id e14mr19618387iol.215.1561043931111;
        Thu, 20 Jun 2019 08:18:51 -0700 (PDT)
X-Received: by 2002:a5d:924e:: with SMTP id e14mr19618333iol.215.1561043930413;
        Thu, 20 Jun 2019 08:18:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561043930; cv=none;
        d=google.com; s=arc-20160816;
        b=m6g9r8VMogeNHSTIGQqY4C1k1rbNDLkL6swTiAfw8gRIFJWa32eTAIaae4DzpQuUEF
         Qr7drkHbQUCaSVjFO0maqGq6/C29kb+dy/VNB2o8qY0dYo/x9YWv/Ih9AvQj/nw2VOMu
         TjcFSOBDHv9yoWGlPdV0hcZMQpQ4+yCe5fPgs/b7BGSrF/VSrfVoygrim6TkJ1DfbjFi
         S6RWpvRoy9ozCaQYjqdQzJVdpbnGPIcuDT+LbU2XdF4fxKgwKRHXZ/RgxO5O87mZWATo
         Ypau8ONRa4GAdQEu99liK3pVa+Jxjk9SyqeLPLE0NpV02ZY1o8pGHeObWhFXs4F2Eoqa
         sj6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=cjD1oM5q5tMvxLtnHLi6QjIV6Kzj0WhrdaBw8sxqP6E=;
        b=KLTr1XjYn45Lj3Euv5UEiqZLGkFVUHeXUfviANB+ekZABgkU3LX+79+9Dbwu8eZPaF
         rY4HRnKaCWx3kGiLiY29lg1wzQGb3jOO4pbg9wAzTC4fZSXuujQhLPwYyl0Y/mpm+vZr
         GDvexUHUsKgm/+SGsN2ALzhbsqKo63SEe5AjQeR9iJB7Vf/NF0YxQbld8wGRRiZGvp13
         8nDXUoIGgfhtUOBqErya5SAkJWpv3+g60k7Lf0RZWGAmne/2THvqLegC/ITkO8H58Z6E
         IIhI0qbHhnYDzdDpCwRyWkQu4zC+ZjZV0w/EQYVYTj4hfgqEiXkMzMs5GOWuKnKQ2s6e
         Zb+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="KL5ut//f";
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e15sor17748434ioc.31.2019.06.20.08.18.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 08:18:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="KL5ut//f";
       spf=pass (google.com: domain of zwisler@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=cjD1oM5q5tMvxLtnHLi6QjIV6Kzj0WhrdaBw8sxqP6E=;
        b=KL5ut//fcz2BIKILaDyB8ohi01uo46BlAttcUNa51KKAK1tcFXFhC8SCH2ucE0+zu0
         joRzLAIQOyAlR2Jt4XsZvDwQoJQxyJxF0Eha7wO+Lcc8hMsDmgZFzdjia1zGXgTCUqe+
         R4q+jSRaCPpupw065Ncg6Ytj3OtHHyjuvu7rI=
X-Google-Smtp-Source: APXvYqyhVkr7S5sXnpnoik5KXYCmAR287xq9lSFfhPvYClEQVEFY414UtXFLtAdnecBoub+5eQcwPg==
X-Received: by 2002:a6b:641a:: with SMTP id t26mr5195793iog.3.1561043929997;
        Thu, 20 Jun 2019 08:18:49 -0700 (PDT)
Received: from localhost ([2620:15c:183:200:855f:8919:84a7:4794])
        by smtp.gmail.com with ESMTPSA id c23sm140526iod.11.2019.06.20.08.18.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 08:18:49 -0700 (PDT)
From: Ross Zwisler <zwisler@chromium.org>
X-Google-Original-From: Ross Zwisler <zwisler@google.com>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <zwisler@google.com>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Jan Kara <jack@suse.com>,
	linux-ext4@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Fletcher Woodruff <fletcherw@google.com>,
	Justin TerAvest <teravest@google.com>
Subject: [PATCH v2 0/3] Add dirty range scoping to jbd2
Date: Thu, 20 Jun 2019 09:18:36 -0600
Message-Id: <20190620151839.195506-1-zwisler@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes from v1:
 - Relocated the code which resets dirty range upon transaction completion.
   (Jan)
 - Cc'd stable@vger.kernel.org because we see this issue with v4.14 and
   v4.19 stable kernels in the field.

---

This patch series fixes the issue I described here:

https://www.spinics.net/lists/linux-block/msg38274.html

Essentially the issue is that journal_finish_inode_data_buffers() operates
on the entire address space of each of the inodes associated with a given
journal entry.  This means that if we have an inode where we are constantly
appending dirty pages we can end up waiting for an indefinite amount of
time in journal_finish_inode_data_buffers().

This series improves this situation in ext4 by scoping each of the inode
dirty ranges associated with a given transaction.  Other users of jbd2
which don't (yet?) take advantage of this scoping (ocfs2) will continue to
have the old behavior.

Ross Zwisler (3):
  mm: add filemap_fdatawait_range_keep_errors()
  jbd2: introduce jbd2_inode dirty range scoping
  ext4: use jbd2_inode dirty range scoping

 fs/ext4/ext4_jbd2.h   | 12 +++++------
 fs/ext4/inode.c       | 13 +++++++++---
 fs/ext4/move_extent.c |  3 ++-
 fs/jbd2/commit.c      | 23 ++++++++++++++------
 fs/jbd2/journal.c     |  2 ++
 fs/jbd2/transaction.c | 49 ++++++++++++++++++++++++-------------------
 include/linux/fs.h    |  2 ++
 include/linux/jbd2.h  | 22 +++++++++++++++++++
 mm/filemap.c          | 22 +++++++++++++++++++
 9 files changed, 111 insertions(+), 37 deletions(-)

-- 
2.22.0.410.gd8fdbe21b5-goog

