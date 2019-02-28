Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95505C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:30:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D3A6218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:30:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="XuAtCfvA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D3A6218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 899038E0003; Thu, 28 Feb 2019 11:30:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 853F38E0004; Thu, 28 Feb 2019 11:30:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73A5E8E0003; Thu, 28 Feb 2019 11:30:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 428578E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:30:43 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id c8so18015478ywa.0
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:30:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=r8ZvTCXRT2zhzdpNdKlPpMAbuU1N2QujZ8hztSmYHqE=;
        b=FlRsxxo7lDTEMfmyUIhwE7cxlIdC7Q8EHnKka0HOSj2W40Vv+MZVjbbB2GA0Xu3ZPQ
         eAPc79U4oZwl90Nxds84rpV+omsoT8ENesw/2SPlpEgFZnLfDub0zmQwGSfpMWpMUUth
         fyBOkrWFSEYGmXSFWL+lauopwla0X1vTLH0tyX8s72VIefEkhXlzPCNbzp5pep3XwP0v
         DqiIVYnpVp7AqaSYkuOcI1QkPpyKIoqyCakpTYHdOHFUHt7gcH6UgGNTeiz7e93NM8t9
         VtNyygNwCD0OBaPEQyS78SHeaz2eCb4ujsTAWxonqULf63vmjvneus1jw7OV3wa2mIxz
         H0zg==
X-Gm-Message-State: AHQUAuYc9XlXX0n1Cj5KMqJ9/aOPGUaOOnejkp8j9CZtNbvKgb96BjV/
	kDcy0nVKtCn2h6P++ufGWDsAioO3+pqIgm6YKUkDW4cO/HubzUmrsXZmhFb7x8w09QMpzsm8/xx
	yiFRHaPqIW1u/RKguIWIkoKc/6qC6vyUvo7xXJ0fcxXCOgJdTQLKXQ/BeUpqsV9XFNxZ9B3gFQP
	sDkXHjwSdRbZwt1qypZtRhv4dd9Pdz2FrqSRSJ8ryOCiJQZq+Hz7mNZhW90O69vlRIX64aQ/fov
	P6Q/Vel+/F1lffS9YNSXPXzGhn61uWf5O/wxSkFJJUXF3DBXCvHeaJFhP+DQeSm66Kef4S5lJaC
	FgyVEWpWPTu0DwjoodVWOV4hiUtD3CDO+SX7Lzg6XINO+s/KgKOS7V7JxpzRcR0Z6ST0IbWynte
	E
X-Received: by 2002:a0d:cb96:: with SMTP id n144mr6166505ywd.87.1551371442970;
        Thu, 28 Feb 2019 08:30:42 -0800 (PST)
