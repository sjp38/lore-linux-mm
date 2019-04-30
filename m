Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C8DDC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 08:19:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9BC421670
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 08:19:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9BC421670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E85806B000C; Tue, 30 Apr 2019 04:19:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DED8C6B000D; Tue, 30 Apr 2019 04:19:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7A006B000E; Tue, 30 Apr 2019 04:19:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5715B6B000C
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 04:19:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n52so2622007edd.2
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 01:19:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ERxQzSRXhs37aXd6I3tui7KO633dxHDTInCcOE2dV9U=;
        b=K/MXJXCmZj6G2yzSVU+wBUtWUhQP1cjHgtNI2ySqEtYNUo7bZ3qBsEN4zNrYpt4u1L
         MTzLI01dl11S980LYsUsZVdfmlPB1TTto6kaFsqCQotjQJGzeP8pJ8UOyMhCqmldrbyD
         OTCJBwgjEuh2fpc5RRWVSo/mX90ito3677sDtZaOHgvtCNLerubeGuvyahaNxucw5vCD
         PRMag2JSAoBt/aLqub6dydQyHJwx+x0XVBX5pRc6M4ZRdrOCprUwBJjLmdoHiD4+DFde
         oOuuuwyw52BxeWc/alvPbRbB0JKTBEEYsuLfENhcoQLhyNjJaA4RwkWf+MCrP4CW+Z17
         Ms4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAVIH6CKCPugDhmzBk/qHdvaF49E7IsDcBR/T46cS3K6Cn4dL1cm
	9bSkpuR3l3FqNpThWNh0gLOxd0UfhyiaUMowpdEzabJavKWfNbWILEPX2NvYymYHJJe7c76z2br
	tQD2c3CyRhkN8WyEi3OUNo2N3ps5fUikwO7a94OQxr4WeVfNodar7t/sPYt4gG0DaJQ==
X-Received: by 2002:a50:b103:: with SMTP id k3mr40994154edd.176.1556612372957;
        Tue, 30 Apr 2019 01:19:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfK2g0EDGE6pz78/05eQuxtJEc+F/A7di/cvEXyyqboFUCTWrvxDL0qtVsc6F9tHc5UJS/
X-Received: by 2002:a50:b103:: with SMTP id k3mr40994113edd.176.1556612372039;
        Tue, 30 Apr 2019 01:19:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556612372; cv=none;
        d=google.com; s=arc-20160816;
        b=GSiq2rqSGYzqSgaEsMTHhyQVn5xfjwfCI4WtQN1HbswQ4xof1KlsgTiFvAJjrwulBH
         Kfu/CRPwmzceP0MWyiFBQgeB5qK5rhB/DjbvjZEUa1M46h1MjtGwsz/NYL7HNcv7E+fn
         blUNBAD/d70YfzNFYM2qrdMGlY9zBlpdQlAf5fUmdv36HhQHOrRQTElI+sy3cFcKAEVC
         KmdXGdpdjRcqufz0PHClFOn4HVNkmjcq7zDFWwHg5DzFtwlCGUh+yXkO2jRn/6sGCUJ4
         0qLONvaIkOozDTnQQqfBz7hEUzqy8aOqpyULx/MsycNtWi8z5R46uo4PSPyHOLdPIC63
         IUcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ERxQzSRXhs37aXd6I3tui7KO633dxHDTInCcOE2dV9U=;
        b=Se/sF9mdPl4jazBQAZOk9LZH1vQ31Lg9zWPqLPSg4belROm4jDJNNa873luJz48YvT
         hmb98mhiaBQssUzmE5iSizPa32Ihj3k4/LK9X6fw70Ev8Dpjf2j90IYXoUzaW2CfhAZo
         hfCVJldhV+ODy2qmLnkGsJVWQLNoFhOyIW+MPpk2T77wAbFGZU0qHv63Jkn3T6w9Ry9c
         MnkbDLJM0amkS9Uy0bauYTXzw059Mo+dIK0reENFkXEDdHzrDgB5ZgnGB2qElmYTYddI
         YjFh19flI/3FMuelvhj6Hn8+ssocTTBd2UINrWoJezVK2bMcsPBNHE4Vn/1xSmWHYI4Q
         6cfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s2si4869058ejh.347.2019.04.30.01.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 01:19:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A3F04AE4F;
	Tue, 30 Apr 2019 08:19:31 +0000 (UTC)
From: =?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>
To: gorcunov@gmail.com
Cc: akpm@linux-foundation.org,
	arunks@codeaurora.org,
	brgl@bgdev.pl,
	geert+renesas@glider.be,
	ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	mguzik@redhat.com,
	mhocko@kernel.org,
	mkoutny@suse.com,
	rppt@linux.ibm.com,
	vbabka@suse.cz,
	ktkhai@virtuozzo.com
Subject: [PATCH 3/3] prctl_set_mm: downgrade mmap_sem to read lock
Date: Tue, 30 Apr 2019 10:18:44 +0200
Message-Id: <20190430081844.22597-4-mkoutny@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190430081844.22597-1-mkoutny@suse.com>
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit 88aa7cc688d4 ("mm: introduce arg_lock to protect
arg_start|end and env_start|end in mm_struct") we use arg_lock for
boundaries modifications. Synchronize prctl_set_mm with this lock and
keep mmap_sem for reading only (analogous to what we already do in
prctl_set_mm_map).

v2: call find_vma without arg_lock held

CC: Cyrill Gorcunov <gorcunov@gmail.com>
CC: Laurent Dufour <ldufour@linux.ibm.com>
Signed-off-by: Michal Koutný <mkoutny@suse.com>
---
 kernel/sys.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index e1acb444d7b0..641fda756575 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2123,9 +2123,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = -EINVAL;
 
-	down_write(&mm->mmap_sem);
+	/*
+	 * arg_lock protects concurent updates of arg boundaries, we need mmap_sem for
+	 * a) concurrent sys_brk, b) finding VMA for addr validation.
+	 */
+	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, addr);
 
+	spin_lock(&mm->arg_lock);
 	prctl_map.start_code	= mm->start_code;
 	prctl_map.end_code	= mm->end_code;
 	prctl_map.start_data	= mm->start_data;
@@ -2213,7 +2218,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = 0;
 out:
-	up_write(&mm->mmap_sem);
+	spin_unlock(&mm->arg_lock);
+	up_read(&mm->mmap_sem);
 	return error;
 }
 
-- 
2.16.4

