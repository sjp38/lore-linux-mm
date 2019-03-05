Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F70CC43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 00:46:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2999320675
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 00:46:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YT8us2NR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2999320675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 847E08E0003; Mon,  4 Mar 2019 19:46:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F5818E0001; Mon,  4 Mar 2019 19:46:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 696C38E0003; Mon,  4 Mar 2019 19:46:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25E498E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 19:46:32 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id j10so7297218pfn.13
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 16:46:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=QfpMaV94+0wgT+OuqRPo5XEGlcPZK1e4dqOorDrF3ZY=;
        b=GIvjDRfcXKQYl7GSRSXnXocYMFum8q8f1JzvPQ9kHKjsEMCKHQgDtGS/+AhvTAY8R1
         AUKHl1cOZwP0KTQ1UJA+AXwJ9FSHnay+NFb5ritONQRyRI51AMVvRM/7xlYYQ7kpWUO6
         hMZ7rMxh2+wQyuwWg63EBTtr1ikJpTnXG4sqZLkcMiiymvOTXTMQSu/M4sUlPOu1SkWV
         4nCccqYOpfXzplic43jkFUW9IqOl+peGhMrQNHGHTCJq0GbpGhiF5+6zg0HHfAL3Bkyi
         jodaN5dMivS3pL22majCiDwirJuruQXClUF08CpHCX2GSl0htK25CNJ/DW8KDG2zJwkP
         ioaw==
X-Gm-Message-State: APjAAAUzInrKKcNkN3AdqxTPpW5BVBCNOsAbw+iNq44Ahlb5KmzFp6+q
	2J/wPqUBTFwjvwDr+BbCmVqJBISvom4lanPQCZp4y8UUaaDT1mwcz6/KnNWVhI7uE7aCPX1bM39
	nIAa0+++6hoUHoY33OMyitSnAkgMmRvlZranm8FQA3X0Wz35yOH7CsY1aRbxQ8vf+EPXbEvO5xw
	RMKAC+FDRKFMsqcDrpwl0/BK+vDXcMMiWHUPi8CIYmacqPWA7xJYiPLNUOqDEfTQH9KPFfS/OiB
	tqHqn6Ohk++9ss9nLEORNyktWKZyOVkP3BaoyQki1g5AHS8rw5leJZ/D9xtAaFGU5WjfD9R3/dS
	NoS7aAOnFb0okD+2u/uK+RIfDfl7c8eU9jOUvNFVPyc7rhecYVBBrMY6aPmV4HXEfVKI6M289R3
	S
X-Received: by 2002:a17:902:a50a:: with SMTP id s10mr22727947plq.223.1551746791638;
        Mon, 04 Mar 2019 16:46:31 -0800 (PST)
