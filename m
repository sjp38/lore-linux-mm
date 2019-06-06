Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 442E8C28D1D
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 12:04:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D7D9207E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 12:04:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qu+Kyycs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D7D9207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B9FC6B000D; Thu,  6 Jun 2019 08:04:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 969FA6B026D; Thu,  6 Jun 2019 08:04:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 881326B026E; Thu,  6 Jun 2019 08:04:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 209336B000D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 08:04:26 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id c25so480126ljb.3
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 05:04:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=VVA1sBKfaRg4LAK0uCbWUTy67eDK44ZySJJKqojIYWk=;
        b=qibOxBNOcwdySZf6YPC0c0yrF+kGWOXcOIAFZK89ZpRj/g9VD2ssyyhNdI1swGyu3i
         aCmSwC4XjccxZQEHINs19WzIJvVoNqJb+bulQFrVO8En6iqMM96V/lQ0o9RLebrAe+QT
         mV+RWn7F+ckNvqbg66//12BIhnZ0d0VheLGjC/1IYUI8ySjCGaIaqMs1VPoctBCjYwpc
         yNgFh4GAz7Dai49Pvyv6J6RiDkY0Zb6DLZlp3jz68tFASUc2/kaHlX1dt+qr4muuvX58
         3B8EHs/M9QPvdmlKwmB5TzmhMQwKHQDY+ZoWoPCDwqW3W8Sa8zOh2My0MJSKpluZlWxn
         z0bg==
X-Gm-Message-State: APjAAAUk2NW429LxiIOfn2Li4o2OOQnBcp4IYFVDBeW64PzPzwA6i7CE
	vsinWuuE2Fjx6jfgP8wqvMG77SOK7TYvkcHCVu7anwPdoA4vfS/HkM77ikhG0lYKj0D2iNu2BkO
	iJ9vNMWvz7if5OO36zhhu+QYUi6LR2nKqnQlN/rp6XqYoYRTJdR/7BKqAvaCB5EsSRw==
X-Received: by 2002:a2e:81c1:: with SMTP id s1mr8854212ljg.103.1559822665402;
        Thu, 06 Jun 2019 05:04:25 -0700 (PDT)
X-Received: by 2002:a2e:81c1:: with SMTP id s1mr8854117ljg.103.1559822663695;
        Thu, 06 Jun 2019 05:04:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559822663; cv=none;
        d=google.com; s=arc-20160816;
        b=dDYZChKtTsddtAZAjcLzDmsoJ4VMP8+p3pZy6IbiOCfDTpv7rbp3b8lA/wOTu500/h
         h0sV++fVmwxPzAFWs1nTCe6SLA9eEnMGAsCVrqSPKpEK7qcps4qYMGDSyPJA6RSONRGe
         ao1vKktDnmJZp8WuPLKTXNB9izkQ328iDj+EDGEx796o6CFPlUQ1jR5gJ0QI78VhMlRs
         xxjd46QecelqU0SPH/Rh8axaYGWW27oS99WdRLXr/TjQsdy2XAcDiNuYRz2kcBCJ7ZD/
         R4dTGYGXCPG2zb/TgDwP348wZi0c5QrejjZjIwgzyL6D7Uex1vMi0pHUSbVXBDf3hHes
         AvHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=VVA1sBKfaRg4LAK0uCbWUTy67eDK44ZySJJKqojIYWk=;
        b=B0niRISJhfwfE8xcLnRYajpypV90zF84QLQStt1ImzhQr4TZ9cjS8gDFFTgWRy8DPN
         TYEi66AwmMI9aOfymmhtm3cZBhUwABirx57ZsQkZ+d6RQTepwYOTaUJWjeEe4XFkc8Pj
         Gu/01TgUY0XpOVTb1O9usyPIz4iY01zx5iDHhju5All/4kr3F6XNIrZ45stzaJOyEdPy
         kM0cZX6E765rxCmxbB0P160sVCrM7RmPnn3ymQ5CyrdXWPyIOUIDSNhm5tm9nMfgx1Sf
         c+e76musm480rPW3wpDkML84aKa5UZACbSg9/5heYchReJ0liMbuUT7CuBQVWf/WOOST
         XDcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qu+Kyycs;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6sor1043479ljk.17.2019.06.06.05.04.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 05:04:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qu+Kyycs;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=VVA1sBKfaRg4LAK0uCbWUTy67eDK44ZySJJKqojIYWk=;
        b=qu+KyycsiKB5H0DVZc1zgw4MCI9LyalwWjcXI8qkPcLtMJjQiwz/0glLYdyI+MP7Hy
         y/nA4L6p2EgYW/fYGhiptMUltMUmA+1j3Ks/i5EGUbT8Zfy+aH8H0hnEchW80QQ0+WJA
         JEmhu6B/I7OEvcJxnR8DgpvWBKVeueyOy3whTiA6TzPpF1IIEm6+6QtqXqm+lDIey/I2
         3YnHLghk21E+RQ/tBlHnrvL5batshl5zttiKnNGZxZWrQA3x4r7l+eLRZVTxdBFspj6j
         gE4dEWg6hJ3+c5uS14T0b0CFUl5HYMRo/qayxwT2iUAYzqqpyIfIFR1w2NgtEq674dUs
         itEA==
X-Google-Smtp-Source: APXvYqw5NsxmFarYoS87ELBeow1UTJ+6nrV64ACjRY5wOWzr1dHJz3NiqdcF6n9Dn1psQiM6BlTViA==
X-Received: by 2002:a2e:95d2:: with SMTP id y18mr123396ljh.167.1559822663131;
        Thu, 06 Jun 2019 05:04:23 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id l18sm309036lja.94.2019.06.06.05.04.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 05:04:21 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH v5 0/4] Some cleanups for the KVA/vmalloc
Date: Thu,  6 Jun 2019 14:04:07 +0200
Message-Id: <20190606120411.8298-1-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

v4->v5:
    - base on next-20190606
    - embed preloading directly into alloc_vmap_area(). [2] patch
    - update the commit message of [2].
    - if RB_EMPTY_NODE(), generate warning and return; [4] patch

v3->v4:
    - Replace BUG_ON by WARN_ON() in [4];
    - Update the commit message of the [4].

v2->v3:
    - remove the odd comment from the [3];

v1->v2:
    - update the commit message. [2] patch;
    - fix typos in comments. [2] patch;
    - do the "preload" for NUMA awareness. [2] patch;

Uladzislau Rezki (Sony) (4):
  mm/vmalloc.c: remove "node" argument
  mm/vmalloc.c: preload a CPU with one object for split purpose
  mm/vmalloc.c: get rid of one single unlink_va() when merge
  mm/vmalloc.c: switch to WARN_ON() and move it under unlink_va()

 mm/vmalloc.c | 92 ++++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 65 insertions(+), 27 deletions(-)

-- 
2.11.0

