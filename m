Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76DE1C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:37:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3405F218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:37:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TNB2/8TB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3405F218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8FA78E00FE; Mon, 11 Feb 2019 11:37:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3D2C8E00F6; Mon, 11 Feb 2019 11:37:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B530A8E00FE; Mon, 11 Feb 2019 11:37:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD888E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:37:02 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id z198so3138438qkb.15
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:37:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=ISun9MAS+KVytOd1BlrXoBr37mM1yAGSGTfHJEPM32s=;
        b=AcW+UsRu9wRu6hUVv3dsghn4e+3L+OY+nGL5S7pQlEmNKnqQdPRuCgjj8UugCvthoV
         c35mod+rDpRmvc6l4QmmSavQxDcwRwO6VlCYNfzbopN/a+rmPDdvewZVp0oFnKInBkcZ
         m3SEUFoO8NAo0uYQcfULGuxRprej/ziEuGyrLA+8uSERVLBTFzovaD9r99I/VdgYAxgL
         OIrM0qhMBZ/yNlAYmLXBQhgOJQKnMfYBRPs06L9WICQ8k2897Vgb3xNXl2jFtkn7dd6Q
         bG6i+QNScUJRtYvNwnoxXauhk3df8r8frTLOSwiCMwGSDK5ByIzbZZsAt48zYAmOSCw1
         cdnA==
X-Gm-Message-State: AHQUAubqN7llC7n6CPAIwmgawNhG6x7tZwTfcLOB3P0ho7+Jl7r3Qv7L
	QKF4JfIp6AHrmirEf405zV1ARtNldapMN0qWrSzlTRJGSRo2WxYHZ7dITqJtUfv0xWRBeWbdigE
	uLKtGWoPCDm+ns9a1k5kLWS6zktUqsNHA4yLvHxxhmz6BkrFx4Iq/o/C0qoExsBnIMKfter7e5b
	sIs8VZ4/3qvsOI8ZmvSzku8Jvpt82ItFWTcdYn4QQq4Hxstktv7lTB3VU7l/cHcGyuZR583+Y+U
	4UZlw/r5WU+xElaP7gcnVCY03It1vhRguZvGJo0+sjuoWuJgQg+yPj2uwob1Ri5X8aILpTuZBHD
	CNqc7YOHJRfwosGpNt1Njt8rgjlyqKXJPSwQBXl860KRmSbtPOmEDNTHQ6ziy0Od/C+FnyJVaGu
	V
X-Received: by 2002:ac8:5558:: with SMTP id o24mr27168900qtr.182.1549903022301;
        Mon, 11 Feb 2019 08:37:02 -0800 (PST)
