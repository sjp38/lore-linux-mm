Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F3FDC41514
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8DC321019
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="IzkXm55G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8DC321019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9469D6B000A; Fri, 16 Aug 2019 22:46:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F8316B026C; Fri, 16 Aug 2019 22:46:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FB4C6B026D; Fri, 16 Aug 2019 22:46:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0033.hostedemail.com [216.40.44.33])
	by kanga.kvack.org (Postfix) with ESMTP id 507586B000A
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:46:34 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E1E94180C2E63
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:33 +0000 (UTC)
X-FDA: 75830381466.18.screw17_9095908954d12
X-HE-Tag: screw17_9095908954d12
X-Filterd-Recvd-Size: 4350
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:33 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id y26so8226142qto.4
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:46:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/W9Ma+c4Rolhy4bvMsvhnDmmj8s4aI4sxvLahrmQOEs=;
        b=IzkXm55G371ze9WVXoK9zad2ACOWDzvok3ySCIMBFTsFQm/1InDzb4H9PlQDZg3B+1
         91fZTR5nLchedpHW5aMPgbel2ZEnY/4Y6d81TwasXQGUoWl3pwGmSACJDbW/T3nKDssv
         +h3dvvD8iyrRdZCJ9mha5885pBDWmcYAqYgiE1seOv1ZfRELrnfuyWjc6lHkfNkB8ktJ
         OywN1d704ZniaPy18rJWm0ZLYmHEL1f2xGaIMRi+uXWwoVQjHADEaYflSmFqXYFC50TK
         COI8DMNyB3sCcIRHgivG4DS6VQAKx7jm3bktmlgmeRCdmQ4puTVFBSpYFVIiLAL++B8O
         rYkQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=/W9Ma+c4Rolhy4bvMsvhnDmmj8s4aI4sxvLahrmQOEs=;
        b=AcRGNP670wf3JPNpQGo2Te/RJ4f688THnmx1nMbclFIUF0qVYF4X7fOVZ2KbGAFdcs
         Zj7JjTfEt1jr+sVuxGNuklrd6nlfsAN6iHWt891q4lUcee4VzruncTy4aX5Y+VW0mMFr
         vxHOr3YDgkAskt+Fghy9fuvi33A6P6y4zu+d7FPMWKjLujgdK/TPp/rOYDIORAO4COef
         E3yr/Td+nBI3bRGg0FvHo65gUkmucnuHjLR506HOzOmiaZUDd11YiPkmO49PS9/zuI5j
         KM/dQ3rWTcvSEzXExLUU21K+3zLOT/VpD767TVQWP2jWPF8YCxhaFX5e8dxN12QuySsf
         4lfA==
X-Gm-Message-State: APjAAAXIcx7ppZdsregPyMweGMJNje2xajoaEt8ocbSTR3ZOFcOogngV
	YHZiOG/rU40rwrVsSLy6+GKpow==
X-Google-Smtp-Source: APXvYqx1YDVIUM4aXrDf+J+vqbqrtMk2KC2J/YfduCmqN0tJGEM/fwsJ5MGyaogor4fl5Zg9qkbq9Q==
X-Received: by 2002:ac8:23cf:: with SMTP id r15mr10955016qtr.97.1566009992864;
        Fri, 16 Aug 2019 19:46:32 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o9sm3454657qtr.71.2019.08.16.19.46.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 19:46:32 -0700 (PDT)
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
	linux-mm@kvack.org
Subject: [PATCH v2 01/14] kexec: quiet down kexec reboot
Date: Fri, 16 Aug 2019 22:46:16 -0400
Message-Id: <20190817024629.26611-2-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190817024629.26611-1-pasha.tatashin@soleen.com>
References: <20190817024629.26611-1-pasha.tatashin@soleen.com>
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
2.22.1


