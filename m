Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00410C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B079C227B9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="H4TiQUgR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B079C227B9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62DC28E000E; Tue, 23 Jul 2019 13:59:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B8338E0002; Tue, 23 Jul 2019 13:59:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47ECD8E000E; Tue, 23 Jul 2019 13:59:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27AE08E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:30 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h47so39125442qtc.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=SnCe+Mtnf/4IPVX5vctz2kNHbLvxo+cXn+T1BQBMjSY=;
        b=d5sM4lFsBv+8K/X2jIQnR0t130sOVd+z3MY8E1zaENsuh3cQ1khD5gKsVPvfdvhPJB
         dTd5mIySSZxcczSHyTXhxWPg4lT9iqlSiC01Fc8s3fJGi0KL0vFe/3wRKu5nWbF6TTRk
         ddo43zxoPkdPSA7NToA5zf3V8s9r3QCsHti1QHNsUsWI2wLnMf1d9XkIo2xfYDBGPuVU
         tRlt/T/2TkNA5NK12wfeyb9LQb9zAgmj85CdczTMM/08VMCtbkFojv0EFVqOlKTJd1P8
         /FL3tP58wFTOzps5bA5c7XwwtPJYq/n6wE0pTJH8CvLYY4b+K+d+WBPpoxpNbm6bq5Fa
         cEOQ==
X-Gm-Message-State: APjAAAUETVtLzGyRifMJcgm93uZx+LuWYZy2gDeP2GCGWWcy8gAn/G3M
	ivdJ9LyTLWrMUzBQGLz6O3jt4aMwquK7Ds+imFrFsGqLaEiXnREIjmqN9QaA92bKhQmqNSP6LYX
	8IeGVRVL5r8cN3T6XeiRKnlPZ6QWTndEyyc6SuJVGPvNopS2Jggyt5Wu3Gb/zyskXCA==
X-Received: by 2002:a0c:acab:: with SMTP id m40mr56671319qvc.52.1563904769962;
        Tue, 23 Jul 2019 10:59:29 -0700 (PDT)
X-Received: by 2002:a0c:acab:: with SMTP id m40mr56671310qvc.52.1563904769405;
        Tue, 23 Jul 2019 10:59:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904769; cv=none;
        d=google.com; s=arc-20160816;
        b=AOqQUs3JR2STxdo4lXrm4PlyAAjkZD2v+eJ3DA+u+lieWmFPFBjiZ+pHUj/roixUCU
         3CRe3a6gocZpijHM/EQaNWmYUPbDC7xpbju3UTK1HuRKLk96UE5DqefyqCc+cbMgV3Gv
         5l143WsI+ez5jJ5Cg8spkzG8mBC1qlHEgmnzqhXy3od8fLbf9tYitMuM4teJ0n0vj6OA
         nZKG7VRJsG6vFY7AIgLwIqFFTaSRB8OYp/wD0RV7mLeNJtDMn294Bx5tptERlHukTt89
         rtR/rFGGXdydsLhiGg5rYaHi8HaQQG5WJ0xCOZic2xVq9JQhgwMn997Y0i6oh6LV2pqg
         +HQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=SnCe+Mtnf/4IPVX5vctz2kNHbLvxo+cXn+T1BQBMjSY=;
        b=0tk820CNnGdb7/T4JJ4Kb1ACTJbFuXH7YpLDp2+Jtm3wdO0NAZ85DgHxSPnP3bvAd7
         13xLpuMN0H5WvC4c8W5rfEgHyflejiojCsBQRmuIV9YWSSQ+/86PgvW3ooc9MUV5b+t0
         kQrP3cd3uTi8hVdw6gams1798SoqsCEbTLzaZkMqvqV7SHST4rmrIW4RY/p0rYQZPiL3
         kPjHbb7Tt3m/Q8CqVrc3OI6VU+CG2vIByfjKHFtldHpv3xFzsxRpEGTfUQtmKeP9hIUJ
         xa/G11mAKDUkSbFoYh8040uO3MN62IeJ18KUHK2IYF3iO6WhjIp9cuomkqtR8lO1d/wl
         mdYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=H4TiQUgR;
       spf=pass (google.com: domain of 3aes3xqokcgmboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3AEs3XQoKCGMBOESFZLOWMHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d14sor58030730qtq.31.2019.07.23.10.59.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3aes3xqokcgmboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=H4TiQUgR;
       spf=pass (google.com: domain of 3aes3xqokcgmboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3AEs3XQoKCGMBOESFZLOWMHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=SnCe+Mtnf/4IPVX5vctz2kNHbLvxo+cXn+T1BQBMjSY=;
        b=H4TiQUgRdi4EHpYB8nTtg37yn9l3JyAu6VKcW2CQCTgny+vzJbtQEYhMy5VYJWq/CI
         KrIVgxdlW5aj4Az2DGaszv74HRn6o+lrlFDsTrBfmff9rY/9V5Ds2Mgw7VHb0yVnzniX
         zHDvZt7zGQFLcaS9bQ85+7iz8VxXg9au1eNOrVwptdD22wpczsG2wyPaMM6iHM1fn6oB
         qEapo2f+2AfPvvpteYPs6gKu7O45lNfI0gMeElG1uz04IPRB0pwyBE+bIPD+sqfvkwBv
         pd2Qci5+NW7JO2WHQGIVKZzYhqd9oRhn7n0TTqLXoH+DCmlggKEuaPlzaJC7NBCKpdOt
         X82Q==
X-Google-Smtp-Source: APXvYqysiVBCmSbfWLll2amFKEEXBGqGWfbcKcVshytrTMG9pLoartROQI2FKjRVOxEkpepSHwC8IxHzKKAn6one
X-Received: by 2002:ac8:66ce:: with SMTP id m14mr12433817qtp.206.1563904768802;
 Tue, 23 Jul 2019 10:59:28 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:44 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <1de225e4a54204bfd7f25dac2635e31aa4aa1d90.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 07/15] fs/namespace: untag user pointers in copy_mount_options
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

In copy_mount_options a user address is being subtracted from TASK_SIZE.
If the address is lower than TASK_SIZE, the size is calculated to not
allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
However if the address is tagged, then the size will be calculated
incorrectly.

Untag the address before subtracting.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 6464ea4acba9..b32eb26af8bf 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2994,7 +2994,7 @@ void *copy_mount_options(const void __user * data)
 	 * the remainder of the page.
 	 */
 	/* copy_from_user cannot cross TASK_SIZE ! */
-	size = TASK_SIZE - (unsigned long)data;
+	size = TASK_SIZE - (unsigned long)untagged_addr(data);
 	if (size > PAGE_SIZE)
 		size = PAGE_SIZE;
 
-- 
2.22.0.709.g102302147b-goog

