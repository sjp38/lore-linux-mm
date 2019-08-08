Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09542C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:56:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE8772089E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:56:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GmtBlYGs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE8772089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A5676B0007; Thu,  8 Aug 2019 14:56:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5565D6B0008; Thu,  8 Aug 2019 14:56:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46BAF6B000A; Thu,  8 Aug 2019 14:56:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3B26B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 14:56:04 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k20so58234088pgg.15
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 11:56:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=G3NhUPjLzs7je5vt+pGcT0rtIfPFfRW8yibRORtLEaE=;
        b=Tqf3doKDkL+wQRZBWmA9BPS1RXY9q+CVW/fjoIrOAAbUARdxyQhCPzMChz/ejmu+TO
         RvopMVUK4zV3owDqg4e0c7M5jtufDjSdxScGWxTooilHitv/M1LrQ2Nw5L0q9ey0YI2i
         I7MjHbT2MUfqgEs/oY5yg3GemFjdswPhkSGBeMa8q2PfohpUgH0p0+AyZXQEOwxX1uTa
         42Q7QNFWd99BVvYIP7Igb+vu11gHmjj+c5aAfNE/tSj233yQdOrudr2Tm1H/FXbpV9pK
         VIueYIqU4ANrwS86YM1cU5eF1BkccP+yn3hqnbIXp0KnyRfMP2Ap7dEV6mP2RtpwCsHQ
         7oZA==
X-Gm-Message-State: APjAAAXg6CnrBMpLTu6d8xNYivfxKTjZ0lQsEUQwOVORmJN6GcrynOTQ
	gq57RreWArbUR+Gqw81+qWdaNTltjciWQoYRToZdhYmDoPdWQRS2w1oaggClffM1ykkr44H33O5
	MslYYvVPWDOdjf5XF3I9GY06cKOAlQHJY7AYqH+lU/5hfHXBa8aL/aOCcJjJNzHghaw==
X-Received: by 2002:a17:902:b212:: with SMTP id t18mr8686529plr.246.1565290563743;
        Thu, 08 Aug 2019 11:56:03 -0700 (PDT)
X-Received: by 2002:a17:902:b212:: with SMTP id t18mr8686479plr.246.1565290563064;
        Thu, 08 Aug 2019 11:56:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565290563; cv=none;
        d=google.com; s=arc-20160816;
        b=o3SS2duUd6meVSzDLziST2UaUqhMPEPhhv92FBUFZ6qPWnZfQ3CDwgrPx/t6ekfNob
         FI8YNuRO1FbGMaVNVYNb0qNSCRvAE90B2Rx8FrN2HVNaYCHobt/ETmyx9qmai7Obv7KA
         7fq4n9AOM3jofpWgJYIp51ad9U3zq/zJxz8wQhpjJW1TMh0YYETbRGBkNWFJim/Xo+gB
         HMe+sxmwJP3t/FYSkxXYv/LOZbwHaEBUaJ5Yuj00M8aD12DdHKci874v676LrsHw/6HE
         Op2Ha708c/hTKkEwPVQM7SiQKj+RcxKEBAt09sjXVWqha0vjbSN6EWcoZ+NtQlpzVLx6
         Ns4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=G3NhUPjLzs7je5vt+pGcT0rtIfPFfRW8yibRORtLEaE=;
        b=NO7k73wEm2woJlmDgICEgyNzXTSfbPduFqAfzsm3CVq67jGJG9a78jLszcHEn0weB2
         lwLbTmBYMrhyDzFebOifRteeLaBRFSyZsZKu0J+ZrASjts9YjqzxfCkvLTjLX8+JcmoU
         Jg6GkzBFzdoI0ve6UttHE5F3P5W67tHGuHEOgGybvMC2vrPFtoO45XEXftas4DMebwvn
         zvKGWfe7aZNBOZSofVYdI/qOZXeHt5Fb+tiaT6k6yrZYsjXibvfOyMCgiV9TPfSlD3Te
         yMrEhzfvBy/MFya0fuvGw+OFs2J9gorXMJVYZvClmZxQkNTkT1o7NaE40v9bZE5+kXx3
         JXsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GmtBlYGs;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor66971686pgv.70.2019.08.08.11.56.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 11:56:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GmtBlYGs;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=G3NhUPjLzs7je5vt+pGcT0rtIfPFfRW8yibRORtLEaE=;
        b=GmtBlYGsA+TJJPso4MWBwLNOIv7kxqHtbGEGGqRQihC5phbhEz44c5/fID7XQ2b8kA
         nGpnCLJrfrm0E3Za38bN5qNXXGIuXHPNxmuaV3jyjinaiUgicMsm/uNRAWkzgJCNullf
         sOFzjthMgOQDwGddWShCVDi7FXkRjB+LUCRFuRrfYiHIDZPUZ+9MgOrZ89t3l7kz73T0
         qWU238IWAZBP8cLKxI90V4DEtXHTY6Ta29q2A6LLm2ViP/m8LAgUfgRj1rhXo9x3eb74
         We/kf25M5AuilUYVd98hz4O+oodSFAj60tiFJoLYbEJ+QJ1s2WFgJeZ4urtLDaiZH77O
         Vfvw==
X-Google-Smtp-Source: APXvYqxrB/9uqlfCMteW9WF5sFZ4DYPJdcyvFQ6jzXf2ExJrH6J6dgl0jvx/fh8l9yzKwCOkRRROGQ==
X-Received: by 2002:a63:b555:: with SMTP id u21mr14284684pgo.222.1565290562611;
        Thu, 08 Aug 2019 11:56:02 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id t8sm110170328pfq.31.2019.08.08.11.56.01
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Aug 2019 11:56:02 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: arnd@arndb.de,
	gregkh@linuxfoundation.org,
	sivanich@sgi.com,
	jhubbard@nvidia.com
Cc: ira.weiny@intel.com,
	jglisse@redhat.com,
	william.kucharski@oracle.com,
	hch@lst.de,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [Linux-kernel-mentees][PATCH v4 0/1] get_user_pages changes 
Date: Fri,  9 Aug 2019 00:25:54 +0530
Message-Id: <1565290555-14126-1-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In this 4th version of the patch series, I have compressed the patches
of the v2 patch series into one patch. This was suggested by Christoph Hellwig.
The suggestion was to remove the pte_lookup functions and use the 
get_user_pages* functions directly instead of the pte_lookup functions.

There is nothing different in this series compared to the previous
series, It essentially compresses the 3 patches of the original series
into one patch.

This series survives a compile test.

Bharath Vedartham (1):
  sgi-gru: Remove *pte_lookup functions

 drivers/misc/sgi-gru/grufault.c | 112 +++++++++-------------------------------
 1 file changed, 24 insertions(+), 88 deletions(-)

-- 
2.7.4