X-Received: by 2002:a17:902:a50a:: with SMTP id s10mr22727881plq.223.1551746790637;
        Mon, 04 Mar 2019 16:46:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551746790; cv=none;
        d=google.com; s=arc-20160816;
        b=LJxfH075AzgOX+b1cMyB8x37XYPCjM28lulINCWF+wjpw0SuipTvJCGJgsWaktrGCh
         4ZaeXI02wij7fX8oNY4OmhcJL6MKQrhsAx3noPtpFRztMykhlY4yrb26VRIj006dYWWN
         v7AvoFoqt6dCrtBZiRGSjIx2FVWe+uChtw1fkBDFs3EZsRKr2EoEn5ULuKuLSmrtgKX8
         EfCeZsdKHnyikPog1wS8Lvt1wEsqGKn+ibEicV7kkauaz88a2b6Dbbt1qqcF/NYH83b6
         ck28jxQyYp7Hd28MHvG0isSPOsQBQCoHlZ0qKly9Vlq3DJ84AcI+RhtTYiqhIUNgH53C
         9QMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=QfpMaV94+0wgT+OuqRPo5XEGlcPZK1e4dqOorDrF3ZY=;
        b=cGMag2uHvvEuCGdfcAXLGE9vJB+AyhnjkUmPGmwHXquqHWtkPhsA2XlpN4LTa9Nji1
         lxz4r/0g266YRJJD5M6qQyhqFRoDx/qTJs0IOL3rdu8LIEG7gQ6ADbnfQhclyLusRl/U
         xjZpcyc3f0cIaxDPm0TgU7tgZ7zScjxj+sG/rQiSu//A2tMuw+JTidXpZBqpAZpZIJQv
         Nj+S1pqA/vjdOU4RZzY6SEWH+2q8qwzpCXd7NqAYIoWIgf38uO7Jqg4Wz/vI7/IKRWnx
         S4xjV5w2PXtdup7iUbx1LGNi0nzC0cJhCPufyLqajEk7ZUcm0iUw1FiFZ7b062caUoRu
         MnDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YT8us2NR;
       spf=pass (google.com: domain of 35cz9xackcfq2f307092aa270.ya8749gj-886hwy6.ad2@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35cZ9XAcKCFQ2F307092AA270.yA8749GJ-886Hwy6.AD2@flex--gthelen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id s15sor10865466plr.6.2019.03.04.16.46.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 16:46:30 -0800 (PST)
Received-SPF: pass (google.com: domain of 35cz9xackcfq2f307092aa270.ya8749gj-886hwy6.ad2@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YT8us2NR;
       spf=pass (google.com: domain of 35cz9xackcfq2f307092aa270.ya8749gj-886hwy6.ad2@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35cZ9XAcKCFQ2F307092AA270.yA8749GJ-886Hwy6.AD2@flex--gthelen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=QfpMaV94+0wgT+OuqRPo5XEGlcPZK1e4dqOorDrF3ZY=;
        b=YT8us2NRgFHYgT4mRU4IW96mK04cQbPtnO1IAE/tauoXqLg0jDxK4WQR1RitCpDODe
         D8fuQMxT3db3pVPvpH+hbXAP15B4iRY7fA98xVdITwfiW/I20fHiFla/hYSfdIK32VO0
         zcEiGH9Fq96ZjWzZuyQkQRr4Ny3mAaZ1NN6t5c2yF+grVCZc7Tw1VBjOtTq6+5+ou1CL
         752/bsRVT2elbSZXium+72a6MWvq7DVgeGje5UZ60WISsyVGYyQCitw2gebWn5PkwIOg
         Nmp3zT1nkSvorDnmS8lIRGhFPu7SxJ/GZb5itspuceQJQHmG8aEYcjxDyAwl/Xrq3TTo
         p5cg==
X-Google-Smtp-Source: APXvYqxlyZF9zMvOdEA5eS1pFBL7W2vAqV7/HcaChTdd6/KURqoPkhMPJPP5T4fyPGMYe7KVvr89whKIEkSj
X-Received: by 2002:a17:902:2c83:: with SMTP id n3mr1914198plb.105.1551746789992;
 Mon, 04 Mar 2019 16:46:29 -0800 (PST)
Date: Mon,  4 Mar 2019 16:46:17 -0800
Message-Id: <20190305004617.142590-1-gthelen@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.352.gf09ad66450-goog
Subject: [PATCH] writeback: fix inode cgroup switching comment
From: Greg Thelen <gthelen@google.com>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 682aa8e1a6a1 ("writeback: implement unlocked_inode_to_wb
transaction and use it for stat updates") refers to
inode_switch_wb_work_fn() which never got merged.  Switch the comments
to inode_switch_wbs_work_fn().

Fixes: 682aa8e1a6a1 ("writeback: implement unlocked_inode_to_wb transaction and use it for stat updates")
Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/backing-dev.h | 2 +-
 include/linux/fs.h          | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index c28a47cbe355..f9b029180241 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -365,7 +365,7 @@ unlocked_inode_to_wb_begin(struct inode *inode, struct wb_lock_cookie *cookie)
 	rcu_read_lock();
 
 	/*
-	 * Paired with store_release in inode_switch_wb_work_fn() and
+	 * Paired with store_release in inode_switch_wbs_work_fn() and
 	 * ensures that we see the new wb if we see cleared I_WB_SWITCH.
 	 */
 	cookie->locked = smp_load_acquire(&inode->i_state) & I_WB_SWITCH;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index fd423fec8d83..08f26046233e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2091,7 +2091,7 @@ static inline void init_sync_kiocb(struct kiocb *kiocb, struct file *filp)
  * I_WB_SWITCH		Cgroup bdi_writeback switching in progress.  Used to
  *			synchronize competing switching instances and to tell
  *			wb stat updates to grab the i_pages lock.  See
- *			inode_switch_wb_work_fn() for details.
+ *			inode_switch_wbs_work_fn() for details.
  *
  * I_OVL_INUSE		Used by overlayfs to get exclusive ownership on upper
  *			and work dirs among overlayfs mounts.
-- 
2.21.0.352.gf09ad66450-goog

