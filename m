Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3166BC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAE6520851
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XG5I+EPz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAE6520851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 782506B026C; Sun, 19 May 2019 23:53:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7358C6B026E; Sun, 19 May 2019 23:53:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AF1D6B026F; Sun, 19 May 2019 23:53:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7906B026C
	for <linux-mm@kvack.org>; Sun, 19 May 2019 23:53:37 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 5so9024891pff.11
        for <linux-mm@kvack.org>; Sun, 19 May 2019 20:53:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6eom6C+0aXRglfnsINAswRs1OeG+39R7hMy87CNGrDQ=;
        b=stDfthoz24x7Y2CNv7XaVcyIVutDRMcgTOMdU8ehTW8si4nuphNc5NuIegUepoa50R
         qOiI9EpfkN7su81DANMX4WW53qmsVPFjsMANoVOeUQ6ACERu88N9bCZULd7P1ug+1G+F
         IiWYDh0cejkDEcEmH/5zb+peCysjgKCfr0/SFZMBm4nQWsM/lUb1Gijv8XugntuG5XLE
         jBmEdb/umb0QmNVRe/TIGb4JsBU0HpxldYHOd7m1JpqP42+aBhp8Pvp3Sj+ZTLpwEN74
         DdK3sYoko/+aUzfLYy3DdiND0Sm/rJ0ll0gskTkL45NL9PinaeN5h53qbHbAWHwrJYjj
         +OXQ==
X-Gm-Message-State: APjAAAWHvU+HJFLjLusvvRyyLbP+n+1FKgYDuXgujrapNSboLtCeQ0Gi
	xom2wlEkJf1tIz8sRAJU5/ZzH+HHlpuQNaJ4YFnar5X1NNKQr0Zc3ih/eiu7OpXloQoe7dhg0vT
	az/3xiXAlS1s3Pj8fl44uXMlhZIgHyRCURqJcrzK33e4k9M9mqLYC+fl50bgQVcg=
X-Received: by 2002:a17:902:322:: with SMTP id 31mr60577216pld.204.1558324416781;
        Sun, 19 May 2019 20:53:36 -0700 (PDT)
X-Received: by 2002:a17:902:322:: with SMTP id 31mr60577172pld.204.1558324416005;
        Sun, 19 May 2019 20:53:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558324416; cv=none;
        d=google.com; s=arc-20160816;
        b=cvTR1NN7lr6I9GC6+koE5HYcwF3DZLuD+Fxs2BWajJtphPyEV4LNYrRSG8pLmVP4L/
         jQQEC5k+GSeFpHC7Vz2RaWMN8qfXeCaVOokMDRJXRUnaG5ccp/5Qc5Q9SE29G5TA4JBd
         MA72vlc8cGH5VgecoKOCTOj0rYa8O7fUDdTzYiA0odyiB6TSXTbxDCEWvD+BWZe/a9f0
         h4sEKZkoDYojmBL2N8TZGqC61bFUSrfQqgHyut9FqVfcy2ZDCp7HnyXSE9hWRenfyAi8
         PwO4in7ZjKiJoEg85L/YsRD1TxGstJmtqWuBQ/526PtLxrVtLNH7+hmrRxqCETCaH8Ka
         62UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=6eom6C+0aXRglfnsINAswRs1OeG+39R7hMy87CNGrDQ=;
        b=LGwSNBY6mRsJs0eUHQ7QvJi6EaZYTWQy9s5UdgCpvUNlZrqFV262ZiebrL8Wi+ts5t
         IobqfxFtDKsOtHOzsfsx0AOEoFF3Q+VgJWxyK8wrslBEnWALqDJN/idOBHoz5x/MbgaM
         6HxWvlge/BNiBuuPsSUDdeYu693ZZ7rshvZufi9II8tbtdZoxXunSRLo5pDZhBp8xxfk
         hR+PmwtegBoC9GKDR7kibVwhbtGYLZsszBnfJSSl2tzY/iKF6frSFQlfy6kJlGTWirJL
         /NxqhNmMHcJoF8J0eRxif7Tf0eiRIBNu3aLfOcwFd5ec1RdnkETevm5Ts7WyGku/LXuj
         6QZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XG5I+EPz;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o10sor17778945pll.35.2019.05.19.20.53.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 May 2019 20:53:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XG5I+EPz;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6eom6C+0aXRglfnsINAswRs1OeG+39R7hMy87CNGrDQ=;
        b=XG5I+EPz86QA3OhsQLafnFpAan9eaChflXFWy43qaxMLemrkVaXoKjqy7PxZqkUxkP
         O0Pi6kyy6arJRnGcyGSp5wdYWbuXmnvmMU9TLW9lQqedL13pwu5ot2YxbHHnH5JDECz2
         5s7ZSy68dQ3tlt3cl5NMx33/pwti9RfeGoJWKiUEMCQZqpnPep50Djr8xxL6STY36Ujw
         beVq6BNhkOiPzbrCyDh5fI53flkYcWi5NjAVWwKl/1j+lPu5r1E1UxZcQv/nYdEAVufF
         I5AElncQaFNYUw4EOAGcoZbjZ6MvPKbdF3qRi76J+cqbdAOTOvWbZZqXTrDpaKJYoBkJ
         Nunw==