X-Received: by 2002:a0d:cb96:: with SMTP id n144mr6166432ywd.87.1551371441965;
        Thu, 28 Feb 2019 08:30:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551371441; cv=none;
        d=google.com; s=arc-20160816;
        b=RsTW/yqDF6LEwzk2exwrCgFh/ErvYdArSNbmcd0sW3PJ0lVL50IIaYXYWEgTsdNMoB
         oIjMZxZyBotwXH17N75DevVhOxVYAeV/HXKoBJdBK4EK3LXmvU4tE6mRn8+gAtA1jdtd
         4lc7axDpoFCZH7ICBzRv3uNB8ic1UqS6H/VVoyuStWgwvhLhFksKFR+UBMhVA13Gguti
         2jTizjbPL+L+dkr+3oORSINh2KkKUGC5q8ZXY2pRJeP5H92X1cud5EUYNBKtqoOWapFc
         k1RRVSYknP/uwA/8A+V92ghELWpmkxDvMAn0SkZFdFQKSOzhXhDtyn9fVxG21u/ajdBD
         BwPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=r8ZvTCXRT2zhzdpNdKlPpMAbuU1N2QujZ8hztSmYHqE=;
        b=oOsbrCGcjSnPMwXqn2oc1VV9h6qDFxIEduRN7Di4i2rdss/Q33u99obQjuI49xWfhq
         XxnPqCXJvjVg9j1OuRzwxG27ltTlIOj6SVgytkQafS4dDgvmqOpSgjAhTWRF1XFoeYI5
         3hjHNRMRcFq1ybaiu7JUP7CZbd2Gab6SpwKeXQYXJkGUIJ/my6JR1zW0GTE5ZW/0B20/
         PTqLoVdLi2vEe1kKrEGt8sisS7vUH28IWfjOgDMdu4m1HWw67XiZSKAHocRhhUrJdcKh
         nv3W4z6TtGTH9FdORJHflKGOysdpfpjsrm6YA5ei2tZ9hSD1UmC2/yGW/56rJas28rJn
         9LHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=XuAtCfvA;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x203sor7430551ybx.18.2019.02.28.08.30.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 08:30:39 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=XuAtCfvA;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=r8ZvTCXRT2zhzdpNdKlPpMAbuU1N2QujZ8hztSmYHqE=;
        b=XuAtCfvAHvwTNFMx0qa1F9819pfkkTzHRKOpVaq3vLzhJJZC5lnmioCoV1xfLmgkpJ
         dUDLdfUT4PSmGDHSEcRyAbTij36xsmu5kZSwyjfKZJaAemf6Nbsl6VsdV2r7ap0+WDaQ
         YeOgPqmKIuQpdHTdijMZXbriMUePvgXWfVccv3ivtj43bnZYtbkhClWW1EPrqHeSPisz
         eT80DHEtMFihomuG7eX6Ia1aWE2lXirpvQlmhq3SKiQyN+IljLh2hhi3TEkTJ+u7+Fqg
         v67gmTMwN7XQbZDsN65N671ZQ9Ej1pqoyH1IfvfoZ8BGby5L3JOkc952FiSNY9U8dvb+
         Ut1w==
X-Google-Smtp-Source: APXvYqxB0gH055GPX2oHz+gUwTQnv6YveWOjsj5yriVXg0OXYCP3vvJLY2OFO3TWYjgjYe/vFCCB/A==
X-Received: by 2002:a25:7508:: with SMTP id q8mr227611ybc.158.1551371439265;
        Thu, 28 Feb 2019 08:30:39 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::3:da64])
        by smtp.gmail.com with ESMTPSA id 142sm5053877ywl.31.2019.02.28.08.30.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Feb 2019 08:30:38 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 0/6] mm: memcontrol: clean up the LRU counts tracking
Date: Thu, 28 Feb 2019 11:30:14 -0500
Message-Id: <20190228163020.24100-1-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ Resend #2: Sorry about the spam, I mixed up the header fields in
  git-send-email and I don't know who did and didn't receive the
  garbled previous attempt.

  Resend #1: Rebased on top of the latest mmots. ]

The memcg LRU stats usage is currently a bit messy. Memcg has private
per-zone counters because reclaim needs zone granularity sometimes,
but we also have plenty of users that need to awkwardly sum them up to
node or memcg granularity. Meanwhile the canonical per-memcg vmstats
do not track the LRU counts (NR_INACTIVE_ANON etc.) as you'd expect.

This series enables LRU count tracking in the per-memcg vmstats array
such that lruvec_page_state() and memcg_page_state() work on the enum
node_stat_item items for the LRU counters. Then it converts all the
callers that don't specifically need per-zone numbers over to that.

 include/linux/memcontrol.h | 28 ---------------
 include/linux/mm_inline.h  |  2 +-
 include/linux/mmzone.h     |  5 ---
 mm/memcontrol.c            | 85 +++++++++++++++++++++++++-------------------
 mm/vmscan.c                |  2 +-
 mm/workingset.c            |  5 +--
 6 files changed, 54 insertions(+), 73 deletions(-)


