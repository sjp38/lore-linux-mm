Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE28FC3A5A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B265B216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="EAK9aWCo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B265B216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E5D46B000A; Wed, 21 Aug 2019 14:32:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 447856B000C; Wed, 21 Aug 2019 14:32:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30DD06B000D; Wed, 21 Aug 2019 14:32:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0030.hostedemail.com [216.40.44.30])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0DA6B000A
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:09 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id CB17F99AC
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:08 +0000 (UTC)
X-FDA: 75847279536.10.smell28_2fc92bb94f43f
X-HE-Tag: smell28_2fc92bb94f43f
X-Filterd-Recvd-Size: 4380
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:08 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id m10so2742515qkk.1
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KZlSM1+HYlx5AabYJySSHWoh4S6JQNg+E/eloF1WuIo=;
        b=EAK9aWCollpH9xmdUtaiVBS6Ul8Grpce2v4a96pxnxYp2IBX8da/99b/wGOvABGtwu
         YGsbf5Rf/sZVH8SNTtDy0XpnvFV5C9IC9WYVDSpYpMbwVzm7ArMz9PW52kFErZTTXCsL
         WTyBvzhkpiiRAQw8xhZCkbesGdEv3+KaY8OAZ6E7bzieO3RZcGtLLT0Pz48c7wl8J3Zh
         tOImm/Vrp/7Gj+QIPxNlt0oaaMZyfLcgYRPH40jynE+MITM4+xI0XYdvt3v88kfQeRO6
         7KdjAnbtkEeJP3UjA9HD358p6hLYn9PO5svHWmEYjnXYtYqKE97d1nQSshP1W53Wo27L
         IM5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=KZlSM1+HYlx5AabYJySSHWoh4S6JQNg+E/eloF1WuIo=;
        b=GNAqTutTNmuQnA+E2JGV2bBFXQxVB6HyQtQrhQv+89y/+pvs9gyAOyoefd/0zCTA+s
         EBl+eRsK61pC9glVEFHrJ9GOHwDh0tn44uwLbYlm8QWo0M9BD0KUNkMBohE9lvBn9A5U
         NmbnJG6mo5OiOI+wV2slvtW72TE2XnuULanegUbJNITdrl6N8W5HjPO2tURtGQ72hSPe
         AL2R3ypjYnrQWn+dufjgckvim6ZC3ekqRYUVGMLE1Dk6te5AWGWfLzzGY1MuG25h6Q4r
         tq8PCvENYagk4xUEbTb/RyV0tEb81G0DUycGaF8a/+iM3eofi83y8wIMWEQtAYmT+jXn
         GrgQ==
X-Gm-Message-State: APjAAAVaLooqjBDhap3FruWrS+ZP49Af4RNVOWosqVBfYQQqYGGX7Xy4
	o9lkvDUUk8vTXQuNd/UkN1YBlQ==
X-Google-Smtp-Source: APXvYqxa+1nBillHVTD1wUyey0q2i0nGT/ot1gRBODj0C6eDdzfP5MOz2GYbi9GTD87ibQ+3R7pbkA==
X-Received: by 2002:a05:620a:4d4:: with SMTP id 20mr30837041qks.95.1566412327681;
        Wed, 21 Aug 2019 11:32:07 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:07 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: [PATCH v3 01/17] kexec: quiet down kexec reboot
Date: Wed, 21 Aug 2019 14:31:48 -0400
Message-Id: <20190821183204.23576-2-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190821183204.23576-1-pasha.tatashin@soleen.com>
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here is a regular kexec command sequence and output:
=3D=3D=3D=3D=3D
$ kexec --reuse-cmdline -i --load Image
$ kexec -e
[  161.342002] kexec_core: Starting new kernel

Welcome to Buildroot
buildroot login:
=3D=3D=3D=3D=3D

Even when "quiet" kernel parameter is specified, "kexec_core: Starting
new kernel" is printed.

This message has  KERN_EMERG level, but there is no emergency, it is a
normal kexec operation, so quiet it down to appropriate KERN_NOTICE.

Machines that have slow console baud rate benefit from less output.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Simon Horman <horms@verge.net.au>
---
 kernel/kexec_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index d5870723b8ad..2c5b72863b7b 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -1169,7 +1169,7 @@ int kernel_kexec(void)
 		 * CPU hotplug again; so re-enable it here.
 		 */
 		cpu_hotplug_enable();
-		pr_emerg("Starting new kernel\n");
+		pr_notice("Starting new kernel\n");
 		machine_shutdown();
 	}
=20
--=20
2.23.0


