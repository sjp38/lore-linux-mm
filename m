Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A90C5C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:27:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4910A21670
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:27:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Obt/qbqC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4910A21670
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3B2B8E0010; Wed, 26 Jun 2019 10:27:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F37E8E0002; Wed, 26 Jun 2019 10:27:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9003A8E0010; Wed, 26 Jun 2019 10:27:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2A28E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:27:54 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z5so3025223qth.15
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 07:27:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=r4ItmzOajsz46SiEckz8j+X5GgZKewiKuJJu0la+VeE=;
        b=BprC3AqCubE+3f4cWmJgmWc2IfuWoBX9JLjUeEU3Vdc8QQXkn9iQYa0t6a9fHbTPD7
         hZ06ybrWY0jRLzS4I9xuMBoTxpOVx9wDn/QuvRJ55NymsihX5EsaTaWi7YfiXuhiedbV
         DxMyhHmp7LTahTMHWwpxTMVQ0e8peR68V5Ld9H3AJNmsbmDLx09tLhnaNktnH7+vLDo7
         LjL1kl4o1GYdkSvTKegF0OEDowq7GInyvM+TQS5YhR0IDY+Ke46bOhc+Xl8bG79QGQp3
         SSFmqAYBgQxdN2ADpRboOmMJ9uxf09GenZWKpCFap9cnkon5uYK7QbPSoGUh00w4PEv8
         c0sA==
X-Gm-Message-State: APjAAAUNU6ePErDDfRcfSy1Uwh0OQ6743POetOlB/a8ArORctoddCIx+
	GHKESOI+0aiVxtxeYmDEYZlET3iYU6O2sYzm6Qa4QyVudW8hKoaQsITQG+joZ4d60dMDh7DlxFJ
	KPFyCBpa0A7LOkSd79gG5h9WxfOxRb3+SHZpqhGtMseLuBPydDyHrUPpvNoZPTc0r8w==
X-Received: by 2002:a37:660b:: with SMTP id a11mr4048688qkc.342.1561559274237;
        Wed, 26 Jun 2019 07:27:54 -0700 (PDT)
