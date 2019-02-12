Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA280C4151A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:01:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADC4B21773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:01:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADC4B21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 538178E01AD; Mon, 11 Feb 2019 22:01:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C13A8E000E; Mon, 11 Feb 2019 22:01:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B0F58E01AD; Mon, 11 Feb 2019 22:01:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3F58E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:01:04 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id n197so14471630qke.0
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:01:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=QzUweX58NX5kJXc37B6qWAgrFGIP75kjzpaY8e9hvrs=;
        b=WLM46c8xDEMDP4z+hXdAJYRz3QIZl73wJ2djcLSWi+i3+7onh8KMXERKDdqp7lVuaE
         67aqzrj6cfflBMOSbATVva/YSEiRgRzFvSi+GumEM116KJV6L9l0lVkxlBctlQDaFV9r
         IupIttqV63WHZaUVen2KGqFVWS46qNioWKUWz73mAlCt7lz92d8S2rT4TjKp4WtnaPoi
         vcrlv8NlbUWepiyvhPL+xca1VxfIWDsTK0t8V/FP8wbjzPBY4I0IQ+4MEe0AxBv4DZpE
         btkXHvU+g74WIlP3lG8CkV3GyDlvgavauirhDuM5HWaiRJ5lloZjzVsJoXY899yWLpZp
         +qqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYIPLpFWcpWmJ4/YsZTBl9vCxr7Wd2oa9yFHKWkvpinhMuHecnS
	LA74iBcJAU4kjUJXYKRsoc7fOWOw0MuJOVmkCiXHFW8Q2NcviV5i2jeL6NV19QUek6WcdtjsQ/D
	j8ZWcOWyTdwncbCU4SHSgDTqJfHO9Gxmrr7cMQS3ieZA6aGrr/5S2e4xE0K1n4LO2tA==
X-Received: by 2002:ac8:38fc:: with SMTP id g57mr1132046qtc.39.1549940463843;
        Mon, 11 Feb 2019 19:01:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibd+IHqmyASF+XMC+Aa4DDbgmsircmKAufpClZfQ9kgZsMJfQk5nCLlVh93xVPiQCkqSipr
X-Received: by 2002:ac8:38fc:: with SMTP id g57mr1132029qtc.39.1549940463371;
        Mon, 11 Feb 2019 19:01:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940463; cv=none;
        d=google.com; s=arc-20160816;
        b=szPLU93VdxmrLSwLGdnCiBOZoUKxqlTdioKUpHzsXFEeeJow3L3T+8np6ulBppD/s9
         lY54u/jd63dep8av+elyzSE66d43ZUEZyMXHkIUv1XVkdaljqVcMxEUdhx2roo6/QKM+
         J6Rrlig4VuSICYab8IfDl6hnq+cRfWoEzAgE6KBzW1Aw/HzcaPWRQDoTEyy7Gb/lbVwN
         /SeUzfpVGy62jWifXKooIyzbrphwOKnJZ0L3C7oeOslGBWaOvNNaMP3qzUvLtNcawo61
         2A7TVcGUfhV30OOAE1qAKHC54XXN8ZKV5H1qpNcnOQWyxp5Jtq2C1k29JAQpPrR8FeC9
         uLZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=QzUweX58NX5kJXc37B6qWAgrFGIP75kjzpaY8e9hvrs=;
        b=zFYxQsNfMlFUKH3I3z3qVSC2zIJA5wU0TH7F0lpKZb+JRTlkBz2VPRZWn4kswG2CY+
         GAIjDpoKC2qJVL+Y532HhSQLsWh8z0CZlSApm82BZJVVVhts/1SlkUIeC9vhW5eoXM3A
         x1qb2e9AP7Lm0wE5Px9TRRgwufQCwK1Rhx0oQ8pxefT7vyeFuuPgiMBj6TfKVyX2usXv
         vfjsY6zFvV8/Y+ABLaE1q5CQtOT2ptxo/yE1Abad33y1fg+axN0t4L0r9/xcwh2xuTyj
         JCFMRsdhfinM4/8C0500GBb/d28TIuwhOw84ODCZMCbwez5qjBY11tCAl0Fm0GG9/2kN
         6XRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i66si1483545qkc.207.2019.02.11.19.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 19:01:03 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 585908762F;
	Tue, 12 Feb 2019 03:01:02 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 94BE7600C6;
	Tue, 12 Feb 2019 03:00:53 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v2 23/26] userfaultfd: wp: don't wake up when doing write protect
Date: Tue, 12 Feb 2019 10:56:29 +0800
Message-Id: <20190212025632.28946-24-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 12 Feb 2019 03:01:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It does not make sense to try to wake up any waiting thread when we're
write-protecting a memory region.  Only wake up when resolving a write
protected page fault.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 81962d62520c..f1f61a0278c2 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1771,6 +1771,7 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
 	struct uffdio_writeprotect uffdio_wp;
 	struct uffdio_writeprotect __user *user_uffdio_wp;
 	struct userfaultfd_wake_range range;
+	bool mode_wp, mode_dontwake;
 
 	if (READ_ONCE(ctx->mmap_changing))
 		return -EAGAIN;
@@ -1789,18 +1790,20 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
 	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
 			       UFFDIO_WRITEPROTECT_MODE_WP))
 		return -EINVAL;
-	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
-	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
+
+	mode_wp = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP;
+	mode_dontwake = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE;
+
+	if (mode_wp && mode_dontwake)
 		return -EINVAL;
 
 	ret = mwriteprotect_range(ctx->mm, uffdio_wp.range.start,
-				  uffdio_wp.range.len, uffdio_wp.mode &
-				  UFFDIO_WRITEPROTECT_MODE_WP,
+				  uffdio_wp.range.len, mode_wp,
 				  &ctx->mmap_changing);
 	if (ret)
 		return ret;
 
-	if (!(uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE)) {
+	if (!mode_wp && !mode_dontwake) {
 		range.start = uffdio_wp.range.start;
 		range.len = uffdio_wp.range.len;
 		wake_userfault(ctx, &range);
-- 
2.17.1

