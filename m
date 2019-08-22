Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24C0CC41514
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:52:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE61F2339F
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:52:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="UsKrpxXP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE61F2339F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rasmusvillemoes.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E2AB6B02DB; Thu, 22 Aug 2019 03:52:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 793A36B02DC; Thu, 22 Aug 2019 03:52:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A8E46B02DD; Thu, 22 Aug 2019 03:52:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0102.hostedemail.com [216.40.44.102])
	by kanga.kvack.org (Postfix) with ESMTP id 46ECF6B02DB
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 03:52:15 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id DB8468248AAB
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:52:14 +0000 (UTC)
X-FDA: 75849295788.21.coach87_309dd4d79235e
X-HE-Tag: coach87_309dd4d79235e
X-Filterd-Recvd-Size: 3393
Received: from mail-lj1-f196.google.com (mail-lj1-f196.google.com [209.85.208.196])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:52:13 +0000 (UTC)
Received: by mail-lj1-f196.google.com with SMTP id u15so4651092ljl.3
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 00:52:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=rasmusvillemoes.dk; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=rCTePgG7RYdXOtsqMn/EGiKAq/u1kBDj9aPT9Dfgczw=;
        b=UsKrpxXPuL+ZKlwuc+ITBE2tuLBFTuT+d1kgO/pLG86lqhfUTqbrbhF74QLrk18Pzb
         aOSONgtap5+EOa0YnJJ0gx+bb3jdFQaJOFn7UB33gwPAQlJWy8VDqNOK6ZTbyqKmTSVM
         pvhaBbl0n3KZ4qFLlOKtQ5UHKddxuxb/jsrZk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=rCTePgG7RYdXOtsqMn/EGiKAq/u1kBDj9aPT9Dfgczw=;
        b=iieloFZttnAkC8jUy/j0eaXGbALCzGSUHooVW5iTaOMdmujdNdzlsqJcKz68OzkcZh
         rMvY5/VqIITc3LoEEQAdSGtwHqdDWPRmQMfuosL8fD7qHyYr61GlGN4DGwfOm0jGeqKn
         XPioABOeNFS+UsftRPo0/IdPJF3pKlOYcw0/GnQz9zpzB2aSbDraZVS8JuZncqupbbkd
         4CWg/f5gl4mAWIx24B7AjwdCZ/XDDtore03RWuXIlmEGtCoF9xwMtZHk+oEfE6DShN8a
         RnVMCAZiPRqTtLwsR6cwHZt3OmzQstNnuLAqpe+MzmC5BIpvKqK0KNESc5cjUKcPQAHk
         QYhQ==
X-Gm-Message-State: APjAAAV5gOGZkH2s9j+zlgvhU2MAs3D248cH5QFpT25obeSelAQ57sca
	7fycmMnf2dGEePWnvysIF7YmBw==
X-Google-Smtp-Source: APXvYqxV31j+6lX+In5ijbALOUcTYMKfDsts8VM2xlJCyXRU+AgvcViEXDeB82pw2Jxiz7jc352mNA==
X-Received: by 2002:a05:651c:104a:: with SMTP id x10mr20266511ljm.238.1566460332223;
        Thu, 22 Aug 2019 00:52:12 -0700 (PDT)
Received: from prevas-ravi.prevas.se ([81.216.59.226])
        by smtp.gmail.com with ESMTPSA id x13sm3699675ljm.7.2019.08.22.00.52.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 22 Aug 2019 00:52:11 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/init-mm.c: use CPU_BITS_NONE to initialize .cpu_bitmap
Date: Thu, 22 Aug 2019 09:52:07 +0200
Message-Id: <20190822075207.26400-1-linux@rasmusvillemoes.dk>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

init_mm is sizeof(long) larger than it needs to be. Use the
CPU_BITS_NONE macro meant for this, which will initialize just the
indices 0...(BITS_TO_LONGS(NR_CPUS)-1) and hence make the array size
actually BITS_TO_LONGS(NR_CPUS).

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 mm/init-mm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/init-mm.c b/mm/init-mm.c
index a787a319211e..fb1e15028ef0 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -35,6 +35,6 @@ struct mm_struct init_mm =3D {
 	.arg_lock	=3D  __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
 	.mmlist		=3D LIST_HEAD_INIT(init_mm.mmlist),
 	.user_ns	=3D &init_user_ns,
-	.cpu_bitmap	=3D { [BITS_TO_LONGS(NR_CPUS)] =3D 0},
+	.cpu_bitmap	=3D CPU_BITS_NONE,
 	INIT_MM_CONTEXT(init_mm)
 };
--=20
2.20.1


