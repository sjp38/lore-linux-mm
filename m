Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 491E5C4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 01:27:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C6312171F
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 01:27:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dYDodNZN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C6312171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91F776B000A; Mon,  9 Sep 2019 21:27:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A80A6B000C; Mon,  9 Sep 2019 21:27:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76FA86B000D; Mon,  9 Sep 2019 21:27:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0235.hostedemail.com [216.40.44.235])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8636B000A
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 21:27:17 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 07EBB824CA2E
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:27:17 +0000 (UTC)
X-FDA: 75917272914.11.train96_79b9f7a59f91f
X-HE-Tag: train96_79b9f7a59f91f
X-Filterd-Recvd-Size: 4350
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:27:16 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id y22so10530825pfr.3
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 18:27:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=htVKbWpEm9QB8qGdRGMXDAO+pxBcl0ZnD2WqCc7LzfU=;
        b=dYDodNZNZBL5k3zCSxOWdPRcFUyUB01dhilO31VRCQCWzNTMmGKwgRqx0ezOfDNyAW
         Xam9LqMjWHWhmXYZ+UyPClwkIDonR2TO65P68AgHwdI+LfXGtXhOV+odbW27EuJiV4SP
         XTvrH2cyaxDU5S7EOTZIh8ZgmIO9Vta9yYvLfVVzJ6tPL8MOhtJkVxJZPSFFuj67j8ht
         keJg435MhybFE/gLA3crGRYdZ2lA8uk+6OFVaRys6lrMlTQ3wlHysXZ6BZlWF0dXyJBy
         7keLQZaUsd4mzy4NYzg79RUQWhi3PbxSlYR1MYRG7hv9PUI8MXdUUzjCGpUVkyRvCYwr
         iBag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=htVKbWpEm9QB8qGdRGMXDAO+pxBcl0ZnD2WqCc7LzfU=;
        b=qRtZV5x5439CdlMbrYcXzFMMicQKX558WM/oQgGlvid7nwiFWea1Pla6efPOGjxybx
         x2w8BuHTRhRu2uUIruG/kiwGPkbyB186vjTEkhF36VwkW3PHPuucCy+k3PL5i0k/NbmW
         6GtZSjfOuYDzrlmuSRIVsFOL1oFY4FpfoV16ehA9bsWAPHubCiuifKfwVVm6nSZaoM5K
         IWMIaU+s2TwZbZutGKL1eDYsLFB9GSGw4GmT4MvQHA5lKZ9Q149nj5xdpTptY+SlaOcC
         lwv1NeubGCncfl60yFi/MT/kV+dIZcin71s13VAzpxqB3s3sF80CXuQrfoAa5INn719F
         LY0Q==
X-Gm-Message-State: APjAAAX7hHf+fe/5N5dRPLQjwMtfVf7x/tuqulgKBowNDq1WHzjbBPqp
	T/JSnNhp9hwAczGcr8Qbch0=
X-Google-Smtp-Source: APXvYqxUIk1rV0t0iVtAqOPrGBZ2YrYBDkkoRIbbfvd0laZuVU6CmCAT86RnUjmrgQPtc1DrgI+F5Q==
X-Received: by 2002:a62:f246:: with SMTP id y6mr31513531pfl.22.1568078835198;
        Mon, 09 Sep 2019 18:27:15 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id b20sm19558629pff.158.2019.09.09.18.27.07
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 18:27:14 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	guro@fb.com,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v3 0/4] mm, slab: Make kmalloc_info[] contain all types of names
Date: Tue, 10 Sep 2019 09:26:48 +0800
Message-Id: <20190910012652.3723-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes in v3
--
1. restore __initconst (patch 1/4)
2. rename patch 3/4
3. add more clarification for patch 4/4

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
  mm, slab_common: use enum kmalloc_cache_type to iterate over kmalloc
    caches
  mm, slab_common: Make the loop for initializing KMALLOC_DMA start from
    1

 include/linux/slab.h |  20 ---------
 mm/slab.c            |   7 +--
 mm/slab.h            |   2 +-
 mm/slab_common.c     | 101 +++++++++++++++++++++++--------------------
 4 files changed, 59 insertions(+), 71 deletions(-)

--=20
2.21.0


