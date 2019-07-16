Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CE1CC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:27:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8BE72173E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:27:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZZcN5b+L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8BE72173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B3EA8E0009; Tue, 16 Jul 2019 11:27:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63DE48E0006; Tue, 16 Jul 2019 11:27:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B6928E0009; Tue, 16 Jul 2019 11:27:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 111478E0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 11:27:19 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d6so10333328pls.17
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:27:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=HxedKsOlRoMuH0YAi3w5n8XgUhrmrip/11U2C/L62+s=;
        b=hz0uLstSXtYXysVMeYmzlayefepKbpIbtCPNnN4b1n6Fs7dbmmyhGIHLC2j4fz8/ZM
         J90h4jcZL56xKyLJtCiOlL1QJDgFiKbG8fHyoZNLmnpx0K/lZ23+9diLPM2ZN/r5t6hA
         FH52yqGUc3RUf6lrF/PkYJVepTeDn/IPoCMjhUpfvOXpLBOaVsnDvymnKL2vDbVCP52L
         L6dXqwvMh7t4P1kBBuHyiKM+ocX0bvcuXzhVUTSpBqz6O5EFOv8Qe73LlLCev5OrfmyO
         wbI/rlsMmVp3QxdHqsVnwnNJqdYSblA8LlD9bhsS3wXLnwdPAAdLseAV1uFALZMj2GyM
         L1gg==
X-Gm-Message-State: APjAAAUgyl3nEyIB2OJM0M+L/395dgzCrt19k0scnqp4oNQfVpCv1aRh
	1hgGrHDjajlr1x9Z7riRAOL7mauWzHx+d1EzYWfNkAhmsHKFQhywvJwVeKbH8dq0FIqRhnFcfLO
	L8stmzhTtUkWi6A+/KpaEZVnqpuFVDGduUJ6i7Xe4FN62OTGpXcMv4UNcJQZrBlqIHg==
X-Received: by 2002:a17:902:1003:: with SMTP id b3mr36954352pla.172.1563290838658;
        Tue, 16 Jul 2019 08:27:18 -0700 (PDT)
X-Received: by 2002:a17:902:1003:: with SMTP id b3mr36954216pla.172.1563290837645;
        Tue, 16 Jul 2019 08:27:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563290837; cv=none;
        d=google.com; s=arc-20160816;
        b=TaaXMJ1RJnf6lZQS/hA9UMB/wxw6IlI8yYRto6qvGzNeHTIdNveCGNuEuUXp2IMism
         4UKQ9tue+oke38VO1QgFfMb/pHh90vGQj3N6RTIZBkG/yTaM6KdWeew4kLAcmdDe+R7z
         EQX2ZY4t5Ta6rcDN7b8MdnmyPSM9AJXQyh/5Mfi9J+RMOexOVXK8frx9fvZg0fjoPwyp
         AQVjtWpeh2i205zJNYg5L7BsIRhrrc3OH7WEb/+vyHOD6LMKlHgPyeAqT+s0Lnr07rds
         iWXcRR9Acyg1S/54vrwjdEsD/j/jM5Kk9V54Vwo6ScIvY2QzknFDJLBGuIhfiavQTSZR
         dR5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=HxedKsOlRoMuH0YAi3w5n8XgUhrmrip/11U2C/L62+s=;
        b=FL3rb+CtS07xpvkl1+BmVuOIKPzogWkZ7Rb87NABDG9iMReW35Z+BXfAhtjWDUUU2V
         B6c7vn/eCWaD8SjuFGjtpTZF2n+FuCXxHLM0SrDjH6o8iyNXnK2TBwwTRSDgn2ZQlVR5
         KLcJ/OTDE4eiN/Emtx3rPodh7OwNrojjP7zMuJORTrMBtJpoQcUIV8I3jYQSlU9wONhB
         4DWxaM2nlezJVp10TkpYOdpKmxcuqwy9ePJj2vMJliTJMLV8CVITUYxQfK08dJrBM8qL
         LkFdP4q5FuGwwqyZeOBGMvuOtbA4WdNx2L1Iw+saTajQewLXEshx+e6czzD8nvIPX83M
         phvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZZcN5b+L;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r11sor25565641pjb.8.2019.07.16.08.27.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 08:27:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZZcN5b+L;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=HxedKsOlRoMuH0YAi3w5n8XgUhrmrip/11U2C/L62+s=;
        b=ZZcN5b+L7iWZo3iArIcmAzXPEGsGU2NeexpNaf6SNsgDDLXVphrRU+sEQ/hrnLmpHJ
         8xzFTZLinKyISv9p9ErZE3Rpojfjh4dJRIelGwba8icXvxJuBnCo/uVUVCOp0JOWEnw3
         fpn/IitK8VLeIrMfR/WNCF4sRuf9xqZGibk1xdzmDjl6X6/Nzp/m9GYv5ocHES1YT9cM
         8jX7ZPtCUIg4kAocab0gZTzzbVghHoApiZU6YzVtvvDUrnqV4CjJrnuf1Q6gBGHlKEp8
         v2pI43Vtkp2slOxzSVSRCwd94hwjb22RBp8pJHGbvN5pHST/X8YUNxvpEIAlNjWh1hND
         a2wQ==
