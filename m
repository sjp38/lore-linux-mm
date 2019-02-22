Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50C17C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 091882070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dFFShaLk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 091882070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA5198E00FF; Fri, 22 Feb 2019 07:53:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDEA28E00FD; Fri, 22 Feb 2019 07:53:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B81FA8E00FF; Fri, 22 Feb 2019 07:53:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB6B8E00FD
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:47 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id v24so937514wrd.23
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9mSxyMmz1xjHsHJUyT/WYIPnpYi9SCNSb/qUJqV67bQ=;
        b=oW0uw3YEGW3tJ+mGmcT0BB+aS3TSUu35wSfqLxLVK6FUkoOy7C6iJye2mBBdFokVgy
         IpGEZCvA+SKHq0cBQMWjGUmj8BXsjFhv2qL234SJ49SmZHSZXqBo7gDvMhn/Ok32icMK
         n3vfqPnwh84bBUeCIQov2v5Wrwkh3hMbru/8kYAuFSxRwDxaCWMbqTFMHYlsW4t2TpCo
         3XVkajRvO48eiPWPIOlMjUDP52epC+dVoNrmnNKSBxegOYIc1oMq6HJu+q7N3xbu5hwO
         +5TkeQdsAo89N7kzyQeiS0Bg0vcnIsZK2UycROPI9hCbgWs8swRFlB0POcMFonyS/YQy
         nVVw==
X-Gm-Message-State: AHQUAuap0BeZN7zPvEmTC2PB2NglVkc07Zqh7aa9qzW1u8T+0dAQ/g71
	wLJBKj+Bk0IssaisMZKnmTWQQUPnEOEPntgpDggdb5vhnwhUaNEM7CTCheDuto4vdyV8a05G4jH
	5P1ZdUYkoNY3xc3Z0CpDc3JiL52uwiVRgatyqDDLvdsyHJTeNrBxZKmniRlfEywBeuHpwzqVkcx
	RJGP57f6myzIARluXr1wYN4NbfgwyQR90JQp2MBJX8haPhH7ZAf5L121a1DtpmawL3pqEF92PN3
	e2Y9OC3Xln8+iTGqL//owIYsF+SCq8b2H16aQxtp51xPBAAEy9/HPFostAF/hoNay3MoYowb/Up
	orvsQDB76Jw2gUxBLYLUTMiYTpYUI9DNT31WZJnEEvzBpBwfBQYhLKr+A5YGPqUuORJVUf6qNSZ
	a
X-Received: by 2002:a1c:4d17:: with SMTP id o23mr2478214wmh.53.1550840026917;
        Fri, 22 Feb 2019 04:53:46 -0800 (PST)
X-Received: by 2002:a1c:4d17:: with SMTP id o23mr2478175wmh.53.1550840026122;
        Fri, 22 Feb 2019 04:53:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840026; cv=none;
        d=google.com; s=arc-20160816;
        b=kjBcl+geDtyWXNnBtweajK2OnxmoNPKm24eNG+Q9aa53NC4/3osfNHYInMlJjk8uxr
         SjUSZZPgpuKugRHuKMBT7dr2FzAKnJFEIXEtmYPmj/jYqQrHnoWwVUJb9zFBl66zHRg/
         XlUw/y0z2ArzLM8Dc5MJTOPNYVIJkE3Ne+g01sqDaMsEkCMDTpLzbnAMJyKpWe9BsoMb
         yMho/Xfba0WNUDmrHIRFWIQy83dafQF9JBMdoQUB2UmF80fBmHbNfHCeOjWaY/PmHL+x
         ujMNubztVrBYpv/j20Xagd3TG/0aoR8aejE5g1z2BAZI22NQ0qEr62VPvS9IdCuZPfYm
         VyjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=9mSxyMmz1xjHsHJUyT/WYIPnpYi9SCNSb/qUJqV67bQ=;
        b=ZQSiGiK+xFgTlSDEEnoNH/G+G6hO2tIO8HsvoqDJah/bnrc8vYuLmsJsAs1zwuslgG
         Of8kI0mY9JkQBm8jK3ynAL8dM71aqjkeLrNKe+0rSbDuzEgDu5Efotf/Asr2V9+IcWgV
         SKWf1MuJY32Ho+eEYFRqN1lLhnDghI2XBGwiHDGlCL3YmWJPWZ6qaLPuJAiVcmGvQmIS
         6D73nvAznm5qvZ+RbEifqC+Aypygd7y+UxKtHsIJikr2UZ3MgLpxYFK4GNHToj3O8/IL
         VtPPdFD0EArfdbCvozGNBrRasLlEAra4xJ0V2XJ3Qz9zK+vRpE+R+3qJz+Yya10TyE4k
         c1oA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dFFShaLk;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b14sor1109912wrx.20.2019.02.22.04.53.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:46 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dFFShaLk;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=9mSxyMmz1xjHsHJUyT/WYIPnpYi9SCNSb/qUJqV67bQ=;
        b=dFFShaLkfC9Jd78NrGHT6+qV8Fa9yuKItk3VxryuG9FBzLyVutr/noYyEqX9rPsCPB
         4FR/7879ajA8ORjVk4I07QF8PQLg274w2Q+K0O39R3Ga3Hhea7F4g92KaP8LM4y5+Hso
         eJt1r7agSQJ/Q7Cx/ewAN6NsplIo0lNiUtrymbVmaJov1lsCukOg7OdDCcVG/G6dymSR
         5NrIRbGPjHAFt0tx/2kWNS9S69vHxnpOLSsET8RPCLmIYV5M4RxLn41hJi0rYK9TmjkN
         4J4iqkL9iIltHwkRu+ZKdYA7Xy0gQC5aG2HVCItmVD26gYOu7PxGByh9QtCwnvGsjRA4
         qTzA==
X-Google-Smtp-Source: AHgI3IYB1rxXC3qLSPjqnlg3vyINEmisEJ9COGx3+BlbVTSYQsvRd/r4g+wzkk/8Tl6H/RsXQOXN5Q==
X-Received: by 2002:a5d:500c:: with SMTP id e12mr3055201wrt.27.1550840025673;
        Fri, 22 Feb 2019 04:53:45 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:44 -0800 (PST)
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
Subject: [PATCH v10 08/12] net, arm64: untag user pointers in tcp_zerocopy_receive
Date: Fri, 22 Feb 2019 13:53:20 +0100
Message-Id: <ebc80132c8ebf6016821ddffbb7e461bd2484824.1550839937.git.andreyknvl@google.com>
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

tcp_zerocopy_receive() uses provided user pointers for vma lookups, which
can only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/ipv4/tcp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cf3c5095c10e..80f3c1fb9809 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1756,6 +1756,8 @@ static int tcp_zerocopy_receive(struct sock *sk,
 	int inq;
 	int ret;
 
+	address = untagged_addr(address);
+
 	if (address & (PAGE_SIZE - 1) || address != zc->address)
 		return -EINVAL;
 
-- 
2.21.0.rc0.258.g878e2cd30e-goog

