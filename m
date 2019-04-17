Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2505DC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:40:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7B8020651
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:40:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eNHc8dyn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7B8020651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A41A6B000A; Wed, 17 Apr 2019 15:40:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62B1A6B000D; Wed, 17 Apr 2019 15:40:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CBFE6B000E; Wed, 17 Apr 2019 15:40:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2856B000A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:40:08 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 3so16056738ple.19
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:40:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=gT/T9M0R5/BEi6TIlhU+Am5U1UIgoVTtygo47LRkjIc=;
        b=nAr1WwGM2VpnWvAK8d25o9VKfcpWHjeLg0e6EDBHxVugOf7m0vWrdp7r5d3UcyXzQx
         hvL+oThlmwr8taKnTW459P8JzBVtMfuuM/t+KtdLx+6Wb2ouyEtoKydvYJxqOcCDDiHO
         HXN46oHMEDMJzSas/erfwxudj39468NSamkAaccB9nXSuNW4WuuJZF5P0boZnd3NQfJW
         vpdDUpGdCLNHCwA0qmBX1I95be48VKk8Djl8gJNzXhMfBVDeUZOmplq6H196sIArmKnM
         TIxC/ZgpWI2Htg0uqaIq8mLYzmuLjUas8iLB9wURtBZiumEItqKgD/aB3YehlrcBVAEY
         Jjxw==
X-Gm-Message-State: APjAAAWIb7W9oPcctqcLArx9IXhl/R1R7qxGTp4/5f02IPBlc0D1oOSz
	Vg8uKbpJBfPfsG28Nvl3Bwx6hOomcj7Kcqw9goBbf1l1Ls3r73h0WXlKnP5dsiKw2Eh6z66qXfz
	rDAZ6ym2CcvlRGmCbPQ8eldiZh8MCJPM1xyb7+GLAcBwKdL9qWyUSNSwmUhzflXB/Ow==
X-Received: by 2002:a62:4115:: with SMTP id o21mr90848893pfa.153.1555530007606;
        Wed, 17 Apr 2019 12:40:07 -0700 (PDT)
X-Received: by 2002:a62:4115:: with SMTP id o21mr90848820pfa.153.1555530006594;
        Wed, 17 Apr 2019 12:40:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555530006; cv=none;
        d=google.com; s=arc-20160816;
        b=HsvWpDLb0qHEJlI91865kWxynzaxrlSi9+vqFm43W6wgKAwcBHN+LNA+dioKMZ3IkB
         ETcn+UAPGUUCbc8HnJBPLE614gn+Kq51nIt5mF4Ke70TgYZkZWbrWmMlKy+4WsovMNzo
         ftnCLGjCSAGnuuGzoBhMKDKOtgyvgx1mgBG4c+oivW/Cqi+T/nsCg5CSySma6F04g0/p
         31fhTIs6+VFMFac0JxqPVIn2llXz7CrZkog/DogopbPL4C3yf7zf5PHQ63i6mH/7wJ7X
         LdljizMuxLWRzP2WBzfc5uh1tYp78OhU4Z+uNS9FX6m4+4umfeXu2U7pWn4jeVrZ0pMv
         p0gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=gT/T9M0R5/BEi6TIlhU+Am5U1UIgoVTtygo47LRkjIc=;
        b=BpJmUNpWrAagf91DX2fXsm7jk4F8Ym4OgfQK8YNTXCIug+qtN76nr38z/PduzKX1FM
         AAC25HyxfelJdlviBuzEpeQsvRjVBQGWZCUstyJ60B16wW4zm0A+nk3eXmC26CtrYkvF
         QQDGI6ua3EZXkADonAwHLlEpfjWRtbbyW/x2aJ0ZYpG3456Uyz1dqgWt60rVJ+lZ+7Gt
         lcUUiAnoeHmUGXRwpnbMqk7z3wjBkjRG1+PP+CWtmaQTw3pVTyftnqb4+99NuCZei/9C
         hYbb44ZBh5BwKBNMywoP5jUdgvrnVGSNOIVgRXEhNzumWUoRHmvUVO7r6u4lUqf+mWm6
         1RJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eNHc8dyn;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 31sor16924007plc.23.2019.04.17.12.40.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 12:40:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eNHc8dyn;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=gT/T9M0R5/BEi6TIlhU+Am5U1UIgoVTtygo47LRkjIc=;
        b=eNHc8dyn4U1XUlujtETs9A87f/6hUOrjt2MNGw93IXp8wvLubty2kvBZFdWrzuvyOJ
         zZw/1esaU+7NJFHlcbG8G5HSxtxenOcwOq+plPF3AMaGm5g8rnUmvefqVzZx3TEzt3fD
         KN9oUT2wYMS4kQ4PTNQ19uBRHK1QCEaYcC1g/5M9eRu2FsdxTMP3iVfnd4UbKa9H7NFL
         BdYxdoXTOXnQq7L84AugDtiQnrQWCnMQEmKq8b19tOUj7AKU7ilUEqAOeHDBs98QdCwq
         SL92Og5JDgI8zqqj2qncqqsGewBaLugHaBRssqE86Isc7s9WU6P54CdAlUh73s1joWZA
         3Mhw==
X-Google-Smtp-Source: APXvYqwvUKyOhiajy/fe1naJTzh7wzopFZ54w9JSFUM32mfLpFPHYOwHHyl9Ryr0EZcdmvxZyf0xvQ==
X-Received: by 2002:a17:902:bb84:: with SMTP id m4mr51333883pls.302.1555530006246;
        Wed, 17 Apr 2019 12:40:06 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::3:856])
        by smtp.gmail.com with ESMTPSA id v9sm8625949pgf.73.2019.04.17.12.40.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 12:40:05 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	Matthew Wilcox <willy@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH v4 0/2] vmalloc enhancements
Date: Wed, 17 Apr 2019 12:40:00 -0700
Message-Id: <20190417194002.12369-1-guro@fb.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The patchset removes a redundant operation in __vunmap()
and exports a number of pages, used by vmalloc(),
in /proc/meminfo.

Patch (1) removes some redundancy on __vunmap().
Patch (2) adds vmalloc counter to /proc/meminfo.

v4->v3:
  - rebased on top of current mm tree
  - dropped alloc_vmap_area() refactoring

v3->v2:
  - switched back to atomic after more accurate perf measurements:
  no visible perf difference
  - added perf stacktraces in commmit message of (1)

v2->v1:
  - rebased on top of current mm tree
  - switch from atomic to percpu vmalloc page counter

RFC->v1:
  - removed bogus empty lines (suggested by Matthew Wilcox)
  - made nr_vmalloc_pages static (suggested by Matthew Wilcox)
  - dropped patch 3 from RFC patchset, will post later with
  some other changes
  - dropped RFC


Roman Gushchin (2):
  mm: refactor __vunmap() to avoid duplicated call to find_vm_area()
  mm: show number of vmalloc pages in /proc/meminfo

 fs/proc/meminfo.c       |  2 +-
 include/linux/vmalloc.h |  2 ++
 mm/vmalloc.c            | 57 ++++++++++++++++++++++++++---------------
 3 files changed, 40 insertions(+), 21 deletions(-)

-- 
2.20.1

