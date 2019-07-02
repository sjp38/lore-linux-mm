Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6199AC06513
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28EA920665
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bFSlFbov"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28EA920665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7F8D6B0003; Tue,  2 Jul 2019 10:16:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B30A98E0003; Tue,  2 Jul 2019 10:16:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F8188E0001; Tue,  2 Jul 2019 10:16:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 694AE6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 10:16:03 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t2so9678982pgs.21
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 07:16:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=G8tirXskpMAhNy3e7NClMztjS4SZXfLYl5ZSuLbR4Hk=;
        b=kNDsd7fZZK690aX8dLK8wsWpYdU3zPt60PoUDhjl1HwC9KtlPlIHKvS0By/x40jWu7
         +X85MflFpDQyen5efjorbk+jCF8m9d32xW9DSpvxFzFw2oPLTkPdlP3d11zTpUGPvhSz
         z6uqa7xYt8LT0+lC6wZ5o8UxVYTg51z1aCfJWm5QgdCUas/14lAaI9QV27PpO7aFhL68
         CNwQT2Y2c8dkcIYSIwpyQsjI2dfvCQRmAOqNC3JLEUR8wqbY0mce9fhxN1AvilK4tpd7
         86gXyzUG+UWgVbWby3XDIqf53xC7MkUb8RbQ3FrmebvGdOxh6EUlyBUZXFwwM3m6HpLV
         nOFg==
X-Gm-Message-State: APjAAAUSE9MgAaRdsJzq9PcYjrBNiiEePc86KGCIMDBT9CnadG3/Xii/
	WyOmDzf1NVOrOKIpJ+TjQhhoHhTbQUsaqCYcOHwkCRc5sz6CqBxa0WOfpyRNZPF5ygsoXcnWiu5
	Jr6xLVuibNQ/8wEs7m00WyTjIkh0eFZPz8xu/ujzaqtzeR2cX1oGML6dy8FhLyeq1Lg==
X-Received: by 2002:a63:1a5e:: with SMTP id a30mr2723396pgm.433.1562076962714;
        Tue, 02 Jul 2019 07:16:02 -0700 (PDT)
X-Received: by 2002:a63:1a5e:: with SMTP id a30mr2723287pgm.433.1562076961074;
        Tue, 02 Jul 2019 07:16:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562076961; cv=none;
        d=google.com; s=arc-20160816;
        b=fJihN1Juic5eR/nqZAPgoqipQpc7kapyfGXDo7C4F1chqyu7nBx0sgHRyNG6ocZqnT
         s9rzL/OiRW7idRL5KvsEaHwX+X9UBVI4/YL2ddJKUGd9nfWeRAmFytVqoPpYihsiY8Tb
         9zqTCdZ/kJeqRcSJmG+7DaICuP9lsSTVjYsrHIi+7UkcntMHdGpcmK/1QbPVgzjRyC68
         EoI7Ayo8c46cbiZSRR/xfve/9BaOwCpuCOWtuRXNuaqdyCouqNO+woQKxfEKFXjGPsT2
         3Gyb0RFBQOKPlufCThqf0lW2I/ER34jd1WrvpE+aXy/KdY0uPK8LTdITrvuCQ3/9J6va
         jJaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=G8tirXskpMAhNy3e7NClMztjS4SZXfLYl5ZSuLbR4Hk=;
        b=uSF48W2QW39J62UfwL8Ks5ymOanrBxv+w9fwv2xA+72OH5OWQifZfdBlH0CdpE3A8l
         lx8PVEL1S9SFPWqT+7PiorbtzrX+NlGuVaad1nP1ceTzBupC2JXLvHn68OBpobBAyky/
         WzPkKTO7rqJdLvbkVVstO7/BQHVf49VMjTkXgUSWlS5JfJJxQ7wvo8iprBibvB0xhOi/
         5jwCdLB6CvIdBXdguZPjtCs8gTI6l85t2fhp/WTRpKKduPqD3IYU2kPnQYE7mq3t9IjI
         SQXTtTHWvmvJeo8XseuShYVLkS4Fe0Rs4SaltuwCfg/m6O7atIM9EY9jyFTplzBl+VC1
         tKhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bFSlFbov;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor16222687plr.31.2019.07.02.07.16.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 07:16:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bFSlFbov;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=G8tirXskpMAhNy3e7NClMztjS4SZXfLYl5ZSuLbR4Hk=;
        b=bFSlFbov+AMUg7OyusaEXkDzPAaG9WIl2+j01Ib4t9nVU2vyX3V5Suc1jxvh0DMj4T
         osRX55sJ9hfdqs/H2DsXotlaYgrJsTPTosbqaFjZ5Ny7OB/oA1xRiN0mYKeLefCNUYP1
         WWAcMJ0NsOy+TwuofxTX+Y/wOx+q3P9evixECNzjly7tNVKK2hyZj6BeUQC8pkFgeI+1
         hsDXQJzau9+X19hrIKQuBv1or+rC7V/lFvHmy3SlA89akP4tMFNmfn07X+mkdDAFiKwx
         uXtGxoLd6Vjcdocc4x7bqBR8dvoBfmATuNlWtlqxVDvpR8VTTIRwE1atqvT/NAFkaqu5
         uCGg==
X-Google-Smtp-Source: APXvYqyw7rlsqOd28OgPWdKiHxN2laMuLmyw7e1ts1TJND9GEmV3gyIu2BhBR3m8wSMIlF+J6RscHA==
X-Received: by 2002:a17:902:b688:: with SMTP id c8mr35129791pls.243.1562076960851;
        Tue, 02 Jul 2019 07:16:00 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id a5sm744617pjv.21.2019.07.02.07.15.52
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 02 Jul 2019 07:16:00 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org,
	peterz@infradead.org,
	urezki@gmail.com
Cc: rpenyaev@suse.de,
	mhocko@suse.com,
	guro@fb.com,
	aryabinin@virtuozzo.com,
	rppt@linux.ibm.com,
	mingo@kernel.org,
	rick.p.edgecombe@intel.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v2 0/5] mm/vmalloc.c: improve readability and rewrite vmap_area
Date: Tue,  2 Jul 2019 22:15:36 +0800
Message-Id: <20190702141541.12635-1-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


v1 -> v2:
* patch 3: Rename __find_vmap_area to __search_va_in_busy_tree
           instead of __search_va_from_busy_tree.
* patch 5: Add motivation and necessary test data to the commit
           message.
* patch 5: Let va->flags use only some low bits of va_start
           instead of completely overwriting va_start.


The current implementation of struct vmap_area wasted space. At the
determined stage, not all members of the structure will be used.

For this problem, this commit places multiple structural members that
are not being used at the same time into a union to reduce the size
of the structure.

And local test results show that this commit will not hurt performance.

After applying this commit, sizeof(struct vmap_area) has been reduced
from 11 words to 8 words.

Pengfei Li (5):
  mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area()
  mm/vmalloc.c: Introduce a wrapper function of
    insert_vmap_area_augment()
  mm/vmalloc.c: Rename function __find_vmap_area() for readability
  mm/vmalloc.c: Modify function merge_or_add_vmap_area() for readability
  mm/vmalloc.c: Rewrite struct vmap_area to reduce its size

 include/linux/vmalloc.h |  28 +++++---
 mm/vmalloc.c            | 139 ++++++++++++++++++++++++++++------------
 2 files changed, 118 insertions(+), 49 deletions(-)

-- 
2.21.0

