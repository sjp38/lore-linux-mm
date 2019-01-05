Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AB0CC43444
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 17:27:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB81421848
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 17:27:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB81421848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B09F8E0122; Sat,  5 Jan 2019 12:27:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1616D8E00F9; Sat,  5 Jan 2019 12:27:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04FA58E0122; Sat,  5 Jan 2019 12:27:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4108E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 12:27:09 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e12so36133505edd.16
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 09:27:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:user-agent:mime-version;
        bh=rbh7SbMsDzLW85qhFs/JA9KR+911TMgBdFkozzVBbtQ=;
        b=GncuAAb4e27vpYQ9azvC1pzOGHiVLLujXUn3rJu6Q8GZLJ5tiofH/wl6B9V4ixD7GS
         BVnznGt5UjASBXehl2mZAuEQNdlKpXaNX3y4Fjy7AC4BHv+lU0bdcEWYvCjumd1Asn8x
         4Rjf7nvhD/GXXGZp9+ZM0XTJt2/wbpHTBzkXnV3Leunib0CgqDBl7Q1hY4tP8rqmdBJF
         Li1EoGSsJGt4PTaYh+ohz2BRtQYcA6cc9rdzQn32Ny/9e9bRxHb85/KIXaqQsQW402EA
         Bd+v7s3eW72PI8MmN8HkzohHSDekHfA4LY33bhOpHXc2/WtexiU+zVUP1rsPOtB/DRlw
         qnjQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AA+aEWb7FJlFuQT9laCp9F1knAwMeZd7UxqxiruZuU4U/Q+vSJ5E23H6
	MQEqvKq3SFmBabfEvXClpGWBrIgnakyqmf0B0XcGSzqJXy3D7Z7AP74StX6dwpH5/IlRHBdgD/7
	2B+7ZxVAkvh85Qr1SofagfLfTohmee8m+ttj0fk0J43xr7vqQAKVDvSqIiqFnlo0=
X-Received: by 2002:a50:cdd0:: with SMTP id h16mr51244883edj.151.1546709229113;
        Sat, 05 Jan 2019 09:27:09 -0800 (PST)
X-Google-Smtp-Source: AFSGD/VGfy4tWzY2OOwdjU8FGMgLB/ltTX0/v1vpKF2n2GrVET4wogAzL8lfHYRPRoulxBd0OkPe
X-Received: by 2002:a50:cdd0:: with SMTP id h16mr51244829edj.151.1546709227944;
        Sat, 05 Jan 2019 09:27:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546709227; cv=none;
        d=google.com; s=arc-20160816;
        b=GSvvk45YRXuFTa5thoqZl4l30UII1LEAd4PKwL86QxxKK8p/mbLwFE59hVjRI1Robv
         /f2QX1loE0Z5JmM5eZtHNBsfLgaD26V1XVFXLI6kGVFpUMgAngbi00JISa0TLr5lD52U
         Cab6j7VLvhceyyYBkzhUxMBdcpDzzFw1HtoX9CChHZvYFlo6onCm7IfTFcd0+oaRejF7
         G/d+Q5HD7Idque9dV7LbpWf3Ad5aEdfXXdlB1AAESURzOLs3aQqNAfyVGa+9OWLJ7vce
         Q+7HfLNHUT84QSWdotpRPvk3HS8nLTb2K+Sk2s9EaPHh3heo8QEuwrPUZsKwmU4kXp3s
         Q97Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:subject:cc:to:from:date;
        bh=rbh7SbMsDzLW85qhFs/JA9KR+911TMgBdFkozzVBbtQ=;
        b=DJ/OpPH4y+9jgAatsHloDgAXm3MGPtMN7YUl4QIL6+OULQMIc1WKF1yBPCJ7GrLl/a
         iKGAJmXTABh2lKJX01qffOdwmlatuYPFz9GqLHDhfn6i+4kCFsj4TouZiDj0IJ/CfDaz
         W1JOfvRLjdAPWIrYiiVqSAuBCkMupe6h9uVLFw94ybjdn0d0rWiw/j4aOaMnjOr9antW
         d0PoSrXKtkny8k/cMWZgazepTMugkK5ZMquI+6KTbt88hwQwIzFHVbTgP/+W/039wLzP
         UdVAG9l6/bltQq86WbBQJEnHmRmGnmBXjHdKS1ib5yQX072+UCSUnE0rp9wVjl+TVtGc
         kTTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z17-v6si1333488ejg.14.2019.01.05.09.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 09:27:07 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 24DAFAF09;
	Sat,  5 Jan 2019 17:27:07 +0000 (UTC)
