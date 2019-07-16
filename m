Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 356F6C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 13:26:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAE8320693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 13:26:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O85w6Uft"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAE8320693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A26A6B0003; Tue, 16 Jul 2019 09:26:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2527A6B0005; Tue, 16 Jul 2019 09:26:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 142218E0001; Tue, 16 Jul 2019 09:26:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFEEE6B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 09:26:42 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 21so12355555pfu.9
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 06:26:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=iNuXYfJpH7xodxMP8TOSGp32e8S4xkphHFsCZYElfVY=;
        b=XZwZtr40WJC06cY2yCwMLefnvRY3YZRIQbd6Oc4zVUGKH66DbSSEL4h5jrZxpfWnVC
         eREbQ3mHTvJNKSxIixPinXoZ+KqK2O1eRo4FHglsaB7FNOQ17EVo1S7m8GKx3ry3id4d
         UwgWNvsvJE4lXERPNPfc/NRDxMcwzPVsqNfCQ/goFYrn4HdmTJVfbSe56ax6sBboNAXq
         yhCc5g1qTIa9eLUa4y32m88fCQ8ijhum4e84X/9WF1vnP8RGIPo8KRKZ7j+IIHyVmUWu
         gk/SrSrd3xwPR4DQJoYtaE6jlwVS3f6l5fsN6txWLamWq43WCEvdfKg4PKf8Y1Zba42e
         g5Tg==
X-Gm-Message-State: APjAAAXUaCCS+M0OCC+xQhBujn0RE0AendjdPa1LIEC9fTkSfYTmvMtj
	M2r281FF49XzttEgGG9MXas8UZLo77R1LHer7nMthYL7L9T4PsN5p+AwGK0vUVCwykBsD03JeqW
	ZPrfJR7MaHHz57NqxyPg0Yp0dmLiTIe8arqLQlg4Dx2FEnVVbiMvyW02eZsUYl3Lnvg==
X-Received: by 2002:a63:608c:: with SMTP id u134mr32174539pgb.274.1563283602331;
        Tue, 16 Jul 2019 06:26:42 -0700 (PDT)
X-Received: by 2002:a63:608c:: with SMTP id u134mr32174400pgb.274.1563283601124;
        Tue, 16 Jul 2019 06:26:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563283601; cv=none;
        d=google.com; s=arc-20160816;
        b=awkfwPOXydl3BWXLLzDpGZcCALoKCcjgoI7sw+AurpZF7ZfKVtKFI/GkQmCc9QFNKY
         F7L4mQYnbzOX0WlnBO84YSPpq8yIN6LgQFXBVsQXqtavIqndUZQ5lmy+3FeqfXsxlSxm
         OkGeZlXe6iPyWtn3IOKEn1BKS4gfIVdDT4h2wv1lZUvLG75jYkAOMkOIC81M7/9TcbPz
         yzt2VHrlGfG0T9NJFwhDp68hzz89tNCY7P7MIrpbK0QJchAP7iBd27hzfJMqgTJRQORL
         QY9HnQNfSuVGbe/Z59wVf8yKZrsvlr9hwJz8INlzx+sdau59I3LykGFXahnptggZSzmM
         BdPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=iNuXYfJpH7xodxMP8TOSGp32e8S4xkphHFsCZYElfVY=;
        b=BoaFBpgS4bF4xDjG1QaZJe2aJNgnw6tOikujIMa/47Zdvwn83Lh/AVIqt4WSmh23P7
         GLt7hfvwjuMOAMYCz/17oxcwSsqWRgKhBvYV30c3dOqkNsOtWPnXfGTcp2ZqGiW/4GeM
         Tm8gryjI99+HJ9GdSlJNxqeV9cqAFIrk+iEFJm9Q3JnzCXYqXTunQfS3e+uaVpPUfszv
         HD4KKEHZEA7wRdMt56AtxHNpiTllpT4HiZy/8Sg1kO+/9ulZeDwhSYlK6h7OlsZkQo5k
         7GACCbNRrtDdG2wYO1AS5oQut2FmjfaySQowy7X4MAjc8fOPjVZZNF7iSESv34lz53R6
         H1QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=O85w6Uft;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 123sor11052775pfu.0.2019.07.16.06.26.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 06:26:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=O85w6Uft;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=iNuXYfJpH7xodxMP8TOSGp32e8S4xkphHFsCZYElfVY=;
        b=O85w6UftvzCE5S7QNcUPHTwRK89UOIVN5UwkFUBVkoJlgzFkrecIe1HCHZxp8XpTpc
         LUsUclB+E0i+ylxp3D4lng3UpJtIw1gZXPwBcCaJKcOivr+2o+5GI9PbWUU8w2l4ssaM
         Qtr9x++RI1Bqm8fFQo7D8JkNWH1KOLvF6koLHwDvY5GzS6HhmQNvb3lah7Oib81HpAUW
         H5STE9MUFYLpzD/VPToXLQZvmF8aqc9g44wgHJrkD0G6zhs92+jqI5ntp2oCI5TampeZ
         K+RZc+cL1r1vBvh6vYS5CrrUA77bkwWs9B5APzX0SBgrGjo3Rvd1OWxrYMsqirI00fIB
         Npbg==
X-Google-Smtp-Source: APXvYqxMR+qcGzM00MAIReSnrdIh/7uLycc7Pudrqz68yEXSZKY7d3bokAlFxAcJq29ZEfJxTtL3OA==
X-Received: by 2002:a63:6eca:: with SMTP id j193mr33082479pgc.74.1563283600675;
        Tue, 16 Jul 2019 06:26:40 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:bf0:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id q1sm21472311pfg.84.2019.07.16.06.26.33
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 06:26:39 -0700 (PDT)
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
Subject: [PATCH v5 0/2] mm/vmalloc.c: improve readability and rewrite vmap_area
Date: Tue, 16 Jul 2019 21:26:02 +0800
Message-Id: <20190716132604.28289-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

