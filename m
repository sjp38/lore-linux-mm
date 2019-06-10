Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EAFCC282DD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:18:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0764F2082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:18:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pLBa7uRD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0764F2082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7674E6B026D; Mon, 10 Jun 2019 04:18:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F1FB6B026E; Mon, 10 Jun 2019 04:18:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BAE66B026F; Mon, 10 Jun 2019 04:18:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 234576B026D
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:18:15 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w31so6425673pgk.23
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 01:18:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=iNQfPT8546HoVkc+KeLP46IyhzvKWlvUhgKz4CHOiq0=;
        b=phey94xy4KiqLvm67fAcFOtuULth09pRfcFZROLcA8IjjHnVyuqhQGF0EfAQFf0SFy
         kzovVsOzcD8LPsuaXu3yjGay8rNHTU9k3YNOTt8444ivWlHaWap216VHGL1ABki43+fT
         BaQhQEZNHFzMPWKMZM3Fo4lpOI86EJp6j4oV30tUpoDrWLUJexev/QJ7U2js/5XC5yG7
         +d/1QCS/TeHZeiJ4TqycuHg0awJV/3LKXzijI7aCf+FtYQ3DkGMZdlwzB7XWSkAwMzQR
         nfLZUsuV7WHHpMHVkmmR9S1fHip14F+CJgPpMfKSiSlUEwgF2uNzX+Uw8GNASnyYfeSP
         l5lg==
X-Gm-Message-State: APjAAAXl4C5F2V+ax8w8fexHTwjj5EXRs3/VrSo+fPiDb0s8bFRYNvLO
	DydlA7bX92ttEyQIXK5OhQT389SjofxIGj/AGoDmGozq8NXWkqOPZy57g4NcBmK3zQOewIzVgL1
	gp3uXa/TxbroiTkJrWmHIryd+Ym9PQuarq5WYC+FeZwvWnrG01LtApf4Q259ERK8=
X-Received: by 2002:a62:e403:: with SMTP id r3mr41854651pfh.37.1560154694796;
        Mon, 10 Jun 2019 01:18:14 -0700 (PDT)
X-Received: by 2002:a62:e403:: with SMTP id r3mr41854602pfh.37.1560154693918;
        Mon, 10 Jun 2019 01:18:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560154693; cv=none;
        d=google.com; s=arc-20160816;
        b=oGeh089G+PzZGv1W+jRzYukcA0mQd1KH9OeKoR+OTBtIJqfoudmKZ+ESxXNe1cD9Iw
         6wwIlKqQyrKFnMUqBfSj8H0n5FAGlYhJ9arNDYK52LfB2qDzDicCG7jhJgfQN6GSGr94
         lk42z3StIsLe+W4W59zmI97YSKgwrU2AOWEiBrH5rNT0s4SBXa1d/FU0eHZhySzR9/z2
         wFDcCmT0zP/eJ0QeFrFq1RRcfu8L2xpinAm+aHsEyxfwK0aqp/P/iqEp+H1HY6KOS095
         BaUQ7x3C0799iBQAbk4heUIRqtOG8eYMRljEoHaYZwsL2O7mVvunLmoyu2G1Ou2TAcl/
         MksQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from:sender
         :dkim-signature;
        bh=iNQfPT8546HoVkc+KeLP46IyhzvKWlvUhgKz4CHOiq0=;
        b=0vchrR3K7KTCFA31Y7b1Cv8t/HDbj8BNBV+vWBxSmMDsIpDv2viXDQafTrjQ35U9QI
         vmVL5annw8sfbWqyVfIOgOMUBm8RKDtWj7PUUoYB2yJ4KIvW8gjv8ZyUwm5RzvUwGfId
         3yygmNFn21YaGyWVcuYyvTOKJN5UUnV7eNBObE2XxjaPq9K5qzbHTNP0xI6DkRWbVBEf
         /oHBm/iDYyoWQk3flT6TATpp5CsiXNpPCFhGoZ7Xpp0H6Ds5qf6HRrN4dLfMmh8QRIG9
         ZVwmUJs22kD7UZzRI+l3p2jP79qyUR5EpPoPO653HeTdcTNjez8y9gAi0YBUoP7rk+hW
         sdSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pLBa7uRD;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c6sor9398605pjq.11.2019.06.10.01.18.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 01:18:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pLBa7uRD;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=iNQfPT8546HoVkc+KeLP46IyhzvKWlvUhgKz4CHOiq0=;
        b=pLBa7uRDTt0HdEaYhnYCGSSTqtbJsyUhgLj8rV/meDyKT5l/ANlgcsuaRyq+FctOQf
         vkXat1v915SvluefadfC0+/69wDlPeCKFMr66nOIB16yBNiCTZ9ZkPnqQE72DYrnaiZx
         uO5c2UjNqZ0AZe5bRPEDXi1mD0w/CJAqTd3ILvW8pRQerE24TWmgD44ibnkHFfHh1KUR
         sq8EGVbycsowcgqaGIm5SA1Qp590Zngp60DuLdiL6sM9xpgGYTLLomAvRmuZtru5HimQ
         xa3C7vTR/VPjP5Q7sGP+JpRb92qTWbKI7j+9OgCx3/mMwZ42CUUSXoGmVUrVC35CiOi5
         pMKQ==
X-Google-Smtp-Source: APXvYqyjElRHo3flIjclpuZdAQgPxpO6E2MkKHQy57sQhuXnYK2eV1rHFs0k7t0O5S4l+S8Nflykag==
X-Received: by 2002:a17:90a:b115:: with SMTP id z21mr19917631pjq.64.1560154693464;
        Mon, 10 Jun 2019 01:18:13 -0700 (PDT)
Received: from www9186uo.sakura.ne.jp (www9186uo.sakura.ne.jp. [153.121.56.200])
        by smtp.gmail.com with ESMTPSA id j7sm9525014pfa.184.2019.06.10.01.18.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 01:18:12 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	xishi.qiuxishi@alibaba-inc.com,
	"Chen, Jerry T" <jerry.t.chen@intel.com>,
	"Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 1/2] mm: soft-offline: return -EBUSY if set_hwpoison_free_buddy_page() fails
Date: Mon, 10 Jun 2019 17:18:05 +0900
Message-Id: <1560154686-18497-2-git-send-email-n-horiguchi@ah.jp.nec.com>
X-Mailer: git-send-email 2.7.0
In-Reply-To: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pass/fail of soft offline should be judged by checking whether the
raw error page was finally contained or not (i.e. the result of
set_hwpoison_free_buddy_page()), but current code do not work like that.
So this patch is suggesting to fix it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
Cc: <stable@vger.kernel.org> # v4.19+
---
 mm/memory-failure.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git v5.2-rc3/mm/memory-failure.c v5.2-rc3_patched/mm/memory-failure.c
index fc8b517..7ea485e 100644
--- v5.2-rc3/mm/memory-failure.c
+++ v5.2-rc3_patched/mm/memory-failure.c
@@ -1733,6 +1733,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
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

