Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2E4FC282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:57:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94E43218D3
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:57:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94E43218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 279F88E0008; Wed,  6 Feb 2019 18:57:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F9D18E0002; Wed,  6 Feb 2019 18:57:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09FE58E0007; Wed,  6 Feb 2019 18:57:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B9A9F8E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 18:57:13 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id y88so6503537pfi.9
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 15:57:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=sOjklSNe51RFx32WiAscoCXKh8DpxqGGcbauECjXbdU=;
        b=ZFajqX8o9DuxdILuqkIubXJqVUdZbbmuZbt9ZPDAP4zU6RNm6smEFgBLTiFyV26sHh
         0855GyBmFsfbUgOtteFJxWDP9P8csOCkZNS0YOcjpkCn5yRQ3bHnB+nvJUTHdw7nhoju
         V3hcTDSxq1HqUQxd2Q3DAVBThpPsCFVDD4sHuTZgAkrf3dHA0XYz+PjYRWFmwisRXb2v
         MR3yxM4qKbDFbqWTuAii0K+Q67zESX43ehr/gFTz2MCTmbtkOer10J6buF8fWmSdjHJu
         CmnoRVxNZG6DlCBbHHEN0oDmLRSTYhtVqdhwCtP5U5iyEXal8XgdzjdwhbLe8kCe+t7k
         eeUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: AHQUAubJLt6Dgy0UGopKTu3OZiZcsR5+FwCOCTe+pHorJUd1JjaRngUS
	6qUgUS/LHDDzjBA924yDZLpF0A3MbDD/s4pQBEpXy8WmgcfWpSZj1O5LRdF6BF38o/bJEm4gtcF
	ftPxEoeG8WM8l3IYyNuvhOzTt7aZ5EaG7BGkfUFX8RjE78rNPABQK9iWhfPIj6+7L0Q==
X-Received: by 2002:a17:902:380c:: with SMTP id l12mr13161569plc.326.1549497433432;
        Wed, 06 Feb 2019 15:57:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbgcUY8gq6wW4xJhGT1T5TE8BhWG9dVJ1/Y3rXB0mR5dCIBvW0U4vwfvMXu9xdLjDe4GvhN
X-Received: by 2002:a17:902:380c:: with SMTP id l12mr13161517plc.326.1549497432325;
        Wed, 06 Feb 2019 15:57:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549497432; cv=none;
        d=google.com; s=arc-20160816;
        b=pQSIYclqx/hecb8m3MFPciywdzZJiXmlY6SroffolfoolYrHVoQSHd9a0IKmGy8wod
         Gc2Y55tVfbAchoVNtVXIGbGLfDMDaEvoEbCTXwQdntCrgqVFe2R026+74xvQyYw8wLF0
         oKz6n59LJMCWKAENl8Q8vQdtYWMY6aGcpBOijnBfkYKg0yOmZPANpvLP/xcc/y5iOdzI
         X5REhdGm+BErLlE+9mo70QUy8Jixk34b5dbziHI8POEbOB8tvHnvC2ml1CcFHuEHWX8t
         1Wsn1NNFpmoFFXHHDZcrPtzIrJXsCjm41aFC0phyIabd5QaDmQIgjimtRPJoBq+NAYWG
         bY7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=sOjklSNe51RFx32WiAscoCXKh8DpxqGGcbauECjXbdU=;
        b=hrKcB+DJXdJYI11d0+Wro3roJeTHw6DRepykqzc/0K7XBM4IcDat7VFU0ohf8f811k
         KLMV/lW2R9XMO+b0Oisc5CubW2dHNc8W/FQYLQg47YlcYRoRfckN1nQj7drHM2j+WYDs
         KbNja1S9u+ddVbDzvTbBeyEvKGofisPLrx2rU9iC+soWXpAj2gOG3H+dZ9WeP2bMcoVT
         h5HEilJJ4r1cKSv9rRThCOyT3hkg1iKklGOTujbpbdfyzrsPwyC5p29j3LWLvXBcrQKz
         C0dLBn//SjpLK/NQPfdDKvUJo+cLGFYRujibcQTmwB8HdPtW8fTCVTunyP4LAkQkWnDl
         LLUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id n2si7185931pgr.67.2019.02.06.15.57.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Feb 2019 15:57:12 -0800 (PST)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 6 Feb 2019 15:56:24 -0800
Received: from ubuntu.localdomain (unknown [10.33.115.182])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 87F0C40FB0;
	Wed,  6 Feb 2019 15:57:11 -0800 (PST)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: Arnd Bergmann <arnd@arndb.de>, <linux-kernel@vger.kernel.org>, Julien
 Freche <jfreche@vmware.com>, Nadav Amit <namit@vmware.com>, "Michael S.
 Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	<linux-mm@kvack.org>, <virtualization@lists.linux-foundation.org>
Subject: [PATCH 0/6] vmw_balloon: 64-bit limit support, compaction, shrinker
Date: Wed, 6 Feb 2019 15:57:00 -0800
Message-ID: <20190206235706.4851-1-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Various enhancements for VMware balloon, some of which are remainder
from a previous patch-set.

Patch 1: Drop the version number
Patch 2: Adds support for 64-bit memory limit
Patches 3-4: Support for compaction
Patch 5: Support for memory shrinker - disabled by default
Patch 6: Split refused pages to improve performance

This is sort of a resend, since patches 2-6 have not been sent (the mail
server rejected since Xavier, whose email address was deactivated, was
mistakenly cc'd). Patch 1 was changed according to Greg's feedback.

Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: linux-mm@kvack.org
Cc: virtualization@lists.linux-foundation.org

Nadav Amit (5):
  vmw_balloon: remove the version number
  mm/balloon_compaction: list interfaces
  vmw_balloon: compaction support
  vmw_balloon: add memory shrinker
  vmw_balloon: split refused pages

Xavier Deguillard (1):
  vmw_balloon: support 64-bit memory limit

 drivers/misc/Kconfig               |   1 +
 drivers/misc/vmw_balloon.c         | 510 ++++++++++++++++++++++++++---
 include/linux/balloon_compaction.h |   4 +
 mm/balloon_compaction.c            | 139 +++++---
 4 files changed, 565 insertions(+), 89 deletions(-)

-- 
2.17.1

