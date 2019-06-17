Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1CEAC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:51:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7518620848
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:51:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TQ+sGkca"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7518620848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20A738E0004; Mon, 17 Jun 2019 04:51:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16C038E0001; Mon, 17 Jun 2019 04:51:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F27328E0004; Mon, 17 Jun 2019 04:51:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA3888E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:51:25 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w31so7297344pgk.23
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 01:51:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=gCvopVOfobmQuesAHChPgfYpOIfGb/WLFM1WRDKCe3s=;
        b=Z/0uo85IYmrTo3sxg3RDTkOaA+Y6RBYeDmeICRXw7oUs//w7Nml7s+VaehCnOWv7K1
         Du0Q9N5j3z/mxSDPPzlR7aYQEA3Hu5wg6oZ83A73jAu5N5Al6YWbKh9WXBhEMe5m8CDx
         UMzOC3D9iyKsbQsLdThGWhif3cC5sQzdjPr+gi6Sp0Ag9WCZMvj1PiPf5lYjQ0ixQwWM
         AYa93Uejd/rn0hzoNjb2IoSvaY3N2YSSueuU9cj/ryiSXw8DbMzUujMYALjDRoH1LXwV
         Tuhw0DgtSbssLwBB7C6jtFs9z7/79kCTWVHLm4nfNotFJ+dVyClR7V5/iCdYyEK4BkHb
         lI7g==
X-Gm-Message-State: APjAAAUaNszr0/oIZ8IFLI7vxCq73YeBPwlZ9xE1PwUiXpwcMBRhm+Nk
	ykISXRxDGWwgKdCPE0rVoRbkQ0wsQANOsMIG1sibLC7NeCSyVBaG4+OZjKbAaZmTbx3bK4hChJq
	Qzi8hOidyboqVwSjgT0pPufmhJsvhrK11IbUeRYKsnVZguwzagHQes+PEFWczTEM=
X-Received: by 2002:a63:c0e:: with SMTP id b14mr29461689pgl.4.1560761485234;
        Mon, 17 Jun 2019 01:51:25 -0700 (PDT)
X-Received: by 2002:a63:c0e:: with SMTP id b14mr29461654pgl.4.1560761484455;
        Mon, 17 Jun 2019 01:51:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560761484; cv=none;
        d=google.com; s=arc-20160816;
        b=G7nGGiQZh0Nzpwlt9GRl8RasZreM698JAPbcLs45tNqjEQba+zYC0l5085ZJPk/idJ
         ZD/bfNRCs8Yi01hNkdqZUUxSj30GvPK+OKt3zFIBnnNEZAKAX/FxgUxPGbQh7s80CslA
         ZhYr1PKiZa+8jto6PNluFmEBRC21EPy+wrsufgvI/OBLtwEH+ZkCC60awIIeRzWt3kBj
         iLV0yYUwhn+robHiUHHFZw6QAubqHkaFJVPQP1ezu3JrSuvO7KvkND58uSd16KGt+mHn
         jLItMvPM0rhFbEnU+WxseGlBhzqzDdo3VQIhDgpz9FIJ0VPUr15Vpbi4Icxvn9JB+Q6s
         8LOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from:sender
         :dkim-signature;
        bh=gCvopVOfobmQuesAHChPgfYpOIfGb/WLFM1WRDKCe3s=;
        b=YE5jiy/2swLlMP0zfIZUTJvoCOb60abl5K6d3wHl3/9VuoI8nRi8e/NPsz0O6zY+/2
         je5gjDyzuGcjNcU2YQZZmBXThW9sBv8vbwFjL15bp1An4O4MFR7pxyRQP08JJ0v/bH/o
         k4fMZvQ/DVHTUTa3CLfYgCi8Hr7B72wddlStMEVbSBgG1cjJWKZsTRYcns9YmGbO0lEs
         gcvPc5/wnx5kft8ngWikrwxg5sOwyQXsitj7fsxPqD2tQz203TPIxfI1xpyU2F/iyhaF
         4qrktts1TLLxH049MQG45u80j8xC//U23k1tv1svjirAYHp0nYi/+3Jqnc1IfXVbjSrf
         Tw3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TQ+sGkca;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s20sor12797679pji.27.2019.06.17.01.51.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 01:51:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TQ+sGkca;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=gCvopVOfobmQuesAHChPgfYpOIfGb/WLFM1WRDKCe3s=;
        b=TQ+sGkcajXwECm/kdggg7cStsdl/xrIv8JRcqDarn1eaKV7HpTpxHzFzmPiIO2veOO
         NmpbhXs8RgDzXFSLCanM9x0sn56F6UQVYzSYsvB88xIbnF6xNaYVN35CkuTkAwv6n7pO
         xlu5R0Gek1L3rI1EDkXJ5jxpl6GjWfKyf5H2zX0f8p5/gIj388t9qbiQSldmzqNLir3S
         RFKt8jwMNaOq5RK1kXkiKeb7nbbttkg0NiAdQ9NiR+WRljT7VHaQ4pMslTPu4rawhAq0
         b1flMfAfDPePnHunFaWJYDrf31uZBnto1a44HkHR4QonqpMRJ9gJK9c1y3yWNQDTPQfB
         jtHQ==
X-Google-Smtp-Source: APXvYqxZ6jAOFq1a/yScy7F54rqF0AQdZ/ngI0YkSFJy9ic4uyu+tAExO1MnqQLZocW0LQnt2P4/jA==
X-Received: by 2002:a17:90a:be0a:: with SMTP id a10mr23682369pjs.112.1560761484028;
        Mon, 17 Jun 2019 01:51:24 -0700 (PDT)
Received: from www9186uo.sakura.ne.jp (www9186uo.sakura.ne.jp. [153.121.56.200])
        by smtp.gmail.com with ESMTPSA id d4sm9443514pju.19.2019.06.17.01.51.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 01:51:23 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	xishi.qiuxishi@alibaba-inc.com,
	"Chen, Jerry T" <jerry.t.chen@intel.com>,
	"Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
	linux-kernel@vger.kernel.org,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH v3 1/2] mm: soft-offline: return -EBUSY if set_hwpoison_free_buddy_page() fails
Date: Mon, 17 Jun 2019 17:51:15 +0900
Message-Id: <1560761476-4651-2-git-send-email-n-horiguchi@ah.jp.nec.com>
X-Mailer: git-send-email 2.7.0
In-Reply-To: <1560761476-4651-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1560761476-4651-1-git-send-email-n-horiguchi@ah.jp.nec.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pass/fail of soft offline should be judged by checking whether the
raw error page was finally contained or not (i.e. the result of
set_hwpoison_free_buddy_page()), but current code do not work like that.
So this patch is suggesting to fix it.

Without this fix, there are cases where madvise(MADV_SOFT_OFFLINE) may
not offline the original page and will not return an error.  It might
lead us to misjudge the test result when set_hwpoison_free_buddy_page()
actually fails.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
Cc: <stable@vger.kernel.org> # v4.19+
---
ChangeLog v2->v3:
- update patch description to clarify user visible change
---
 mm/memory-failure.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git v5.2-rc4/mm/memory-failure.c v5.2-rc4_patched/mm/memory-failure.c
index 8da0334..8ee7b16 100644
--- v5.2-rc4/mm/memory-failure.c
+++ v5.2-rc4_patched/mm/memory-failure.c
@@ -1730,6 +1730,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
 		if (!ret) {
 			if (set_hwpoison_free_buddy_page(page))
 				num_poisoned_pages_inc();
+			else
+				ret = -EBUSY;
 		}
 	}
 	return ret;
-- 
2.7.0

