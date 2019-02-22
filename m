Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64CDEC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:54:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1311D2075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:54:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SP+p1d8f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1311D2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE0128E0102; Fri, 22 Feb 2019 07:53:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C41DC8E00FD; Fri, 22 Feb 2019 07:53:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABE6A8E0102; Fri, 22 Feb 2019 07:53:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48AA18E00FD
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:53 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id j44so940772wre.22
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QBwzVVFrwl/lt9+IMfY2XIzbrADnd5gfL2MVdMoEoBA=;
        b=PegBozn85Ptz7Dc0VlorxS2+2uXEB4abVhcyW8dDA8uveh4Akq/tlNs4fzcwZjXULk
         IoCNWGHqD14qug6Y+LNpqIo3Ojedi7+TFRzA3crW5zgmaO5z17nMfkoVpKThXIseJREu
         8pikHZYCaggojkWPu1TwRABX/NzM0v878ZMpp7m1xfkCtoKgWH3B/9KjC+g9+NA3KAxj
         JfH4tfaMsoLYS5zk3J3SyrWauV4n024KgmRY1k3abvpfNvjyi2zVvsMWIo9S7lEB/V3F
         Uvx3QAU1EE5gwF6V7KFDQSthKlzcfT+KEbQbsdEFLTg7zf2XiHoqTsCIbX/rgCdPP2I7
         zx5Q==
X-Gm-Message-State: AHQUAubLyrP9OgSY5D9sj3ElbQd6U5V2qR+LGgH6IDxHMkLDfvDhyQwM
	6CFseLz9Elcoxuw5Ry165hteoj1U5htkIx/zn7yD7nLgKYnFSjTy7sDnUlSDpZFCdul8hJ6C9MP
	VVCj9jRSD9l7M24/XQxSTg18Sqj9EW0QErGHWCdSLZKOcVhhctczYNkvEb9bIPhISM7HudFJeD7
	CAjX+rL/knRXn0P8Fb5H2aKcDWs2RiBYgzxSB5CTbzM8YIZHN3h/+VN2WvFfdanIHYlNoIrhHqZ
	0q1KKGEFOqQLPaY2m0dv/hjcFWaXLavWLFfdM5/WSSZHuIKGS8mjv8o9G9a7FqZutW6c5H9Ax2v
	mTt33WWTxHPCpL+DOUpOkzDViBYZ7Pq9qNFI3/1iFpbIS3aKI93w7ofcEfEyT0NHKljCFPzyMCj
	Q
X-Received: by 2002:adf:dd8a:: with SMTP id x10mr3035941wrl.117.1550840032835;
        Fri, 22 Feb 2019 04:53:52 -0800 (PST)
X-Received: by 2002:adf:dd8a:: with SMTP id x10mr3035897wrl.117.1550840031973;
        Fri, 22 Feb 2019 04:53:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840031; cv=none;
        d=google.com; s=arc-20160816;
        b=o8eXcgD7gRWlCEdRRy7VydRC5wEavGhHALNEi3ah1yjCG1bG0nlgrfYGu7GAJheZ71
         pW4uDXuURGUthk24yrb0fhv2Ae4ulrvNXi8jTMrp1wWjIUVw08dL0/KUMRwNxevMdzGA
         sWTzm9QzxIKt6yXnFBwvHSlnGqkuby5eQ36QhlF8KFt+SrojoIBDbdwH1Nj0cPfAXAnx
         goXTFogZS/uXwtRDSZH58fScF4XLPv0jxFeG55YI2189DXGWO0qFaGqQ/SeoL+cwBbJL
         VSGXuEKmTQLyqTmFqU0PdsKMIIgVkSD5u3SBVsiQA2IFg8LmaZvwSJQp1Es0CftXBdbo
         Zr3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QBwzVVFrwl/lt9+IMfY2XIzbrADnd5gfL2MVdMoEoBA=;
        b=xrgdzTC9gqJH7SMlcqphOOXnySvvAakwyT3+wia5bc1KR/oKPRAobea18MWW7bVJk/
         Jpl77lLf5TtZDRY32L0T3KpgVEE2qegDze30H7Rpek/8It9/PiBKQQg85PjzbOSy7tyA
         f49d/RvbfF62CokkI7qcIO3WsWVQR4P/Ep4KcGwmy7P7sm6QrPr/d41xTROfhKdSBjeH
         1KUv/deGEwRvqVW0+JsJRgUsyTVtYQBo+8UO5HEX14oAuxzvtvIUNDS3OWzCohhxanGx
         cA5K+v3PK820t+ElsNgRrdXW2xuwNr65IwnjfGtbi7xDe7U2Nh5AMCE3Zp32fpZSoujI
         IDFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SP+p1d8f;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7sor1101025wrr.32.2019.02.22.04.53.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:51 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SP+p1d8f;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=QBwzVVFrwl/lt9+IMfY2XIzbrADnd5gfL2MVdMoEoBA=;
        b=SP+p1d8f0BVnFGmwpzP5ObmgqSe7l5anq9SYK3Z0/3NQEWTdLTfJgPvtmksh4rCpqp
         IfRqUp24iOQF92rOfMBXwE8SN4Qg9+J3Ff0nPtSyfwTEqbyNm+DeeN5PWzbyT11CnE2+
         NiNjrCubovAK/wbw8TnBd9rAdhYi2JGQm/9ZBjiURbGSLjfWJPtszQ5Wp43UoL05Tluv
         TlBFrRQljeAOUxOv3LCaFgOpw7HH2il9JHvSEnJIjNEhD/hw3TxMJV0heNgWZ4hyYnqc
         k67G6tBgxNf5nw4KsRQIR60AgXHPgBerP6BueL5DUb/aboLZYnGfKfMCtobiEEHXKnw+
         xU8Q==
