Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D116C10F03
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:08:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB0152084F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:08:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="myYETjF4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB0152084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1806A8E0003; Sun, 10 Mar 2019 21:08:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 130238E0002; Sun, 10 Mar 2019 21:08:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 020188E0003; Sun, 10 Mar 2019 21:08:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C93D88E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 21:08:20 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o2so3268478qkb.11
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 18:08:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=T1dZV3cS1FB6Iz/lCstJWsGELgplemQHQV7/Ond8b20=;
        b=DkkwpYfYJktqvoLjyewo1BUnoRvMHvyPokWCSWtG4H+e/acG5TLOz/JcJXWfKy8I1H
         7Pmw7yFV+oriZA9ibLyWvA35MLBP63HiJvoR8QHj5O4NfYMzQv4wXRVj0LGcozFUA6V5
         qKHPb2T8jDgZ40GPpTQexOqo3nGuoHmUd9Gz6UTKw/K9Kmirh2ZPDa1YN/v017kfi6pV
         zUhMOURuRGBPjnbm9rNvhVgEJVuVRN2n2B6YJo2oLZr+72MGLUPjiTPAgKvd5DZFB7wm
         XDsT7YIkKRX62JlctwZdoCVxe58EZtbEn3x5lR7c0ckUIVtyhEK+xSv4fLtDKdG+ta7e
         2O1Q==
X-Gm-Message-State: APjAAAWeQ2+Ejl7cpmZVXVFduMBy+9NHjDeOIdorB7lbxNwFloy3Ifzx
	uFx8hISn5zVndsxkIQMnX3eUkXMSAQo2vk3X+pRF2TNRsZ/J6QuJR5OhXBYV8jgvDqMcwPnQn1M
	vMvjf3zM5vTYCdt9Q18WejolwegjL66plJ6WCd639CYHGSL/NCnsz7qJJEcCl29I=
X-Received: by 2002:aed:21c2:: with SMTP id m2mr24986247qtc.107.1552266500520;
        Sun, 10 Mar 2019 18:08:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5obBhSPQEvKqXeOKpWbBJkj5rY6Xs+WP1Z2nP/BDbti4sNDQhTa0pPaSUPa1YeBozF4NB
X-Received: by 2002:aed:21c2:: with SMTP id m2mr24986195qtc.107.1552266498956;
        Sun, 10 Mar 2019 18:08:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552266498; cv=none;
        d=google.com; s=arc-20160816;
        b=m7/rkoU/8eqUx7qcjO1vcXuOgCJOUshwDVFuSQdbCXVAENa4lVGyU1mp/rnx9ZyqKc
         FEieV6gZgQZnOTZz+SAKi8JenXvYpTdmcec9pMOX9m3h8KEo3/Ak1vBEhb/rtmrfr+5T
         IOMi0S/gV6ZGAB5yGaFlXrwOKZDXKrH1eb2/+FLIqucBiGFnqlkXMOy79I27RrQyAuBd
         XOkm8cRhMQUUrhv+Y7bIjrYM2M3xMNo2Fq5D2YIVFgsK4YLpwZVlZhjXCQHX3f6xfybz
         mWTjFSdvwqsc5TTsxcuuraDYW8VTrdI7MUmLhC0V46hUas9tyFfkf79IlmNEqKKhFLmr
         g2MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=T1dZV3cS1FB6Iz/lCstJWsGELgplemQHQV7/Ond8b20=;
        b=uYuJwXAJfGYZDiM/2ZLnvHZ9h+bAp9SsmHXi1SOkPzjDPFkmmy1gzWZB7E7ufsiamq
         0D+YVEvvtVolfoi6084ySjaO75+inHEZnd5wKVsQSq516y7JBd9hh5PtKNK5BPu/HhvK
         UG1Vy5dhw9b9QM2bmwofwyoZEpn51r3l07yTmdyOVwDBPwmT7tSV+9VB6XCCZYqMDYSn
         QRn9VXZU6y6KqfGTqOfc0+8aunGlATE4t2otjrlXsyK3ocHgRiJCCPWmrmcZwjbZ6uN2
         9qSA5Zsq61k8LE64quJ24YykdtT/cwkmZQb3w/t8JDba8UDpbEVoany7lyCr0ANdZy6o
         DdiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=myYETjF4;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id b4si2119142qta.220.2019.03.10.18.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 18:08:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=myYETjF4;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id AD193217DD;
	Sun, 10 Mar 2019 21:08:18 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Sun, 10 Mar 2019 21:08:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:message-id:mime-version:subject:to:x-me-proxy:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=T1dZV3cS1FB6Iz/lC
	stJWsGELgplemQHQV7/Ond8b20=; b=myYETjF4g+/oSJ6XYAfNU6sSO5K0sxbWR
	v3W6dgDMo2JRFPXQL+6wDa1Q7INU3bCSn9p9gHbqAlXsVhhpoQbzyuYhLV7Fnatz
	feWVY9x9zZSkPy53Z3hFCIrWIA1YClG7rD0HmwphDqFSqSk94rZAxvyZqUTk5o75
	VXeWkOTn5jyATQBTTeghZePGMzE8HfyyzhjkcT4rFUjV67/vNXHrUT7bHiTOcqq2
	Bho/RyyDAi5+r+Qfo43vl5Km67j9ZU7hQ8l1eDj9veBABYzLAqCV/k7w0wfv+Bsx
	+6fR9CoZ1oQqCwQzE7jYvDZWDgH09ouQ2wKU8nRzlgDZBF7QbUCyw==
