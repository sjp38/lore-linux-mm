Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2955EC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBCEA206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBCEA206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 891878E000A; Wed,  6 Mar 2019 10:51:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8186D8E0009; Wed,  6 Mar 2019 10:51:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7308C8E000A; Wed,  6 Mar 2019 10:51:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2C18E0009
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:12 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k37so11920304qtb.20
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id;
        bh=gVh63R6jXWGvfH8lhiTdxs5SO95iMTODRGtrqioWTbU=;
        b=dqlS3WGnloFk4OP/w7xdo5iC0LO/LEMKOqxC5LlP0oUflRxuc+t1bLqsnmcA6jAbYg
         fM/CBd7bTJm3h1gABsTKZGCZXWnmgDAoAiQQHktPehGAhSbWDWlUAinU78BLCJro2o7X
         3RY34dmKY5aPtDvlK428gyWvN0WCV+PEJGYn6fcq7wnmRiiw8Laqdl4WY7Q0rgddZ8jx
         hYm6nwnfPWK4JaiVKPrPuHSoZxNvTQvJYHD4KD5O1bjL/EjgC54NM7uZIIuZUIleJsFH
         RkLsGjSN4hMKFPAae8x2JyOeORKvlyJUDcTsutFbSCbbuov6bDrLjTAbndAhrHGo3kEn
         iyLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVRnk8tEMi362FtMOHXzJrWLpG9fWf1tqsUqlJNtM7BSQ4eQafi
	PRBVUmOzmOn/LItqoxQuRYpxFcumdqGUNLe4M3hdhL7PCQk977HpD4PkdXtuab5F500I3fNfCzz
	Iu9Y4LwIR2MMIXfRiSf7xtsvcYmIrt4aiGAnILoRGn60QWc1wF/B21h6bSVqpcDOSMg==
X-Received: by 2002:a37:aa17:: with SMTP id t23mr6163020qke.133.1551887471986;
        Wed, 06 Mar 2019 07:51:11 -0800 (PST)
X-Google-Smtp-Source: APXvYqxmi/h0tYgD+2I43uoj85dhr6nh/L6xkuL3/bdIbrNQX6DZO0wCf3E/I/AccOR6VA+L6pmh
X-Received: by 2002:a37:aa17:: with SMTP id t23mr6162955qke.133.1551887470681;
        Wed, 06 Mar 2019 07:51:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887470; cv=none;
        d=google.com; s=arc-20160816;
        b=vMJ9RAvQi77PFMXn86q6wNzcmUPcs9MYAgHl4wdJRBiE18pcZu/cLXvNRYY5ISUZNR
         vjywerBBz/GRkENQl1a/Gxr20C30VP+gLhuxgqgh6CFEl2FSNKUT+yl93kpgoacO2XnM
         Q7zsLhVBvIzyq9kvr2TeTD+u20+yww4RROGTGgA824Tsnpy2PSJsZzqCyA8ttewxthkg
         RE7RIM6zytyHQSAecIUkATAiHT2Hn0N7/XTd2z0lzpQvmSiY/1IhczdLkqMxnlcJOLC9
         yk7F1wD9va7rLt7aUelvD74AUmChTdngz7rD0DHdIY7bqUinvGQu/5YDuh4ARNkmUN8B
         Zxww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:to:from;
        bh=gVh63R6jXWGvfH8lhiTdxs5SO95iMTODRGtrqioWTbU=;
        b=uIOoTfyO/n68EuTqwLxu+URjPS7S7ZttGfNhUT8c5wsco/ydb+jxao8sjELRkCalt5
         hnsnOCeL+0RfLBKgiZjyclqv2Ww/t6tXSKcwL+A4RFceuLrREHoI85urOHLEYFBiEHY4
         dt4/hrPV9EaLEDkNmUnuqE8NIYoQTWvV4fQwzA1g50wKDU2uyvjhlk5Gl309yOS5n+aN
         whcwzKNt7m9gGCW0No6hpW2YWvkYeTctJPSSpKn7QFFk3vAvSUvTu5fSCkou/8Ir7til
         W81sOpbkU5oNJydmbPYo9FkrLE/NzN0m6akBAoZ52PC6j0HQh2s6M91H3yA2jNhFb7oR
         UsHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h19si47042qkg.18.2019.03.06.07.51.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 07:51:10 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B703181E16;
	Wed,  6 Mar 2019 15:51:09 +0000 (UTC)
Received: from virtlab420.virt.lab.eng.bos.redhat.com (virtlab420.virt.lab.eng.bos.redhat.com [10.19.152.148])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5FFB51001DF0;
	Wed,  6 Mar 2019 15:50:55 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	pbonzini@redhat.com,
	lcapitulino@redhat.com,
	pagupta@redhat.com,
	wei.w.wang@intel.com,
	yang.zhang.wz@gmail.com,
	riel@surriel.com,
	david@redhat.com,
	mst@redhat.com,
	dodgen@google.com,
	konrad.wilk@oracle.com,
	dhildenb@redhat.com,
	aarcange@redhat.com,
	alexander.duyck@gmail.com
Subject: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
Date: Wed,  6 Mar 2019 10:50:42 -0500
Message-Id: <20190306155048.12868-1-nitesh@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 06 Mar 2019 15:51:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The following patch-set proposes an efficient mechanism for handing freed memory between the guest and the host. It enables the guests with no page cache to rapidly free and reclaims memory to and from the host respectively.

Benefit:
With this patch-series, in our test-case, executed on a single system and single NUMA node with 15GB memory, we were able to successfully launch 5 guests(each with 5 GB memory) when page hinting was enabled and 3 without it. (Detailed explanation of the test procedure is provided at the bottom under Test - 1).

Changelog in v9:
	* Guest free page hinting hook is now invoked after a page has been merged in the buddy.
        * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(currently defined as MAX_ORDER - 1) are captured.
	* Removed kthread which was earlier used to perform the scanning, isolation & reporting of free pages.
	* Pages, captured in the per cpu array are sorted based on the zone numbers. This is to avoid redundancy of acquiring zone locks.
        * Dynamically allocated space is used to hold the isolated guest free pages.
        * All the pages are reported asynchronously to the host via virtio driver.
        * Pages are returned back to the guest buddy free list only when the host response is received.

Pending items:
        * Make sure that the guest free page hinting's current implementation doesn't break hugepages or device assigned guests.
	* Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side support. (It is currently missing)
        * Compare reporting free pages via vring with vhost.
        * Decide between MADV_DONTNEED and MADV_FREE.
	* Analyze overall performance impact due to guest free page hinting.
	* Come up with proper/traceable error-message/logs.

Tests:
1. Use-case - Number of guests we can launch

	NUMA Nodes = 1 with 15 GB memory
	Guest Memory = 5 GB
	Number of cores in guest = 1
	Workload = test allocation program allocates 4GB memory, touches it via memset and exits.
	Procedure =
	The first guest is launched and once its console is up, the test allocation program is executed with 4 GB memory request (Due to this the guest occupies almost 4-5 GB of memory in the host in a system without page hinting). Once this program exits at that time another guest is launched in the host and the same process is followed. We continue launching the guests until a guest gets killed due to low memory condition in the host.

	Results:
	Without hinting = 3
	With hinting = 5

2. Hackbench
	Guest Memory = 5 GB 
	Number of cores = 4
	Number of tasks		Time with Hinting	Time without Hinting
	4000			19.540			17.818


