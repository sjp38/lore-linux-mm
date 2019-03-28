Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EF87C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:09:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 024F1206BA
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:09:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 024F1206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DD7F6B000A; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88C066B000D; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E9646B000C; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35FFB6B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j1so3204944pff.1
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:09:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=s+zk/CUGkDr2mmqraLot65kVN8oBHGYCTuE1qiBNW04=;
        b=jptIO9QclBiClo0ANT0i0/d+SwjkhXUUejDN/R3LewB+boPaDECKc3JAQUOk4YDyk/
         Da8OA2fkGHG10bF0l4FHnzFvCAMbt18y6JUplGKV1BRvWHJtDFdZqH7LSLhQogCpptgy
         AZen03t/Tftr/NEPfWQ+BVOH05SDPT0g0JtL3GgHG+AK4IeXKiAyTbMi1gHCRJEjB2xR
         1ivHI0ubsEIeRAZgMj63SFn4hriwf5W6Tdf2pMLn9JfvCRZQcKFuG87lxFoiF1Ehse/s
         lv63uRJPQopqmaDIU6YQEO/BXvbNlOE5SiNRsJPzN8/UXWKEDPLD04b8R+tvGJPuXUT0
         xz8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAWUKhVL03P9madwriFq6ytk5/FuEmXXBoVxeGoxmBxRLaCv3Qn9
	SBGQiA3ES2RCrH3/zjdHsjMKLNFDVjp9vyTfpYnDwzMOtW1LpWvvcga6B6fsVln4vrK6kkX6PyQ
	9yzbcPPFJe9T8liOqqdD9AzBpFjs+ldUz2bA9AYh+k6pZLgBbh5W0rDY90PBIeKoJgQ==
X-Received: by 2002:a63:c45:: with SMTP id 5mr28262497pgm.385.1553706571861;
        Wed, 27 Mar 2019 10:09:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOfdIphS/MjniPPn7LrZ22aohPqJ2Ane49qLDIzt0j3VI3je4jSqbMyjNR1V40whz4pALu
X-Received: by 2002:a63:c45:: with SMTP id 5mr28262395pgm.385.1553706570823;
        Wed, 27 Mar 2019 10:09:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553706570; cv=none;
        d=google.com; s=arc-20160816;
        b=N1kLlYgNAlWu1lmUgabuT1YJ05ctPwp+NUHf7lIEnqEgdjMqqpsIR/2+G0W6fwfY9w
         N0fv59RmV7OjXflMe1QfXjEk2XslIhIUbP0LemCqvSYXaTeqU4o0fLjBYqmBU7aw91wE
         03X5y7UnCSRKv+zYfWejAlYADbSgUzL58FSxMixwXFAcYFKSOloB2NZoTAC04DmWxylE
         im0r1CBnx5F6h6UJF78ZzKYLxJQ4ws9SDp+HJanhVbciNIIADfnPa2UhTF1jVksL7SQz
         NRqd72luV0c/kX/9aYg4omr+l54c+Th7sJfgJKjHU2bZe3x9iqxaVRkeiDO4KoSfEq1i
         iV+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=s+zk/CUGkDr2mmqraLot65kVN8oBHGYCTuE1qiBNW04=;
        b=dSF/MN7NWcdB46brSjt8GERFyc81UYEbTX1v+vmjs7h466uGSq9L4CXxwLXtiQRZNR
         LJ4MmjFmmw7s48GGYG1293T+LO3Mo8Oo+G/1VhqGV6Xd2HiTmjTw82xh73xfbr7n7Rlg
         GaZkn2cIYbAiy/SBnu9/1SeBf+at5k40LTrhWg+rfvz0uSfNr7T4btP/B9Fi0pJGG/yq
         YOLLYChrubEwFqlEz6qqOYgQVtER2yFfobRvTdugXYwM3ZDseYMGMqOc4DHRmx9X+Uco
         Glg4qsLhQgf2LKQznhNU5mqZzWqnr0hkGiZjYzoFTP2rbs8Oy3p+2LYUHC1ZKs7una+9
         OIJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id n22si19678465plp.296.2019.03.27.10.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Mar 2019 10:09:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 27 Mar 2019 10:09:16 -0700
Received: from namit-esx4.eng.vmware.com (sc2-hs2-general-dhcp-219-51.eng.vmware.com [10.172.219.51])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id 9959EB2124;
	Wed, 27 Mar 2019 13:09:29 -0400 (EDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann
	<arnd@arndb.de>
CC: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	<virtualization@lists.linux-foundation.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, "VMware, Inc." <pv-drivers@vmware.com>,
	Julien Freche <jfreche@vmware.com>, Nadav Amit <nadav.amit@gmail.com>, Nadav
 Amit <namit@vmware.com>
Subject: [PATCH v2 0/4] vmw_balloon: compaction and shrinker support
Date: Thu, 28 Mar 2019 01:07:14 +0000
Message-ID: <20190328010718.2248-1-namit@vmware.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

VMware balloon enhancements: adding support for memory compaction,
memory shrinker (to prevent OOM) and splitting of refused pages to
prevent recurring inflations.

Patches 1-2: Support for compaction
Patch 3: Support for memory shrinker - disabled by default
Patch 4: Split refused pages to improve performance

v1->v2:
* Return number of pages in list enqueue/dequeue interfaces [Michael]
* Removed first two patches which were already merged

Nadav Amit (4):
  mm/balloon_compaction: list interfaces
  vmw_balloon: compaction support
  vmw_balloon: add memory shrinker
  vmw_balloon: split refused pages

 drivers/misc/Kconfig               |   1 +
 drivers/misc/vmw_balloon.c         | 489 ++++++++++++++++++++++++++---
 include/linux/balloon_compaction.h |   4 +
 mm/balloon_compaction.c            | 145 ++++++---
 4 files changed, 554 insertions(+), 85 deletions(-)

-- 
2.19.1

