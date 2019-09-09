Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05FD0C49ED6
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:07:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE32021924
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:07:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bfQesemg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE32021924
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53D676B0007; Mon,  9 Sep 2019 13:07:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EE276B0008; Mon,  9 Sep 2019 13:07:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4040A6B000A; Mon,  9 Sep 2019 13:07:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0234.hostedemail.com [216.40.44.234])
	by kanga.kvack.org (Postfix) with ESMTP id 206AE6B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:07:53 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 854A4824376D
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:07:52 +0000 (UTC)
X-FDA: 75916014384.04.fly06_7eead61fb512b
X-HE-Tag: fly06_7eead61fb512b
X-Filterd-Recvd-Size: 4172
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:07:52 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id q5so9527192pfg.13
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 10:07:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ya4un5YA0owQideI/MnR/HmIg6HIggVszRA4CHgSJSk=;
        b=bfQesemgwud5nizYMr1grKMmyrd48AgVHvSmTFX3YLhGq0ftejWHsv0MINm76i5tkP
         ahjuoLde76YMxLrU1imGriyhbxPRckv3CgiLiKghA4Ow3ZSAKJ/SFNXK1A/Tn6JSxxd8
         EL2G4o4aTG8clSIR2eJcmlyL0oTxrRNm+IkBFr4HgVPUEbNRhRqD7ThhU/2cywFytlKz
         R0FYTZ2ee5UrKVBHhtCWuB8RZlfZK4B6Jzq1RMpiy+nVfVTJ1Z62J9AEpxgzcfcQrA76
         ZQGZvEqkfT64cI12flI8eZotZPdJaIuLl9y0HGAf/Xdkg+u82EyIkDTKT2eeHjrcOdtv
         UH4A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ya4un5YA0owQideI/MnR/HmIg6HIggVszRA4CHgSJSk=;
        b=K1kDNdunwYzX3jYJRFjWyKG2LAKgFb44J+mPF3sXp8Ym4hpTingb0GRjZsdPYn60fd
         jiJvxZi9lY9WfugkB06hmxGG+wzI99nSR9E/aFI5IL3+o5vIwO65Izl8XfM+YU7c+5PZ
         1v7QeFiUk7opBvjQ/RHk9Wt/xRg0XXkgjeZoT7CSgWM6RA2+k2LUchzYA3JMDccgzT4N
         HtXKY6W8g6RSSDk+51pKSHDTgBXQ7KN9l9qbUJFVuownWOyxM/TX2DE0g+Dl+0BUyt5O
         povrY/71c/Fdikg+ncwfhIDa14ZIbvE5JJRFon0ny+OgjjC8W2nfyvmEkzJ7HrZfevP7
         Wcrw==
X-Gm-Message-State: APjAAAWlbhcYAZ29ZwTHNKNH7fxci2aYgnj8cGwhXl1ZD0WC3UXlt3wY
	BzI0TsXlBoH+IhojqO7Dfh0=
X-Google-Smtp-Source: APXvYqz3vBlQUNXO/ZoZ7N3F3CgJYvVeA+Owe2P7RRBLPpKBiWdjqh2EzcIQTKhtuKJBDyw0X+BTtg==
X-Received: by 2002:a62:1cd2:: with SMTP id c201mr29332690pfc.51.1568048870991;
        Mon, 09 Sep 2019 10:07:50 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id b18sm107015pju.16.2019.09.09.10.07.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 10:07:50 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v2 0/4] mm, slab: Make kmalloc_info[] contain all types of names
Date: Tue, 10 Sep 2019 01:07:11 +0800
Message-Id: <20190909170715.32545-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Changes in v2
--
1. remove __initconst (patch 1/5)
2. squash patch 2/5
3. add ack tag from Vlastimil Babka


There are three types of kmalloc, KMALLOC_NORMAL, KMALLOC_RECLAIM
and KMALLOC_DMA.

The name of KMALLOC_NORMAL is contained in kmalloc_info[].name,
but the names of KMALLOC_RECLAIM and KMALLOC_DMA are dynamically
generated by kmalloc_cache_name().

Patch1 predefines the names of all types of kmalloc to save
the time spent dynamically generating names.

The other 4 patches did some cleanup work.

These changes make sense, and the time spent by new_kmalloc_cache()
has been reduced by approximately 36.3%.

                         Time spent by
                         new_kmalloc_cache()
5.3-rc7                       66264
5.3-rc7+patch                 42188

Pengfei Li (4):
  mm, slab: Make kmalloc_info[] contain all types of names
  mm, slab: Remove unused kmalloc_size()
  mm, slab_common: Make 'type' is enum kmalloc_cache_type
  mm, slab_common: Make initializing KMALLOC_DMA start from 1

 include/linux/slab.h |  20 ---------
 mm/slab.c            |   7 +--
 mm/slab.h            |   2 +-
 mm/slab_common.c     | 103 +++++++++++++++++++++++--------------------
 4 files changed, 60 insertions(+), 72 deletions(-)

--=20
2.21.0