X-Google-Smtp-Source: APXvYqzawjhmQskMTjHPygEFAgYiL4Q/o65j0xjkMqI2OU3MhBsEo2mDN7heff7G2XFlEjOFBY9bKg==
X-Received: by 2002:a17:902:bc42:: with SMTP id t2mr21860026plz.55.1558324415659;
        Sun, 19 May 2019 20:53:35 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x66sm3312779pfx.139.2019.05.19.20.53.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 20:53:34 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER
Date: Mon, 20 May 2019 12:52:54 +0900
Message-Id: <20190520035254.57579-8-minchan@kernel.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
References: <20190520035254.57579-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

System could have much faster swap device like zRAM. In that case, swapping
is extremely cheaper than file-IO on the low-end storage.
In this configuration, userspace could handle different strategy for each
kinds of vma. IOW, they want to reclaim anonymous pages by MADV_COLD
while it keeps file-backed pages in inactive LRU by MADV_COOL because
file IO is more expensive in this case so want to keep them in memory
until memory pressure happens.

To support such strategy easier, this patch introduces
MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER options in madvise(2) like
that /proc/<pid>/clear_refs already has supported same filters.
They are filters could be Ored with other existing hints using top two bits
of (int behavior).

Once either of them is set, the hint could affect only the interested vma
either anonymous or file-backed.

With that, user could call a process_madvise syscall simply with a entire
range(0x0 - 0xFFFFFFFFFFFFFFFF) but either of MADV_ANONYMOUS_FILTER and
MADV_FILE_FILTER so there is no need to call the syscall range by range.

* from v1r2
  * use consistent check with clear_refs to identify anon/file vma - surenb

* from v1r1
  * use naming "filter" for new madvise option - dancol

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/uapi/asm-generic/mman-common.h |  5 +++++
 mm/madvise.c                           | 14 ++++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index b8e230de84a6..be59a1b90284 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -66,6 +66,11 @@
 #define MADV_WIPEONFORK 18		/* Zero memory on fork, child only */
 #define MADV_KEEPONFORK 19		/* Undo MADV_WIPEONFORK */
 
+#define MADV_BEHAVIOR_MASK (~(MADV_ANONYMOUS_FILTER|MADV_FILE_FILTER))
+
+#define MADV_ANONYMOUS_FILTER	(1<<31)	/* works for only anonymous vma */
+#define MADV_FILE_FILTER	(1<<30)	/* works for only file-backed vma */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
diff --git a/mm/madvise.c b/mm/madvise.c
index f4f569dac2bd..116131243540 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -1002,7 +1002,15 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
 	int write;
 	size_t len;
 	struct blk_plug plug;
+	bool anon_only, file_only;
 
+	anon_only = behavior & MADV_ANONYMOUS_FILTER;
+	file_only = behavior & MADV_FILE_FILTER;
+
+	if (anon_only && file_only)
+		return error;
+
+	behavior = behavior & MADV_BEHAVIOR_MASK;
 	if (!madvise_behavior_valid(behavior))
 		return error;
 
@@ -1067,12 +1075,18 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
 		if (end < tmp)
 			tmp = end;
 
+		if (anon_only && vma->vm_file)
+			goto next;
+		if (file_only && !vma->vm_file)
+			goto next;
+
 		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
 		error = madvise_vma(tsk, vma, &prev, start, tmp,
 					behavior, &pages);
 		if (error)
 			goto out;
 		*nr_pages += pages;
+next:
 		start = tmp;
 		if (prev && start < prev->vm_end)
 			start = prev->vm_end;
-- 
2.21.0.1020.gf2820cf01a-goog

