Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1637FC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 15:44:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D517920665
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 15:44:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D517920665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EDD76B02AC; Thu, 15 Aug 2019 11:44:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29FD86B02AE; Thu, 15 Aug 2019 11:44:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 117916B02AF; Thu, 15 Aug 2019 11:44:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0168.hostedemail.com [216.40.44.168])
	by kanga.kvack.org (Postfix) with ESMTP id E35C26B02AC
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 11:44:18 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 875968248AAD
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:44:18 +0000 (UTC)
X-FDA: 75825083796.21.crook23_7ce4659b2a759
X-HE-Tag: crook23_7ce4659b2a759
X-Filterd-Recvd-Size: 4771
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:44:18 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 647AF360;
	Thu, 15 Aug 2019 08:44:17 -0700 (PDT)
Received: from arrakis.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id B3B1E3F706;
	Thu, 15 Aug 2019 08:44:15 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Dave P Martin <Dave.Martin@arm.com>,
	Dave Hansen <dave.hansen@intel.com>,
	linux-doc@vger.kernel.org,
	linux-arch@vger.kernel.org
Subject: [PATCH v8 5/5] arm64: Relax Documentation/arm64/tagged-pointers.rst
Date: Thu, 15 Aug 2019 16:44:03 +0100
Message-Id: <20190815154403.16473-6-catalin.marinas@arm.com>
X-Mailer: git-send-email 2.23.0.rc0
In-Reply-To: <20190815154403.16473-1-catalin.marinas@arm.com>
References: <20190815154403.16473-1-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Vincenzo Frascino <vincenzo.frascino@arm.com>

On AArch64 the TCR_EL1.TBI0 bit is set by default, allowing userspace
(EL0) to perform memory accesses through 64-bit pointers with a non-zero
top byte. However, such pointers were not allowed at the user-kernel
syscall ABI boundary.

With the Tagged Address ABI patchset, it is now possible to pass tagged
pointers to the syscalls. Relax the requirements described in
tagged-pointers.rst to be compliant with the behaviours guaranteed by
the AArch64 Tagged Address ABI.

Cc: Will Deacon <will.deacon@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: Szabolcs Nagy <szabolcs.nagy@arm.com>
Cc: Kevin Brodsky <kevin.brodsky@arm.com>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Co-developed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 Documentation/arm64/tagged-pointers.rst | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/Documentation/arm64/tagged-pointers.rst b/Documentation/arm6=
4/tagged-pointers.rst
index 2acdec3ebbeb..fd5306019e91 100644
--- a/Documentation/arm64/tagged-pointers.rst
+++ b/Documentation/arm64/tagged-pointers.rst
@@ -20,7 +20,9 @@ Passing tagged addresses to the kernel
 --------------------------------------
=20
 All interpretation of userspace memory addresses by the kernel assumes
-an address tag of 0x00.
+an address tag of 0x00, unless the application enables the AArch64
+Tagged Address ABI explicitly
+(Documentation/arm64/tagged-address-abi.rst).
=20
 This includes, but is not limited to, addresses found in:
=20
@@ -33,13 +35,15 @@ This includes, but is not limited to, addresses found=
 in:
  - the frame pointer (x29) and frame records, e.g. when interpreting
    them to generate a backtrace or call graph.
=20
-Using non-zero address tags in any of these locations may result in an
-error code being returned, a (fatal) signal being raised, or other modes
-of failure.
+Using non-zero address tags in any of these locations when the
+userspace application did not enable the AArch64 Tagged Address ABI may
+result in an error code being returned, a (fatal) signal being raised,
+or other modes of failure.
=20
-For these reasons, passing non-zero address tags to the kernel via
-system calls is forbidden, and using a non-zero address tag for sp is
-strongly discouraged.
+For these reasons, when the AArch64 Tagged Address ABI is disabled,
+passing non-zero address tags to the kernel via system calls is
+forbidden, and using a non-zero address tag for sp is strongly
+discouraged.
=20
 Programs maintaining a frame pointer and frame records that use non-zero
 address tags may suffer impaired or inaccurate debug and profiling
@@ -59,6 +63,11 @@ be preserved.
 The architecture prevents the use of a tagged PC, so the upper byte will
 be set to a sign-extension of bit 55 on exception return.
=20
+This behaviour is maintained when the AArch64 Tagged Address ABI is
+enabled. In addition, with the exceptions above, the kernel will
+preserve any non-zero tags passed by the user via syscalls and stored in
+kernel data structures (e.g. set_robust_list(), sigaltstack()).
+
=20
 Other considerations
 --------------------