X-Google-Smtp-Source: AHgI3IZQ0MX6sfukCDFdoJfLKBs/7VPcUCMns2qTz5bt2s0RG4yqp/Tz4fV7jNtbv7px50I5nWPT9w==
X-Received: by 2002:adf:efc8:: with SMTP id i8mr3073265wrp.164.1550840031452;
        Fri, 22 Feb 2019 04:53:51 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:50 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v10 11/12] arm64: update Documentation/arm64/tagged-pointers.txt
Date: Fri, 22 Feb 2019 13:53:23 +0100
Message-Id: <e555d752859291bc74d550a5ea7e8ecd1876a308.1550839937.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <cover.1550839937.git.andreyknvl@google.com>
References: <cover.1550839937.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Document the changes in Documentation/arm64/tagged-pointers.txt.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 Documentation/arm64/tagged-pointers.txt | 25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/Documentation/arm64/tagged-pointers.txt b/Documentation/arm64/tagged-pointers.txt
index a25a99e82bb1..f4cf1f5cf362 100644
--- a/Documentation/arm64/tagged-pointers.txt
+++ b/Documentation/arm64/tagged-pointers.txt
@@ -17,13 +17,22 @@ this byte for application use.
 Passing tagged addresses to the kernel
 --------------------------------------
 
-All interpretation of userspace memory addresses by the kernel assumes
-an address tag of 0x00.
+The kernel supports tags in pointer arguments (including pointers in
+structures) for a limited set of syscalls, the exceptions are:
 
-This includes, but is not limited to, addresses found in:
+ - memory syscalls: brk, madvise, mbind, mincore, mlock, mlock2, move_pages,
+   mprotect, mremap, msync, munlock, munmap, pkey_mprotect, process_vm_readv,
+   process_vm_writev, remap_file_pages;
 
- - pointer arguments to system calls, including pointers in structures
-   passed to system calls,
+ - ioctls that accept user pointers that describe virtual memory ranges;
+
+ - TCP_ZEROCOPY_RECEIVE setsockopt.
+
+The kernel supports tags in user fault addresses. However the fault_address
+field in the sigcontext struct will contain an untagged address.
+
+All other interpretations of userspace memory addresses by the kernel
+assume an address tag of 0x00, in particular:
 
  - the stack pointer (sp), e.g. when interpreting it to deliver a
    signal,
@@ -33,11 +42,7 @@ This includes, but is not limited to, addresses found in:
 
 Using non-zero address tags in any of these locations may result in an
 error code being returned, a (fatal) signal being raised, or other modes
-of failure.
-
-For these reasons, passing non-zero address tags to the kernel via
-system calls is forbidden, and using a non-zero address tag for sp is
-strongly discouraged.
+of failure. Using a non-zero address tag for sp is strongly discouraged.
 
 Programs maintaining a frame pointer and frame records that use non-zero
 address tags may suffer impaired or inaccurate debug and profiling
-- 
2.21.0.rc0.258.g878e2cd30e-goog

