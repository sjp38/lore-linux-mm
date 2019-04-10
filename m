Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7F8CC10F0E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 02:48:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6027120857
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 02:48:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="lOxkk1da"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6027120857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05EA96B0006; Tue,  9 Apr 2019 22:48:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00DBF6B0008; Tue,  9 Apr 2019 22:48:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3FED6B000A; Tue,  9 Apr 2019 22:48:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C47BB6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 22:48:02 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q12so945620qtr.3
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 19:48:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=XlC3RnW+D3VAmOuoJxxfAw5B6kl3S91FZ3Fvm+E8U4A=;
        b=UiL37u1sMVq8aqcv3M+5PfCnBZuxfyFh7Q3/UBFc57VPiUFdo+yihigwC06s4RhB1t
         4mv+xjIz9/UCLdUWwp8JXf75Rukdb+kOyqRuo10p7eN3bhKtkDyL8XXKgG04qKAghD2O
         Sc0Wdwb09Iu5gnB6ilIC3ZgZgLDJ/IadncwTNX8nQygvjEmMP8HN2OZXzvBdaCPW4avy
         qG5BlR0DG3R3KI+4fhJOvPxwWB56YCBFa0PiTGAu0cRP7LnZt7pGjKQHQveLTTtxar5v
         6yeMEexsUKpQKr4mKyKVL0hj8gTEMNx4uixwkqDVaAaSWQOWSlVxk/gcpu1md53Ni1Yh
         03Tg==
X-Gm-Message-State: APjAAAXfEgt5ICosV7Pn2bM4Oa1aAH8Atrpf5WT4tTwFwSU3Vmam5vZk
	istuPeSDHX2PKzAz8z49PudQssFwpmL0+585dKyuMno2+736TS3D/vIXGeEFCyekvkvVthhCKX0
	bxWVRtYpeXeiTW/lAYBtuS4VEhaTrMLt5DwMWNCv+UKN+WDr3yAU9qzV6dwMQRS4=
X-Received: by 2002:ac8:38fd:: with SMTP id g58mr34603371qtc.14.1554864482503;
        Tue, 09 Apr 2019 19:48:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxr+zUTFzewnFISRVwzCNnVdZ81/D4rnjPuxm0oqfT9vlVCUDSTibZK1fJi1+DFK77t7iLi
X-Received: by 2002:ac8:38fd:: with SMTP id g58mr34603347qtc.14.1554864481823;
        Tue, 09 Apr 2019 19:48:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554864481; cv=none;
        d=google.com; s=arc-20160816;
        b=l+9ebCQqa3OsHQvGFyczSMf1Gz3KLYbvuGNVnUhYNIoe/oDguV8hpXtiuwgQ/olh5+
         mI1ahdki5vjv2KAue9Kuhmsr9jlHaOaxrmc8qZxbHGUa+c7pBGUDXKFHvium4DK7nvfH
         MY18lQSdMetR5eoqvl7Ym0iYIJQeEfeVoLyCr76Umw5xT0Tu1gIOExSb8bIW4aadDvGG
         rT/dR5ob602dbCJO6hsXTONBYPp/DPUE8QxxqgROtnUyUnrk94NKLJ/Crr+dKgzEX1/n
         BJTssPoqd57UghezKQd6DONtPFUi4uykLiOcHzFO8I1BABUjGu5Lg77JlwmY//qHZwVg
         tcVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=XlC3RnW+D3VAmOuoJxxfAw5B6kl3S91FZ3Fvm+E8U4A=;
        b=V2YTWNA2/RxWiGso3nZjs6Ue4EJjlSfpUBRs+N7unx5pXyb5wkEHeDZnyYKbh7mtTb
         w9mOR+T1XsntyPbrL3zZ9rH1czybKBNoT4mv9S3QuaS8OuoQF96azHhHnWvvvHHYUw1p
         F92Dzfj3UOFT4tOdiFwFQc6W0SVYUC1QMiPUcR1W+Sq/upHfN7+BWrUrMxYX/SLQ5xRy
         g1SApG089PitkF8KQISb1gslKnjpZkRPgzObTFshFR95BZNoD2QO2Cf3//BVjyRHj02x
         25lNiH7TbdJnX9sdrOdPtUU0Pc/S8lZ8HE2mt+2KCnRY6kn4DftXX4NAPc6A5a7h7Ip3
         FeMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=lOxkk1da;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id n24si3344015qvc.146.2019.04.09.19.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 19:48:01 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=lOxkk1da;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 89AA411096;
	Tue,  9 Apr 2019 22:48:01 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Tue, 09 Apr 2019 22:48:01 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=XlC3RnW+D3VAmOuoJ
	xxfAw5B6kl3S91FZ3Fvm+E8U4A=; b=lOxkk1daLOiUegnToXTPbXZstC7PhgN8v
	JNgQ4F00fMnTVZ9Snb0TFwk1DOJX1P61pbFmowgODP7h80N4aot4GVMGZz3fOYik
	AnUTSDJTvxaREOlbp5MXLBDdt6wCTpG98txUqu/KxZ2tNB3P8Dn/iPtOjjwKyohF
	e5GFJR9x6pYoyB2Fb99+TrdsSEfBr/9RfytcES7lAuuSP9/iyrqHOdZDjEzXqS1Z
	SImlly6TxIpyKk/7r83JOAj8p3/NXz5yhv5iSyY7rdmDeZdiIKmwn5x+MojV8IjW
	xx7oSwhoA/WUlWAT2wgAvT16zBbZ4qxnHGVm3CU/uAtW3XoAPds1Q==
