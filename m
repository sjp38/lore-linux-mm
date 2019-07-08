Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6EAAC606C2
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:08:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A07F421479
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:08:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="su70wQ6/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A07F421479
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50FAF8E0021; Mon,  8 Jul 2019 13:08:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E6F98E0002; Mon,  8 Jul 2019 13:08:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FD1F8E0021; Mon,  8 Jul 2019 13:08:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19BF48E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:08:56 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id j140so6815063vke.10
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:08:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=rkb+RBbpaLSwWUUB7g0A+rsu7yIfnRDIumBvHSjiI6g=;
        b=GE3LJ3fBIq8naIOLeu95+F6PnJWT+tNZ3esQC2Ey310f0N+zjtDUjzRn22F1WJYcnG
         M6RcmGgS3ZpK0edwtCGo5su4PX0YgRZklxtq4aBBxYtnJl1TF0vP5QWei6WVVjMqo1eR
         WrN52MyP0k9YCwlkincrtQJ+1HT6mH/oUaQgEsPx11Jg2s0WeFmrLsmIe0MLprXpdBXn
         0ayeNHz5DLMd7MXvkGt2NEZycmf3xJ8KR9yOFWLO5XUJ//Ro39HyLJSYkpt4hVMITAFD
         aG8WJZLN2M4SdEZ1Z58bRKcIoED7knb3rEAQNh2rkxbbH+sy37K94lyYBuQZQagtFXeB
         Pz5Q==
X-Gm-Message-State: APjAAAWsAwfDi0rbA8JFQrzjMMX3p74TcKe6lTE04WqrKoPVNeiyKb05
	SZPa3XUIMJRDIceJjbkZI6EKLTu+cOPOubfP7vwzRiI8Tqara56sR6g6Khda9jaFPpcaOonCs6h
	DfcdgETvPq7GUeNCvynbfMRYM2fmiyBl55wj6IIzSaQfk7NibVqom9+Pf5pNGTwiYow==
X-Received: by 2002:a67:f043:: with SMTP id q3mr7703019vsm.219.1562605735811;
        Mon, 08 Jul 2019 10:08:55 -0700 (PDT)
