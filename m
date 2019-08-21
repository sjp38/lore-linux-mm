Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB070C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:47:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72197233FC
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:47:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72197233FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1E276B030A; Wed, 21 Aug 2019 12:47:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA7E26B0319; Wed, 21 Aug 2019 12:47:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D207E6B031B; Wed, 21 Aug 2019 12:47:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0066.hostedemail.com [216.40.44.66])
	by kanga.kvack.org (Postfix) with ESMTP id A7A156B030A
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 12:47:46 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 45B968248AB4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:47:46 +0000 (UTC)
X-FDA: 75847016532.04.tank18_9515b7911a27
X-HE-Tag: tank18_9515b7911a27
X-Filterd-Recvd-Size: 2621
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:47:43 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B85EA360;
	Wed, 21 Aug 2019 09:47:42 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 09F003F718;
	Wed, 21 Aug 2019 09:47:40 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will@kernel.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Dave P Martin <Dave.Martin@arm.com>,
	Dave Hansen <dave.hansen@intel.com>,
	linux-doc@vger.kernel.org,
	linux-arch@vger.kernel.org
Subject: [PATCH v9 0/3] arm64 tagged address ABI
Date: Wed, 21 Aug 2019 17:47:27 +0100
Message-Id: <20190821164730.47450-1-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.23.0.rc0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This series is an update to the arm64 tagged address ABI documentation
patches v8, posted here:

http://lkml.kernel.org/r/20190815154403.16473-1-catalin.marinas@arm.com

From v8, I dropped patches 2 and 3 as they've been queued by Will via
the arm64 tree. Reposting patch 1 (unmodified) as it should be merged
via the mm tree.

Changes in v9:

- Replaced the emphasized/bold font with a typewriter one for
  function/constant names

- Simplified the mmap/brk bullet points when describing the tagged
  pointer origin

- Reworded expected syscall behaviour with valid tagged pointers

- Reworded the prctl/ioctl restrictions to clarify the allowed tagged
  pointers w.r.t. user data access by the kernel


Catalin Marinas (1):
  mm: untag user pointers in mmap/munmap/mremap/brk

Vincenzo Frascino (2):
  arm64: Define Documentation/arm64/tagged-address-abi.rst
  arm64: Relax Documentation/arm64/tagged-pointers.rst

 Documentation/arm64/tagged-address-abi.rst | 156 +++++++++++++++++++++
 Documentation/arm64/tagged-pointers.rst    |  23 ++-
 mm/mmap.c                                  |   5 +
 mm/mremap.c                                |   6 +-
 4 files changed, 178 insertions(+), 12 deletions(-)
 create mode 100644 Documentation/arm64/tagged-address-abi.rst