X-Received: by 2002:a37:660b:: with SMTP id a11mr4048641qkc.342.1561559273605;
        Wed, 26 Jun 2019 07:27:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561559273; cv=none;
        d=google.com; s=arc-20160816;
        b=oATw0kBTkz44hROWWG7ydbmE1Xbli/ZEbUTiXRMJDUFYG85XAgjo0Fu3k+JQgnsf92
         IkMQuuolcPMwPT4s8lY63Sv4LXtgKx8DpP0kzDU6JZCkUsNPiK6p/G9/evqpOBbxtKgl
         iohNogYFLb3L1mXmv2mCPENgYd7NA04/hwmPiWkK4CXRausjidQHzgCSAZnE6HTLaUDq
         P6pALl25QLWmLbH2lbwSfg78rxAFPD+/0qOTsdFNx3g8ZnlooEm/runJLgcorz5V12uL
         GQIXjyjm3hxjaX1JcalctSzl6cyPeev6UKHIv/Il5+LgSy3Y9CeheROUvuKY7XZAV/gw
         KeIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=r4ItmzOajsz46SiEckz8j+X5GgZKewiKuJJu0la+VeE=;
        b=cFWdTP8SZ85+l4hi5QgOarsjzNTo1igNfQc1TqPqCCMv5UiHfRcH1m85bcj+uJiayF
         2vz6Nt8kxYzILv/dSFegjW/QPYq7jBo2NSMvknMDT3bYjNVhddZW+/2tqCQP6htDANqw
         XENYy427OIZEugfoLaYi/J2HByv3lU9ZREVfKwcS0Or1ONtWI7A6F9iInGknNJIKxh/t
         PZwnFLqdTDLwGCH5Kt4BkNy3dtzcHlxBkFHLXiUS8C/tE8oTipcrbR3ML93N6tf+oqoR
         HPsl+ZFFzFBIF2+E2intbMW0dnGkfYsvnR7Sz3XiShno4BzlJ3SolHfw+jMc+5SPLM/w
         +b/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Obt/qbqC";
       spf=pass (google.com: domain of 36yatxqukccgipzivksskpi.gsqpmryb-qqozego.svk@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=36YATXQUKCCgIPZIVKSSKPI.GSQPMRYb-QQOZEGO.SVK@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f4sor24371397qti.68.2019.06.26.07.27.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 07:27:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of 36yatxqukccgipzivksskpi.gsqpmryb-qqozego.svk@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Obt/qbqC";
       spf=pass (google.com: domain of 36yatxqukccgipzivksskpi.gsqpmryb-qqozego.svk@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=36YATXQUKCCgIPZIVKSSKPI.GSQPMRYb-QQOZEGO.SVK@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=r4ItmzOajsz46SiEckz8j+X5GgZKewiKuJJu0la+VeE=;
        b=Obt/qbqCs/bsHGPLzrNGMBKdEVVjbJIIBymqIDhJeO1ke0sGLX/925KyG2CxVcciHo
         5uEUeJJRXcGvNUoB2idEYM2BOk9ugowXvoP4Nu/4ySo7CByG0YDh1DQtB3Anx71bi3Zq
         xXWdUKPuJ620a7XPTZxFzOBN8B6Qzr8Hej2qFEE90En3bjM96NRZY6es1n/HnIHtnouh
         zcVOwNBXhEi2oklJO7kGV2MJ83wm0KHwOaPSnkztN/1M30iNj7hOpa+5eagHwfzxRvDQ
         dFzVHe8QVvyBrwypZO7fGM3vGURartVLGtOVDhDbfTKdKpqQlTdlZtpaAN2K6EBWE+nI
         jDeQ==
X-Google-Smtp-Source: APXvYqzr74PSeU2y6FOA03uUNS0dApgjOP/jRZUTpufkeZ++4HYMPmrj9Hcs4rnDGQJZ9/uHvmMAxYzh+w==
X-Received: by 2002:ac8:29c9:: with SMTP id 9mr4065369qtt.196.1561559273101;
 Wed, 26 Jun 2019 07:27:53 -0700 (PDT)
Date: Wed, 26 Jun 2019 16:20:09 +0200
Message-Id: <20190626142014.141844-1-elver@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v3 0/5] mm/kasan: Add object validation in ksize()
From: Marco Elver <elver@google.com>
To: elver@google.com
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, 
	kasan-dev@googlegroups.com, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This version addresses formatting in kasan-checks.h and splits
introduction of __kasan_check and returning boolean into 2 patches.

Previous version:
http://lkml.kernel.org/r/20190626122018.171606-1-elver@google.com

Marco Elver (5):
  mm/kasan: Introduce __kasan_check_{read,write}
  mm/kasan: Change kasan_check_{read,write} to return boolean
  lib/test_kasan: Add test for double-kzfree detection
  mm/slab: Refactor common ksize KASAN logic into slab_common.c
  mm/kasan: Add object validation in ksize()

 include/linux/kasan-checks.h | 47 ++++++++++++++++++++++++++++++------
 include/linux/kasan.h        |  7 ++++--
 include/linux/slab.h         |  1 +
 lib/test_kasan.c             | 17 +++++++++++++
 mm/kasan/common.c            | 14 +++++------
 mm/kasan/generic.c           | 13 +++++-----
 mm/kasan/kasan.h             | 10 +++++++-
 mm/kasan/tags.c              | 12 +++++----
 mm/slab.c                    | 28 +++++----------------
 mm/slab_common.c             | 45 ++++++++++++++++++++++++++++++++++
 mm/slob.c                    |  4 +--
 mm/slub.c                    | 14 ++---------
 12 files changed, 147 insertions(+), 65 deletions(-)

-- 
2.22.0.410.gd8fdbe21b5-goog