X-Google-Smtp-Source: APXvYqweQYeGtHEfqywtbTQqGntIQfKXECduapNMxbzT+2waGPhyg1ck1l+5eDii4IS1zlf522DXDw==
X-Received: by 2002:a17:90a:37ac:: with SMTP id v41mr35699482pjb.6.1563290836876;
        Tue, 16 Jul 2019 08:27:16 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:bf0:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id h9sm27453651pgk.10.2019.07.16.08.27.08
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 08:27:16 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org,
	willy@infradead.org
Cc: urezki@gmail.com,
	rpenyaev@suse.de,
	peterz@infradead.org,
	guro@fb.com,
	rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com,
	aryabinin@virtuozzo.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v6 0/2] mm/vmalloc.c: improve readability and rewrite vmap_area
Date: Tue, 16 Jul 2019 23:26:54 +0800
Message-Id: <20190716152656.12255-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

v5 -> v6
* patch 2: keep the comment in s_show()

v4 -> v5
* Base on next-20190716
* patch 1: From Uladzislau Rezki (Sony) <urezki@gmail.com> (author)
  - https://lkml.org/lkml/2019/7/16/276
* patch 2: Use v3

v3 -> v4:
* Base on next-20190711
* patch 1: From: Uladzislau Rezki (Sony) <urezki@gmail.com> (author)
  - https://lkml.org/lkml/2019/7/3/661
* patch 2: Modify the layout of struct vmap_area for readability

v2 -> v3:
* patch 1-4: Abandoned
* patch 5:
  - Eliminate "flags" (suggested by Uladzislau Rezki)
  - Base on https://lkml.org/lkml/2019/6/6/455
    and https://lkml.org/lkml/2019/7/3/661

v1 -> v2:
* patch 3: Rename __find_vmap_area to __search_va_in_busy_tree
           instead of __search_va_from_busy_tree.
* patch 5: Add motivation and necessary test data to the commit
           message.
* patch 5: Let va->flags use only some low bits of va_start
           instead of completely overwriting va_start.

The current implementation of struct vmap_area wasted space.

After applying this commit, sizeof(struct vmap_area) has been
reduced from 11 words to 8 words.

Pengfei Li (1):
  mm/vmalloc: modify struct vmap_area to reduce its size

Uladzislau Rezki (Sony) (1):
  mm/vmalloc: do not keep unpurged areas in the busy tree

 include/linux/vmalloc.h | 20 +++++++----
 mm/vmalloc.c            | 76 +++++++++++++++++++++++++++++------------
 2 files changed, 67 insertions(+), 29 deletions(-)

-- 
2.21.0

