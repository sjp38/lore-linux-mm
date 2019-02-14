Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FE06C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:18:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF9702077B
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:18:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mS1kRCWJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF9702077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 855B28E0003; Thu, 14 Feb 2019 11:18:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 803108E0001; Thu, 14 Feb 2019 11:18:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F2BF8E0003; Thu, 14 Feb 2019 11:18:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFDB8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:18:50 -0500 (EST)
Received: by mail-vk1-f199.google.com with SMTP id d123so2748069vka.4
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 08:18:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=oKk58CX0dVCOzbtvHNUy4h7TKuAtrChgZJQZr0P+GiE=;
        b=df6zMGj7Hg+j3CqIPAn5mOR7OrTgCj/lCdPA1/AJ0Tg2b/Jfzs7jqryGYeKyt6giTR
         8Lh26A5RKhprZCcZ5Fnt7L6eq4TcRuXkkcyVpLTmjour9YDrm7g9KBCetiRz38Lrmjuw
         mtGnh6i6biLR/hg7+dMU+beDw1zOBNvJD2d+XmrmE4Ik9wqf/s6GQ69nuOb3SFCsPrbM
         3DLMG2enDn+0SGazpmZUR8HFnRFoNNWE4z1rQfF6ePGgJQFR9NKn0VOMZ48Gxgoz+k4b
         m2DO39X/XvFcp0/r1Y4+8wMBauAb7N6Sf5w82+Xezskex072dYwMnJSvbcnhjlm7mjTp
         YleA==
X-Gm-Message-State: AHQUAuYp4r+PiRQCkAvWN9CrU3PU36skbMjOArdRj6gjOnZY8KpAMfoE
	4MmxTyC7173PyaJFlOcMPlQu+lyOlj6l10yU+rIrVnr+Flb/KZUxMtVWoDK/YnPfQUqGd8fIPIX
	ZzfJndGAUxO6pa3CjYnYyn2DNN1G600tu2Ix5/f2lt7xw13XCFuFlcZRtoUpFRY0mVcDLRwsQmm
	W/UhHxaT4VOJRsYu5QaPFZr/2rmETFRFvdW9WSVJqBWiMW/YdcGPU+ueMkIIERsMCveig2MaOss
	NK0PKebHLS7GzUrKXKNGvbdShLRTiVvLb4RmPV9a5iiccCFI6pq/FgTuZfGE5mVgQc7bDtlx+Yp
	D7PselUHAtVjiFXYM1kQwTev9uBfvJ/XqnYcrY8yrErwOgHQ6L7oEw1m5kP60jj1PTbfPi8lNtU
	k
X-Received: by 2002:a67:7e09:: with SMTP id z9mr2366207vsc.194.1550161129621;
        Thu, 14 Feb 2019 08:18:49 -0800 (PST)