X-Received: by 2002:a67:f043:: with SMTP id q3mr7702986vsm.219.1562605735278;
        Mon, 08 Jul 2019 10:08:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562605735; cv=none;
        d=google.com; s=arc-20160816;
        b=jCsN7obwACnTA4R8002n3kJ9atgG47AJY9jXDjMPqDCpNxVC1TA6WFUNCfkk87s1u1
         C86WyyZgvUhQ6GhymS7ZiaZtK3y/w8Ts4Rrb0jyirXCFFM1oAyVSRHGrQmmZlGgPGBMz
         Cz0UL5J9PTeIaLBjC8eP33bxTwmVtv667Ucagninr+rDCtaJelI3bu0FFFtyULAX9LdL
         x0Qx8ZhE1bud1F5JeVrrMmHZSfHn6ijV92mJ4xTdqDbPRFo8wYjqa/bz74eAU6pAdEHB
         /VjkjqmP7wfCdzWD5eAnmVnFJ48WvocNSKVn5dCNRpmvn1mO2Yv7CekgPOdh9xobElGT
         IIOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=rkb+RBbpaLSwWUUB7g0A+rsu7yIfnRDIumBvHSjiI6g=;
        b=1DAsEKsH8h8zGDFaciUqYrloe3L9KkD6JaZzzOdqwwdmpbHe/YiqNNI/UXYw+eHSeu
         dKFcy6QvaioTG+ToubbuZ0TcGQCpaZiOV50wxeNkzswfC9PbqpLt4Kt0g91clWtS+pt2
         ASl8QY3R+Ct+2iuywzIiFvVhYxqfnzjDn0kG+BeUoOqhYLBusyz6sScJelgxN7pYVoJr
         hKcavU5iuY1zGEBs8Kk/NdWLgZkMfwY5vKD2f4Ch02SpVojCayGH74rFSnI3qikqxv5j
         T0Nxd5aWXt1vdWDAa+xLeAIjNRteZkr4qZV7t23x4Bag650EculPfZK1xCkcgP5n20Dh
         Vf1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="su70wQ6/";
       spf=pass (google.com: domain of 3pngjxqukcbuz6gzc19916z.x97638fi-775gvx5.9c1@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pngjXQUKCBUz6GzC19916z.x97638FI-775Gvx5.9C1@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id y3sor7234511uay.15.2019.07.08.10.08.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 10:08:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3pngjxqukcbuz6gzc19916z.x97638fi-775gvx5.9c1@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="su70wQ6/";
       spf=pass (google.com: domain of 3pngjxqukcbuz6gzc19916z.x97638fi-775gvx5.9c1@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3pngjXQUKCBUz6GzC19916z.x97638FI-775Gvx5.9C1@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=rkb+RBbpaLSwWUUB7g0A+rsu7yIfnRDIumBvHSjiI6g=;
        b=su70wQ6/2hTT+J8ES8WXMRV7++oOFKiaJoXI1tHyVzzTCdE5I1E5DVYHktmK7xoyLH
         iZb/vfep+BIeL3PrullH6dkk5V4/AmuWTC4WBFI/bMTAhsjNYBYn6ySN8XAKZYkF+uiP
         /QutnYKWRFTxmwrZGCr6CmPBC/PSe9LZI5m5LU2EeHPCw7wxiCOF0TAe+0xJSMxjHVFE
         4y24R1PdKke1XPauJk+Z6WuRwhl7JisBrF/xvMt0cdsXlh+0PZiu45rvNKxWd1vmthVU
         h0d4arZgDyJcJRGTZnIyatkhKFDNCFMlQpm5jbPlJtLFtTpWD0P6d5SUFIGnBwSgWvB4
         dCXA==
X-Google-Smtp-Source: APXvYqxlNqCP7Is+7VGSJcZtIKkF90xpT2ulacUW8J0j4jU3IIAPg9yY4ZS6OegNMF29BsHeoXjMsqH8RA==
X-Received: by 2002:ab0:7143:: with SMTP id k3mr10372932uao.91.1562605734773;
 Mon, 08 Jul 2019 10:08:54 -0700 (PDT)
Date: Mon,  8 Jul 2019 19:07:02 +0200
Message-Id: <20190708170706.174189-1-elver@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v5 0/5] Add object validation in ksize()
From: Marco Elver <elver@google.com>
To: elver@google.com
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, 
	Kees Cook <keescook@chromium.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Qian Cai <cai@lca.pw>, 
	kasan-dev@googlegroups.com, linux-mm@kvack.org, 
	kbuild test robot <lkp@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This version fixes several build issues --
Reported-by: kbuild test robot <lkp@intel.com>

Previous version here:
http://lkml.kernel.org/r/20190627094445.216365-1-elver@google.com

Marco Elver (5):
  mm/kasan: Introduce __kasan_check_{read,write}
  mm/kasan: Change kasan_check_{read,write} to return boolean
  lib/test_kasan: Add test for double-kzfree detection
  mm/slab: Refactor common ksize KASAN logic into slab_common.c
  mm/kasan: Add object validation in ksize()

 include/linux/kasan-checks.h | 43 +++++++++++++++++++++++++++------
 include/linux/kasan.h        |  7 ++++--
 include/linux/slab.h         |  1 +
 lib/test_kasan.c             | 17 +++++++++++++
 mm/kasan/common.c            | 14 +++++------
 mm/kasan/generic.c           | 13 +++++-----
 mm/kasan/kasan.h             | 10 +++++++-
 mm/kasan/tags.c              | 12 ++++++----
 mm/slab.c                    | 28 +++++-----------------
 mm/slab_common.c             | 46 ++++++++++++++++++++++++++++++++++++
 mm/slob.c                    |  4 ++--
 mm/slub.c                    | 14 ++---------
 12 files changed, 144 insertions(+), 65 deletions(-)

-- 
2.22.0.410.gd8fdbe21b5-goog

