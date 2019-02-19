Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C445FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 05:38:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FBEC217D7
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 05:38:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IrVyG7M7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FBEC217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A0998E0004; Tue, 19 Feb 2019 00:38:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 153BD8E0002; Tue, 19 Feb 2019 00:38:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0417B8E0004; Tue, 19 Feb 2019 00:38:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA0798E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 00:38:02 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id j23so16986919otl.6
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 21:38:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:user-agent:mime-version;
        bh=7TgetPiKYsdjnOAeKC/fO5fqwlcjUzyiQLqeYUXldYM=;
        b=bnQ2NQPMbIKSjd7tTUp/iqEjDkJz3bDsPTb4aVtXdnaiObyb/PJF7XyKpJhkhbabuA
         is/BbuudXiL7oJ2B50guku0XFoSdUMTaMrEMTlugP6U0w5J7lydekYK/9vudsgjHRIqW
         e74zGs0ox5dD/MB7bnMV1zFFfmRjNHYupR7C0QDZG3ROiZ3cz83SRUlea6RkVwbx7Fo9
         M2LWd60PBbgkOKelmbdRDAZFGYNwLy/YVc+3QG1ttwifSrPzEAsyS5E267Zm0JEMj+ul
         PigO6TU9tzYrGyjPTGRJdGWWJ2+OGW4SQ6+UDjCxVnA5j4ztHSGugYyNKYMgsJXT/Spj
         7p9w==
X-Gm-Message-State: AHQUAuZbkXZtVMtXSqq5fkbCA1tEHOTaPGbjYxgeA0oq1HHTzVEOACMn
	vk0Zf5ylbV+hTQbe+RSnP1bxugIQzXeD91zZAxvlVDgxgf6K50XuLoKJp/xSDt9hRI99KsC60Q4
	Q4zK5hnS2mym8dtKaPg9Ja6p+9unyC11Su0/Q5fvD/cdrldH68mFxJ3HRicBj2jQaQGqf+dD5JD
	PuXiQwq1oENvraPPi0uakF53Nzz0S+HaWbdijgBGiybHXo1tK0+O5hLtZi9cmsDb8l6R9ydR/Lc
	CLw6PKTsNa4tb8NJ0SaD9GxN4cv4+eVzY9puzKJyFAt2ICQO14AesWMoCEaUcx73Dpgk9bOfyW0
	NRlE+dFOtJeNRDm+GqnnUOztgqWonvNC7OsBqu4Zr//+ibqOnRSxjyDDaavtduS6igfR+kQq4UP
	4
X-Received: by 2002:a05:6808:211:: with SMTP id l17mr1501198oie.166.1550554682566;
        Mon, 18 Feb 2019 21:38:02 -0800 (PST)