X-Received: by 2002:a67:7e09:: with SMTP id z9mr2366159vsc.194.1550161128779;
        Thu, 14 Feb 2019 08:18:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550161128; cv=none;
        d=google.com; s=arc-20160816;
        b=tO0aW1C5TfkvTX1El4Z8joHnt6Ol70QU1iQ553A22uSBM5bks94L3QxFDH7/zU1Tos
         kOi7ckbVDPSidHaVZlMbUPWeM58HdicmyhpgnbzUGn9JLcPEMC3kun8sm1Y8rhCD7zJF
         uPqGRbsuetXP6CNpaGfg5VLEislARPjgg4GGGyBOLzgOWwNShldvoKZl/RTgtqikfEXx
         5TxHX0JFH6kyGHcDlCTiH04RpjJiVJ063aPUkqPcSWtFJdBNkmpFFVIA9cqUXIkBdHRZ
         bXs1BptPfIRcclhz005RJwIpMd7YOrF2xt71KKHoLtjgA0TMfoum2QKQOZ9J2IOWhoXo
         V3Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=oKk58CX0dVCOzbtvHNUy4h7TKuAtrChgZJQZr0P+GiE=;
        b=Oi1yQGswr6ye5gm9Sz7LgRGnuwm09YaXzMeUFZqtkU6zoMs6+jTB/4LPHBG7NpX/Gw
         kih64jFKsagZfu3fhV4SZiHWLsZCr8DH7y8NFrfkx2Cl7SL1DeqDzn/H/JblQsdpEJV/
         7E6BZZxV0O28Z5V1dR9r15ncv+hqmH2leF+89YksMCySMYnd17usI/gA9WL7Z65vCzLb
         KvezQa86F7DL3XOFikS7pvEcKLI6mwvW/pJoJh9Tb3oskUKPQ2wwQ4sFaoKhU2ZVU40h
         JmMkUp0iOXFAM8i5kSrH0ZhxIoCDPzQN71hK0bk+L2JQVXs7WQAIYh4OOM0tx8Pj4u+q
         YgwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mS1kRCWJ;
       spf=pass (google.com: domain of 36jrlxaukcje4v88219916z.x97638fi-775gvx5.9c1@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=36JRlXAUKCJE4v88219916z.x97638FI-775Gvx5.9C1@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id e63sor1502022vkh.5.2019.02.14.08.18.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 08:18:48 -0800 (PST)
Received-SPF: pass (google.com: domain of 36jrlxaukcje4v88219916z.x97638fi-775gvx5.9c1@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mS1kRCWJ;
       spf=pass (google.com: domain of 36jrlxaukcje4v88219916z.x97638fi-775gvx5.9c1@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=36JRlXAUKCJE4v88219916z.x97638FI-775Gvx5.9C1@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=oKk58CX0dVCOzbtvHNUy4h7TKuAtrChgZJQZr0P+GiE=;
        b=mS1kRCWJiqrdR2I28pUMVV7dUzsj3u2bjHCUuI1NBtQnbga7MdZBcOecCT/pcqcejq
         vO1xAFuMg6VDkg8uPNFaOHnBrlw2chDWQDiXjw+h6DE6tV9RtuCvNyo1PUP5vIe8imOF
         39OwTiGs+9LBH+dhgd0V/r7UBChbHyx9tFPR614u1JbIGgz3CDPbdjlvZVi+sAagWG8E
         IAFtUPDvv/CGkdtEvRnmhARHFWDqquO0JkXZLHdGbJtd5z5f2AHcWxF8snFUTZtZXWfq
         GeoppSp43tw3sgvx5sgNvoOpIdOvOqM6HCBivjype7Di1sY+7KLFCYDxTxWFceJKLZQR
         tvFQ==
X-Google-Smtp-Source: AHgI3IZENa5stLf3BmZXrkkpDjFibVOtJyqCAzo3f+gbiNpbmVAskmxuKgc5hqf1elacYQ5y/Si280bI2w==
X-Received: by 2002:a1f:2d08:: with SMTP id t8mr2942878vkt.14.1550161128419;
 Thu, 14 Feb 2019 08:18:48 -0800 (PST)
Date: Thu, 14 Feb 2019 17:18:36 +0100
Message-Id: <20190214161836.184044-1-jannh@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
Subject: [PATCH v2] mmap.2: fix description of treatment of the hint
From: Jann Horn <jannh@google.com>
To: mtk.manpages@gmail.com, jannh@google.com
Cc: linux-man@vger.kernel.org, linux-mm@kvack.org, 
	Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000429, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current manpage reads to me as if the kernel will always pick a free
space close to the requested address, but that's not the case:

mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
-1, 0) = 0x600000000000
mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
-1, 0) = 0x7f5042859000

You can also see this in the various implementations of
->get_unmapped_area() - if the specified address isn't available, the
kernel basically ignores the hint (apart from the 5level paging hack).

Clarify how this works a bit.

Signed-off-by: Jann Horn <jannh@google.com>
---
changed in v2:
 - be less specific about what the kernel does when the requested address
   is unavailable to avoid constraining future behavior changes
   (Michal Hocko)

 man2/mmap.2 | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/man2/mmap.2 b/man2/mmap.2
index fccfb9b3e..dbcae59be 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -71,7 +71,12 @@ If
 .I addr
 is not NULL,
 then the kernel takes it as a hint about where to place the mapping;
-on Linux, the mapping will be created at a nearby page boundary.
+on Linux, the kernel will pick a nearby page boundary (but always above
+or equal to the value specified by
+.IR /proc/sys/vm/mmap_min_addr )
+and attempt to create the mapping there.
+If another mapping already exists there, the kernel picks a new address that
+may or may not depend on the hint.
 .\" Before Linux 2.6.24, the address was rounded up to the next page
 .\" boundary; since 2.6.24, it is rounded down!
 The address of the new mapping is returned as the result of the call.
-- 
2.21.0.rc0.258.g878e2cd30e-goog