X-ME-Sender: <xms:ALWFXJcLT3SNQhkw2XWOyTkvPz24CWWil7m2J_h30oRRVuJl3eKpUA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeehgdeftdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhnucev
    rdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkphepud
    dukedrvdduuddrudelvddrieeinecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgsihhn
    sehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:ALWFXFuGL2vmcy02-nLiJNwEr9Ut0BA4A2AF9-b-mAFVCvfPkdGUtw>
    <xmx:ALWFXK7sy4RaxpBWw5NFWpuLk2C_ylQrdThCeDAoTkNgAtuyuk0f7g>
    <xmx:ALWFXEwuIzXTISEY-ns3msJF3NMGfYhmCVJbEvRhHaCdUeyQtt7rFQ>
    <xmx:ArWFXDrDcPpmSxalAOUCA4tDroDdM7U_V5D7pByQNT_Bi1XWznp2ug>
Received: from eros.localdomain (ppp118-211-192-66.bras1.syd2.internode.on.net [118.211.192.66])
	by mail.messagingengine.com (Postfix) with ESMTPA id B822C10312;
	Sun, 10 Mar 2019 21:08:13 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 0/4] mm: Use slab_list list_head instead of lru
Date: Mon, 11 Mar 2019 12:07:40 +1100
Message-Id: <20190311010744.5862-1-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently the slab allocators (ab)use the struct page 'lru' list_head.
We have a list head for slab allocators to use, 'slab_list'.

Clean up all three allocators by using the 'slab_list' list_head instead
of overloading the 'lru' list_head.

Initial patch makes no code changes, adds comments to #endif statements.

Final 3 patches do changes as a patch per allocator, tested by building
and booting (in Qemu) after configuring kernel to use appropriate
allocator.  Also build and boot with debug options enabled (for slab
and slub).


thanks,
Tobin.

Tobin C. Harding (4):
  slub: Add comments to endif pre-processor macros
  slub: Use slab_list instead of lru
  slab: Use slab_list instead of lru
  slob: Use slab_list instead of lru

 mm/slab.c | 49 +++++++++++++++++++++++----------------------
 mm/slob.c | 10 +++++-----
 mm/slub.c | 60 +++++++++++++++++++++++++++----------------------------
 3 files changed, 60 insertions(+), 59 deletions(-)

-- 
2.21.0