X-ME-Sender: <xms:YFmtXMGFGIm-6am_5gDOgtnvVC7UyKzeFA4_cSGhoHZ_gw2hLatYSQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudeigdeigecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhnucev
    rdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkphepud
    dvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgsihhn
    sehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:YFmtXHOxTD7FOy3Uqw5GxJ2yaEeSWtc0WPUtjpjETR_PwYY0jg7hHQ>
    <xmx:YFmtXLQRd69luDnYzNCduhWMeanR3b0TETYgqZmLhuTNH6O11-7TlA>
    <xmx:YFmtXOSqW2Me1ghCuZXKUIfBx8Bmj7IHXCf1B3IWSU0oOIMKCMcEJw>
    <xmx:YVmtXFW9ie1klqfZaQJ-XkL6mOtkCMZwpXSIPUYTZofIoqXp1GVMzA>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 746D610391;
	Tue,  9 Apr 2019 22:47:56 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Tejun Heo <tj@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 0/1] mm: Remove the SLAB allocator
Date: Wed, 10 Apr 2019 12:47:13 +1000
Message-Id: <20190410024714.26607-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Recently a 2 year old bug was found in the SLAB allocator that crashes
the kernel.  This seems to imply that not that many people are using the
SLAB allocator.

Currently we have 3 slab allocators.  Two is company three is a crowd -
let's get rid of one. 

 - The SLUB allocator has been the default since 2.6.23
 - The SLOB allocator is kinda sexy.  Its only 664 LOC, the general
   design is outlined in KnR, and there is an optimisation taken from
   Knuth - say no more.

If you are using the SLAB allocator please speak now or forever hold your peace ...

Testing:

Build kernel with `make defconfig` (on x86_64 machine) followed by `make
kvmconfig`.  Then do the same and manually select SLOB.  Boot both
kernels in Qemu.


thanks,
Tobin.


Tobin C. Harding (1):
  mm: Remove SLAB allocator

 include/linux/slab.h |   26 -
 kernel/cpu.c         |    5 -
 mm/slab.c            | 4493 ------------------------------------------
 mm/slab.h            |   31 +-
 mm/slab_common.c     |   20 +-
 5 files changed, 5 insertions(+), 4570 deletions(-)
 delete mode 100644 mm/slab.c

-- 
2.21.0

