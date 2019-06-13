Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 764ABC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:47:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18BD6208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:47:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18BD6208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B17B96B026B; Thu, 13 Jun 2019 06:47:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC7D86B026C; Thu, 13 Jun 2019 06:47:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B8226B026E; Thu, 13 Jun 2019 06:47:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBF56B026B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:47:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a5so20958824edx.12
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:47:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YR8hMv6qqSRLcHR5+nJRHlZJCSYGZ5XT+sBjsdKq79s=;
        b=rtFFS7NX4/4pDj5OZKKKfAY5PtTsX9Y5uKubeWox66cMI9hOgUs19gVDIXhitcIzSm
         Re3QvjyJ4I+jBoMIHt6yIkAxYJdi5xlnqg64oPXtr/bYT7G9d1NzXhp0yIUk+G7HoTkc
         k/kmseHPRnq1FmGIo9HXRiWjtWY2H+xVmyKCW1QH+jIHPNgBsokg3SenxmUDPfncCszy
         EqKGaBptP0ei81FiWc3afniRQB33RjGTIGsGi7n2eyd0cCP7I6As15LDx+rUbwDkGKAn
         isOL/B926lAHXW57JAC9B9ydcf4sQ2dX2KVgMvMORakhMMuLzAbGira4NQtCVfXjc6gO
         kMMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAVyFu2Sr7vHEcdmCkkUSr6c5Q2IJZkx3K2EELu5TAlxlDgbchz7
	/NkaK6Ciw/GMohDgseotBKpYnR0Ll98a4K62+ASuaKRXjqBotgDE/ZFGRxLe+6iuUVVeg/oJj4F
	ke5lA2WJrxtpJ8YVHj9rLUhRoJXhyRr65gnIqxYjC+UqrFf8KkuffpCaBXl6Zv8mKvA==
X-Received: by 2002:a50:94a2:: with SMTP id s31mr53386716eda.290.1560422846883;
        Thu, 13 Jun 2019 03:47:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwy8pm3H3vIi38SSYLLbWLxqQBU5D7VvRgz4vyGGu0ZiLXpJKNekGsEz+uZOy2aj9K/s5bl
X-Received: by 2002:a50:94a2:: with SMTP id s31mr53386638eda.290.1560422846121;
        Thu, 13 Jun 2019 03:47:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560422846; cv=none;
        d=google.com; s=arc-20160816;
        b=rn/9Dc3D6fiUafcG8rigSTXTxpjwzgoq7nruL535jzz30lWi/xtUC2ZxstnePg4x8J
         8KM4rfFW6PLiIPXq04OyGDEXBpHunpjwdcIeT+QtCppXcEA44aIZtkgagmZpNPa5uQPN
         IfQkzQa7UCUXUwS/tXhvIq6aIVbZupaeJ05oBxhpCQ/rrUTFGUZTcAsafRkIenQGiVT1
         niMoD2Pc0tUs6YbswyT7WTRODyowJKGwkMD3s4ti/xqQ3CwL5YyR8t7rY89JAN9nvGG8
         9OjyJgDumdyWndtiesSIMCjrJbjnfIDAkhTYnkwrP1AELBFUlXv1h5ga5cXrniMmPJ1x
         MgvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=YR8hMv6qqSRLcHR5+nJRHlZJCSYGZ5XT+sBjsdKq79s=;
        b=L4i6TBcYS9Gq+jAlR+eINuD9lOUQGJCT4kgJW5ZtdmqrL8WYJ6Ijho9gZNu47kB0LP
         5YjdIT60rcom1IyOZ9Xcx63fIS/QqJahoSdGXONw3x5F4LoQaqnKEQg7DalQTrhxPb6S
         sX5RnSw3wMokVs58blPBjjtTrzcoGbEH8B4MrWdY7MULfzWx28bvU82WC1XTZlUf8/Nc
         n2dmQAEH2M5IE3DSBItmVvZXMd77ITkisCWUfsdMgym7qByMIKA+T3T05nWhZWEVhXMd
         K6BBrlV+4OThhXj883P7lkZRcQGvwJozi23eMM536bxR1qAjrRW4812OZh1NDb0I+l7K
         djpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15si2089884edb.281.2019.06.13.03.47.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 03:47:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8C775AE4B;
	Thu, 13 Jun 2019 10:47:25 +0000 (UTC)
From: =?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>
To: mkoutny@suse.com
Cc: gorcunov@gmail.com,
	ktkhai@virtuozzo.com,
	ldufour@linux.ibm.com,
	Matthew Wilcox <willy@infradead.org>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [RFC PATCH v2] binfmt_elf: Protect mm_struct access with mmap_sem
Date: Thu, 13 Jun 2019 12:47:15 +0200
Message-Id: <20190613104715.22367-1-mkoutny@suse.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190612142811.24894-1-mkoutny@suse.com>
References: <20190612142811.24894-1-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

find_extend_vma assumes the caller holds mmap_sem as a reader (explained
in expand_downwards()). The path when we are extending the stack VMA to
accommodate argv[] pointers happens without the lock.

I was not able to cause an mm_struct corruption but an inserted
BUG_ON(!rwsem_is_locked(&mm->mmap_sem)) in find_extend_vma could be
triggered as

    # <bigfile xargs echo
    xargs: echo: terminated by signal 11

(bigfile needs to have more than RLIMIT_STACK / sizeof(char *) rows)

Other accesses to mm_struct in exec path are protected by mmap_sem, so
conservatively, protect also this one.
Besides that, explain in comments why we omit mm_struct.arg_lock in the
exec(2) path and drop an obsolete comment about removed passed_fileno.

v2: Updated changelog

Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>
Signed-off-by: Michal Koutný <mkoutny@suse.com>
---
 fs/binfmt_elf.c | 10 +++++++++-
 fs/exec.c       |  3 ++-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 8264b468f283..48e169760a9c 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -299,7 +299,11 @@ create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
 	 * Grow the stack manually; some architectures have a limit on how
 	 * far ahead a user-space access may be in order to grow the stack.
 	 */
+	if (down_read_killable(&current->mm->mmap_sem))
+		return -EINTR;
 	vma = find_extend_vma(current->mm, bprm->p);
+	up_read(&current->mm->mmap_sem);
+
 	if (!vma)
 		return -EFAULT;
 
@@ -1123,11 +1127,15 @@ static int load_elf_binary(struct linux_binprm *bprm)
 		goto out;
 #endif /* ARCH_HAS_SETUP_ADDITIONAL_PAGES */
 
+	/*
+	 * Don't take mm->arg_lock. The concurrent change might happen only
+	 * from prctl_set_mm but after de_thread we are certainly alone here.
+	 */
 	retval = create_elf_tables(bprm, &loc->elf_ex,
 			  load_addr, interp_load_addr);
 	if (retval < 0)
 		goto out;
-	/* N.B. passed_fileno might not be initialized? */
+
 	current->mm->end_code = end_code;
 	current->mm->start_code = start_code;
 	current->mm->start_data = start_data;
diff --git a/fs/exec.c b/fs/exec.c
index 89a500bb897a..d5b55c92019a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -212,7 +212,8 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 
 	/*
 	 * We are doing an exec().  'current' is the process
-	 * doing the exec and bprm->mm is the new process's mm.
+	 * doing the exec and bprm->mm is the new process's mm that is not
+	 * shared yet, so no synchronization on mmap_sem.
 	 */
 	ret = get_user_pages_remote(current, bprm->mm, pos, 1, gup_flags,
 			&page, NULL, NULL);
-- 
2.21.0