X-Received: by 2002:ac8:5558:: with SMTP id o24mr27168864qtr.182.1549903021668;
        Mon, 11 Feb 2019 08:37:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549903021; cv=none;
        d=google.com; s=arc-20160816;
        b=CCIH1MhApwb9Wwe1ZSA9fkXeJgo0Y6+fIY8qgeOfnCVmlHSD00ohbEQML79Q6LPE8P
         Ry6jw9mKDDi4LnObinWXu+QYgD+Gvk8TP/BmLIrulf5gn1DnIVNV/ukfTWXPQEoOntum
         XCf2G2c3eNkjm35o2ZriTAJt3CsWqQEPyGRnxQVe6jmljUyMlqqcOMzknGgvdWnHCMwq
         lTKIEmaWpvQEvMcBgs4dnx0NULVyBL+opqaCQCR10NupUGv60IYQmb+Izm7AEvlmrYX3
         pr4/Ta0B6RmeddO0dp/wRQQemYBEX+2UxCjx34of9wJ0kTgpLMRMR4zC5VEN1wLjO1Vi
         BDAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=ISun9MAS+KVytOd1BlrXoBr37mM1yAGSGTfHJEPM32s=;
        b=EwPggRwcLhil3Y4BNw3AHS1dNAiWUPJonjiSQ7Hb4dS44QSkfT5k560iHpS3kmki4F
         n8rN8wPkF7V+3fIDv71GYq14oSEOfMJT1rh0Qy36Xt4tSj00oda+I3+FTYexF5Fb07Ow
         EZVsCvcJ/gDDDs/uoSSWsIxCPfGkxyyKo7zAcZ3fmXDezkyyt+983Pwa2Dd7qFMmsb48
         iQOlKhRiY39tP9hM4tMaXZMlZ7lV3vrCNNkxrXb96EqQ/3LF5Np9J4L4Gj47ZDh5AMQ9
         SB8sn3cW1IIV+tWr90YMqhwLDIZXVr/vAu7ImkhG4itsV9MZdF0/KjjfSlZ/jLaEwMLp
         G3iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="TNB2/8TB";
       spf=pass (google.com: domain of 3rarhxaukcgynerrlksskpi.gsqpmryb-qqozego.svk@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3raRhXAUKCGYNERRLKSSKPI.GSQPMRYb-QQOZEGO.SVK@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id x10sor2207453qkx.18.2019.02.11.08.37.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 08:37:01 -0800 (PST)
Received-SPF: pass (google.com: domain of 3rarhxaukcgynerrlksskpi.gsqpmryb-qqozego.svk@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="TNB2/8TB";
       spf=pass (google.com: domain of 3rarhxaukcgynerrlksskpi.gsqpmryb-qqozego.svk@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3raRhXAUKCGYNERRLKSSKPI.GSQPMRYb-QQOZEGO.SVK@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=ISun9MAS+KVytOd1BlrXoBr37mM1yAGSGTfHJEPM32s=;
        b=TNB2/8TBwxbKKd2i42i2M7UNYFPUuZ64UIeF/y5q0W/RWfGzDCpL9oAeLllxUgbpxu
         /cvhORcFHMuixNyvvXBi8swrgkc8NK8XFMtVDmmXKI0nooslZQcTJY2isSJJYk0ivgT6
         NFHfV11v8RgZMXI890RMntZksGTENB71Ubvb5F2UW0DQOw21cGSnNJJMtGlvKhZ7IvT9
         g/y9JC1+onhZf8pbSNO66gA2hh6rV2+5h6lrXNfNvRt7jdJKA28Djl/NGpsdi5rSc/+w
         p6/3NrHFkVMS+STFZSgm/kHncRU6QkrSNBTNSCTzprdYtg16aJQEVP/RE1fsbvxc+vjY
         bRXQ==
X-Google-Smtp-Source: AHgI3IbIpHNITiD/z7phI27+wkBpML0Qrk8afGSQ6mMM5RujSQsYB+1u3g69NuuKIR42OGBcaDSaC7fcxA==
X-Received: by 2002:a37:d150:: with SMTP id s77mr3319763qki.35.1549903021406;
 Mon, 11 Feb 2019 08:37:01 -0800 (PST)
Date: Mon, 11 Feb 2019 17:36:53 +0100
Message-Id: <20190211163653.97742-1-jannh@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
Subject: [PATCH] mmap.2: describe the 5level paging hack
From: Jann Horn <jannh@google.com>
To: mtk.manpages@gmail.com, jannh@google.com
Cc: linux-man@vger.kernel.org, linux-mm@kvack.org, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, 
	Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, 
	Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	linux-arm-kernel@lists.infradead.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The manpage is missing information about the compatibility hack for
5-level paging that went in in 4.14, around commit ee00f4a32a76 ("x86/mm:
Allow userspace have mappings above 47-bit"). Add some information about
that.

While I don't think any hardware supporting this is shipping yet (?), I
think it's useful to try to write a manpage for this API, partly to
figure out how usable that API actually is, and partly because when this
hardware does ship, it'd be nice if distro manpages had information about
how to use it.

Signed-off-by: Jann Horn <jannh@google.com>
---
This patch goes on top of the patch "[PATCH] mmap.2: fix description of
treatment of the hint" that I just sent, but I'm not sending them in a
series because I want the first one to go in, and I think this one might
be a bit more controversial.

It would be nice if the architecture maintainers and mm folks could have
a look at this and check that what I wrote is right - I only looked at
the source for this, I haven't tried it.

 man2/mmap.2 | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/man2/mmap.2 b/man2/mmap.2
index 8556bbfeb..977782fa8 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -67,6 +67,8 @@ is NULL,
 then the kernel chooses the (page-aligned) address
 at which to create the mapping;
 this is the most portable method of creating a new mapping.
+On Linux, in this case, the kernel may limit the maximum address that can be
+used for allocations to a legacy limit for compatibility reasons.
 If
 .I addr
 is not NULL,
@@ -77,6 +79,19 @@ or equal to the value specified by
 and attempt to create the mapping there.
 If another mapping already exists there, the kernel picks a new
 address, independent of the hint.
+However, if a hint above the architecture's legacy address limit is provided
+(on x86-64: above 0x7ffffffff000, on arm64: above 0x1000000000000, on ppc64 with
+book3s: above 0x7fffffffffff or 0x3fffffffffff, depending on page size), the
+kernel is permitted to allocate mappings beyond the architecture's legacy
+address limit. The availability of such addresses is hardware-dependent.
+Therefore, if you want to be able to use the full virtual address space of
+hardware that supports addresses beyond the legacy range, you need to specify an
+address above that limit; however, for security reasons, you should avoid
+specifying a fixed valid address outside the compatibility range,
+since that would reduce the value of userspace address space layout
+randomization. Therefore, it is recommended to specify an address
+.I beyond
+the end of the userspace address space.
 .\" Before Linux 2.6.24, the address was rounded up to the next page
 .\" boundary; since 2.6.24, it is rounded down!
 The address of the new mapping is returned as the result of the call.
-- 
2.20.1.791.gb4d0f1c61a-goog

