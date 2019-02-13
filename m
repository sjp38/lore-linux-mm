Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00F93C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3395207E0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kRsFmn7O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3395207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 505B18E0003; Wed, 13 Feb 2019 08:58:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B62F8E0001; Wed, 13 Feb 2019 08:58:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37F9B8E0003; Wed, 13 Feb 2019 08:58:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id D5AA68E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:58:38 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id l18so572927wmh.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:58:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=oa2C9YpwVP4acC+vx0vAyuhET6Eq6DJxoD9AMTm5eV0=;
        b=I5Bc22fBrcntYAXf2Yh7rYFaX1P6Brd5LIgl0qqmS/Ualo50FNlM3KdqjClHW2qjqG
         JAKp0oNJQtb54FxHSac36B4NbY2YtGs5Ft30Sypdup/2vPDGAlVOr7NdIlleItcr3XCk
         fJt84uiO258gHPUojhym8zYn373sSCIKepW6te727PVXtftjx6ujwi1vax8os6sNz9p4
         PJdVvkJXgJyY2JCDS9dXDMYadkJYqShC/9ZhRrh3lXRmL2MH8Ge8VNlE0LufmO3Y/f2D
         W/aZq1E4gYE12gx7df/4/mOAPLl2s/TaeLs9Ikt7RD2vaIEAsGc553yLPoxA5DfsFVXx
         9H4A==
X-Gm-Message-State: AHQUAuYtEbS2pqVBhHfDMYj/JNs5eI5UglDhbYipnWSh8I07uVcKZ/8V
	6nGtRGMnesuoMtigVAL+KPFMSA8YPa+ZZyYtzEgaQy9nWhcyTH8STw6VmMzrXnM3IsixXPDQLe3
	nyGI8lHg0wdk20/LQV4LB/uAAmHWqMQ5WcjcRc+CX7e8Cfrs/8e/MTayOExb2avX0/lqTAzMkxI
	7XQ/Mbxb6JX6GVCF3UEhL+U0Q/DpEwws9oFBv6Bob9oncOh+ZoGpgujA8xSD8ak9XnPEYiqMu3V
	CBGjBg7SNcIsk2NsBYC8u0br+M3b59AexgohqsOE70UGbZs7o6JGicCJT23W81SCaJRdhVcwId0
	SqzB0OGL/rdaOE2TwcjIMieLySESB0T4eiOIfbb/glht04PXvuMWz+FqsjjUA6zWccnLCBYbTAC
	t
X-Received: by 2002:a05:6000:92:: with SMTP id m18mr530027wrx.258.1550066318401;
        Wed, 13 Feb 2019 05:58:38 -0800 (PST)
X-Received: by 2002:a05:6000:92:: with SMTP id m18mr529953wrx.258.1550066317046;
        Wed, 13 Feb 2019 05:58:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066317; cv=none;
        d=google.com; s=arc-20160816;
        b=mW7STM2mVFuVt0LwYsQKizU77488G70HFpfjG0KkWIWFErdhgI6QJRcM//UKikc+eU
         f8wd3DTPfB/ujZFUf6srLpWldlu2VejCZ8ox8YuIqeIf+vXBXM8KoeQsQCJyl3DwDeci
         T2WCnPKfokgZyjlj3kXuoOqOVYgEFUtiGd6FwlIZz9b/H5c3LlikfZwLG6ZmrklC1kHx
         rhxJTK+0rskyHxzOwvpevYrK/s/ZEEeYExq7V6QljGv0mJFIZCuW5Fe8GUXVmj2QyzjX
         cZRuu3AzlFp2+q8KIH7wz9IVIOJXYcjRosnnnlMAvQ8wK2SBRVcIs9BtU+e353aLeN2w
         ga2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=oa2C9YpwVP4acC+vx0vAyuhET6Eq6DJxoD9AMTm5eV0=;
        b=qtBQqBeN++EVcNP9OFrMTXfgEUNOOwQQBOATxq88eOa5cz6FpeJLNQ3WfDGYloXI0n
         z574PeK0n8SbjzuLtzj6A09qJh4mMSc/ewkWru9oxFOduQBWZHrHe6BoIMU9XQXeYRLG
         LucRjffWpa4awt26zDKrH2GDw0wA9d4hH7Su8ddlWOCDq219p8Zo37LwQ+QNB18pafcj
         Ws4I0MA6xQ/RaADjRQxEbi/85BJRTHE+CHPCsEfmUPZjq/neeqErS9DXF6uTkOdKZmhB
         K0EAZVNaMlwrOp3SnCkk7FLXp+yLOT7q6jDwb3hHx9rpnZs+VmkzHH4rV2jTo9rvmleP
         70Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kRsFmn7O;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o13sor5918041wru.8.2019.02.13.05.58.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:58:37 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kRsFmn7O;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=oa2C9YpwVP4acC+vx0vAyuhET6Eq6DJxoD9AMTm5eV0=;
        b=kRsFmn7OVbjdcREztoEjmqqR5rmyygYeAE+WMFiiQ6sFhAi82Q5MDKUh9A16xtT5JW
         /SQv2U5Wlbn6W94LeKGcEiCI+F4m8OdDclPsSMhUqBw5fApBz1U/toUIZKSY8MuAUBjO
         6M1ff8yThJPJ2dJ1ZPZtsat1y+jg2xvHBF04I2qBkl6GcEr0Xfwk3k2Vf9eqPvNmQeho
         /pY/KmEJrzpHXFKDr7ZWEJOaQXGCR3YmssPvpdi0UJOts5yXPZr7sP2Ejw3l4VAsY3dS
         963mQxVU+K1gxD9d4wiRrR9fHIQjBq3/rl7SL549MH0Lb3to/bDI/FukbcVC1H2Qrqtf
         eEGg==
X-Google-Smtp-Source: AHgI3IblUdp24VTe0Xsfg2eryeBWFR0ujqHQHBSOoLBlpfNOPNi1X8GGdCQvSSPbkVuV1YEk3IDGzA==
X-Received: by 2002:adf:b783:: with SMTP id s3mr552411wre.274.1550066316297;
        Wed, 13 Feb 2019 05:58:36 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id v9sm11195866wrt.82.2019.02.13.05.58.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:58:35 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 0/5] kasan: more tag based mode fixes
Date: Wed, 13 Feb 2019 14:58:25 +0100
Message-Id: <cover.1550066133.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes in v2:
- Add comments about kmemleak vs KASAN hooks order.
- Fix compilation error when CONFIG_SLUB_DEBUG is not defined.

Andrey Konovalov (5):
  kasan: fix assigning tags twice
  kasan, kmemleak: pass tagged pointers to kmemleak
  kmemleak: account for tagged pointers when calculating pointer range
  kasan, slub: move kasan_poison_slab hook before page_address
  kasan, slub: fix conflicts with CONFIG_SLAB_FREELIST_HARDENED

 mm/kasan/common.c | 29 +++++++++++++++++------------
 mm/kmemleak.c     | 10 +++++++---
 mm/slab.h         |  7 +++----
 mm/slab_common.c  |  3 ++-
 mm/slub.c         | 43 +++++++++++++++++++++++++------------------
 5 files changed, 54 insertions(+), 38 deletions(-)

-- 
2.20.1.791.gb4d0f1c61a-goog