X-Received: by 2002:a05:6808:211:: with SMTP id l17mr1501178oie.166.1550554681870;
        Mon, 18 Feb 2019 21:38:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550554681; cv=none;
        d=google.com; s=arc-20160816;
        b=Fw18nLtDoqvars+4RGtrIRIytE81pGQcB2QIXpmaJ4eL4kLe6MTSVqPCjTtpizJ+re
         QpF2Qhjyrfdzv3AcQwwpdTKO40Cci8NAr22DkTz7lqouhkSinWJ1pDVLiT7V8T5bEVVe
         9KWM/QemS6K5jLYNQHhTitTs2j79D/9FaObs1sgHmO5OWkssAlck1xdkq+U1NpdEfxY6
         fJFsxoH3U0W0ud1Vx+JIxGscCwbxfrv45wxV/gXSUj5UTkCovaqE7zp64bBvjCtRFAA9
         eshHymr9LZwSGRta7M8APzWzPecUNAh4mrBaRqxy4St/7w8Ux70ve1DXuye4avvu3uFV
         ugTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:subject:cc:to:from:date
         :dkim-signature;
        bh=7TgetPiKYsdjnOAeKC/fO5fqwlcjUzyiQLqeYUXldYM=;
        b=EuFvKlslEYesifjulQDIxLfayvaSAQCck1OIwjM+5lqBAoVxfGHsdvw6JfumMGu+QF
         /ECrp8gIWmofq4VNJXPrk9Czcvsf9bhNcXYFIV8Qrbuskz8uTA+sntVCYWv5GFLXPl8g
         hN6erEGMfX01Wmov2oESMqyIWZ2VlkfwCkIGQk5uiXznbw/h23hVRxcmWpwmAY42EGsc
         O0mIXWC+vSu2tom/KNfwhqzG6gJbkd3UyLDSDApQgwzZCrBcV9GP1eQSBp+V1W+IXXdW
         ovvgLwnWqpTx1ZekrIg6ghAvvX5uiZfmeyN8t1kXZxUXLDTs+0VJspDt9nkNpUBlk7ip
         10tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IrVyG7M7;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20sor8076885otl.111.2019.02.18.21.38.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 21:38:01 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IrVyG7M7;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:user-agent:mime-version;
        bh=7TgetPiKYsdjnOAeKC/fO5fqwlcjUzyiQLqeYUXldYM=;
        b=IrVyG7M7DlLpaywnYWIxg3ulWcftgdss9wryWV/2BvZLja/i4ljxEZHrgKal4VbLAE
         vKDmRu9QPzRujb5aUjCeADBl+RGEmWx/8Ka9B0ZGksJ3/zkIZjNe/DyR2+RFxrpGlwag
         gQT+PNpzA2LVvRjERFfyhlsCghH+RfA1shAvkfU9AoRANWn1WWmVwMOIvzOzwqQ9yrnn
         HqrD4fLNqeGnJPCgm5a/LK+ImEFnUCrD8C2SvYqGGBxIvN1CFps9mVyOl1bLT78AALQy
         +jHGbQB/SuAK//WF0YPJ3ZFiUMePIJ4C7iEMBTvnUDKEm9NzVmEksLmxkuyIZZkk8c9w
         W6xQ==
X-Google-Smtp-Source: AHgI3IbmXH6vefHGSLsDWVj3usIfcJ+vdeCsDimIXsoxb9GUBNQc1zai148VCOMdqT2Nj1BO1MpAyw==
X-Received: by 2002:a05:6830:1648:: with SMTP id h8mr8856727otr.50.1550554681150;
        Mon, 18 Feb 2019 21:38:01 -0800 (PST)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id n8sm6528310otl.40.2019.02.18.21.37.59
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Feb 2019 21:38:00 -0800 (PST)
Date: Mon, 18 Feb 2019 21:37:52 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Andrew Morton <akpm@linux-foundation.org>
cc: "Darrick J. Wong" <darrick.wong@oracle.com>, 
    Hugh Dickins <hughd@google.com>, Matej Kupljen <matej.kupljen@gmail.com>, 
    linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: [PATCH] tmpfs: fix link accounting when a tmpfile is linked in
Message-ID: <alpine.LSU.2.11.1902182134370.7035@eggly.anvils>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Darrick J. Wong" <darrick.wong@oracle.com>

tmpfs has a peculiarity of accounting hard links as if they were separate
inodes: so that when the number of inodes is limited, as it is by default,
a user cannot soak up an unlimited amount of unreclaimable dcache memory
just by repeatedly linking a file.

But when v3.11 added O_TMPFILE, and the ability to use linkat() on the fd,
we missed accommodating this new case in tmpfs: "df -i" shows that an
extra "inode" remains accounted after the file is unlinked and the fd
closed and the actual inode evicted.  If a user repeatedly links tmpfiles
into a tmpfs, the limit will be hit (ENOSPC) even after they are deleted.

Just skip the extra reservation from shmem_link() in this case: there's
a sense in which this first link of a tmpfile is then cheaper than a
hard link of another file, but the accounting works out, and there's
still good limiting, so no need to do anything more complicated.

Fixes: f4e0c30c191 ("allow the temp files created by open() to be linked to")
Reported-by: Matej Kupljen <matej.kupljen@gmail.com>
Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

--- 5.0-rc7/mm/shmem.c	2019-01-06 19:15:45.764805103 -0800
+++ linux/mm/shmem.c	2019-02-18 13:56:48.388032606 -0800
@@ -2854,10 +2854,14 @@ static int shmem_link(struct dentry *old
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

