Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 406F5C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 16:37:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07A9021726
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 16:37:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07A9021726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 924696B04AC; Fri, 23 Aug 2019 12:37:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D4CE6B04AD; Fri, 23 Aug 2019 12:37:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79CC86B04AE; Fri, 23 Aug 2019 12:37:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0233.hostedemail.com [216.40.44.233])
	by kanga.kvack.org (Postfix) with ESMTP id 5BBA66B04AC
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 12:37:25 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 0D8418243760
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 16:37:25 +0000 (UTC)
X-FDA: 75854248050.24.kiss94_2391401c20850
X-HE-Tag: kiss94_2391401c20850
X-Filterd-Recvd-Size: 2223
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 16:37:24 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 40C0C28;
	Fri, 23 Aug 2019 09:37:22 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 865353F246;
	Fri, 23 Aug 2019 09:37:20 -0700 (PDT)
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
Subject: [PATCH v10 0/1] arm64 tagged address ABI
Date: Fri, 23 Aug 2019 17:37:16 +0100
Message-Id: <20190823163717.19569-1-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.23.0.rc0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Minor update to the arm64 tagged address ABI documentation since v9,
posted here:

http://lkml.kernel.org/r/20190821164730.47450-1-catalin.marinas@arm.com

The mmap/mremap/... patch (1/3) has been queued in the -mm tree and
removed from this series. The tagged-address-abi.rst patch (2/3) has
been queued in the arm64 for-next/core tree. There is only one patch
left in this series (keeping the cover letter for consistency).

Changes in v10:

- Remove the tag preservation paragraph since the new ABI does not
  change the behaviour we already have. The only difference is that now
  the kernel can access tagged addresses (e.g. delivering a signal on a
  tagged alternate stack).

Vincenzo Frascino (1):
  arm64: Relax Documentation/arm64/tagged-pointers.rst

 Documentation/arm64/tagged-pointers.rst | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)