Date: Sat, 5 Jan 2019 18:27:05 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>
cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    linux-api@vger.kernel.org
Subject: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105172705.jxdz--rnXBZQNTsl0CJzHldLtsVI3hh_CydIwytVhMk@z>

From: Jiri Kosina <jkosina@suse.cz>

There are possibilities [1] how mincore() could be used as a converyor of 
a sidechannel information about pagecache metadata.

Provide vm.mincore_privileged sysctl, which makes it possible to mincore() 
start returning -EPERM in case it's invoked by a process lacking 
CAP_SYS_ADMIN.

The default behavior stays "mincore() can be used by anybody" in order to 
be conservative with respect to userspace behavior.

[1] https://www.theregister.co.uk/2019/01/05/boffins_beat_page_cache/

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 Documentation/sysctl/vm.txt | 9 +++++++++
 kernel/sysctl.c             | 8 ++++++++
 mm/mincore.c                | 5 +++++
 3 files changed, 22 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 187ce4f599a2..afb8635e925e 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -41,6 +41,7 @@ Currently, these files are in /proc/sys/vm:
 - min_free_kbytes
 - min_slab_ratio
 - min_unmapped_ratio
+- mincore_privileged
 - mmap_min_addr
 - mmap_rnd_bits
 - mmap_rnd_compat_bits
@@ -485,6 +486,14 @@ files and similar are considered.
 The default is 1 percent.
 
 ==============================================================
+mincore_privileged:
+
+mincore() could be potentially used to mount a side-channel attack against
+pagecache metadata. This sysctl provides system administrators means to
+make it available only to processess that own CAP_SYS_ADMIN capability.
+
+The default is 0, which means mincore() can be used without restrictions.
+==============================================================
 
 mmap_min_addr
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 1825f712e73b..f03cb07c8dd4 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -114,6 +114,7 @@ extern unsigned int sysctl_nr_open_min, sysctl_nr_open_max;
 #ifndef CONFIG_MMU
 extern int sysctl_nr_trim_pages;
 #endif
+extern int sysctl_mincore_privileged;
 
 /* Constants used for minimum and  maximum */
 #ifdef CONFIG_LOCKUP_DETECTOR
@@ -1684,6 +1685,13 @@ static struct ctl_table vm_table[] = {
 		.extra2		= (void *)&mmap_rnd_compat_bits_max,
 	},
 #endif
+	{
+		.procname	= "mincore_privileged",
+		.data		= &sysctl_mincore_privileged,
+		.maxlen		= sizeof(sysctl_mincore_privileged),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
diff --git a/mm/mincore.c b/mm/mincore.c
index 218099b5ed31..77d4928cdfaa 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -21,6 +21,8 @@
 #include <linux/uaccess.h>
 #include <asm/pgtable.h>
 
+int sysctl_mincore_privileged;
+
 static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
 			unsigned long end, struct mm_walk *walk)
 {
@@ -228,6 +230,9 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	unsigned long pages;
 	unsigned char *tmp;
 
+	if (sysctl_mincore_privileged && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
 	/* Check the start address: needs to be page-aligned.. */
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
-- 
Jiri Kosina
SUSE Labs

