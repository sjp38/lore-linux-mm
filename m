Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 385D1C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFF062080C
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iIFIdW8A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFF062080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AC138E0003; Thu, 27 Jun 2019 05:45:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85CB88E0002; Thu, 27 Jun 2019 05:45:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74AF38E0003; Thu, 27 Jun 2019 05:45:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6128E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 05:45:05 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id g189so492962vsc.19
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 02:45:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=G7q4MddQh2Qki7wvcHF8MIsvZAyVqJ4sXwbvqTqIetQ=;
        b=pdlJeCBsoJG1P8p3K9BfnwojTfXHzYEnf4Epq6qgPU8GLYzFuQgc51ppSiIAKf0f42
         rfMEakgb+O3HXEscfccHyF+9tjKGn3f3R+uELrq4CbndVD+p7ctZg5QAEE/Ndm+udlKa
         YCM+3Y9J0vI3nlWHOe7UbW13uQtoHk25CkeUM2SC8zepY7sL0aeZaJaoTSpQWDtwLi1H
         O3q+5i9/4jiwJTJ0z1X4iIWIsaGR34bnt2U6DAwVgBJYaxDSdgiUB1q5vKyr8bEFWFW6
         22lnGZ8Jcvruuz9bZst9xTK2Sz/O2+3IJafK1MWlw902e2MDnPjTSEbjmENaaY4YB9sm
         R5Tg==
X-Gm-Message-State: APjAAAX94bMHpRG9/rwlRzZ0EjEQOkhfnMfFianDFvMxvQdoJMknFmMJ
	cUHX8cpJ0CqgQal32J251QJcd060ijrMqROz84FMrFWm05JYTZ1tliYdSmrY9Hr/UNH2QmIfil+
	lDZFl0PibOx4shueTpm30lRp4ikWFfitpIz3EEVHgzdsELHxVymOFnmcfjQO+rRDpRw==
X-Received: by 2002:a67:ecd0:: with SMTP id i16mr1898317vsp.110.1561628704955;
        Thu, 27 Jun 2019 02:45:04 -0700 (PDT)
X-Received: by 2002:a67:ecd0:: with SMTP id i16mr1898290vsp.110.1561628704343;
        Thu, 27 Jun 2019 02:45:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561628704; cv=none;
        d=google.com; s=arc-20160816;
        b=NSWlJd+ocVuCaXXW1G89MKNYz1z/o8JpKsXIU0/nvukkxIpGsTmrY8tFUDEQKCdGeX
         u79CcVoYeVWF9DlBcu1ZVMxR5e87OJg2CI27MY3BqK985M3eHASQKAs73b/3zWj6IS91
         gdjzPtCyGPXbzg4QhyASr3/ORM9WXgDxlceJi2qr/gjzimfZNH3Fprw5BhNjEAoBd+wB
         e3xXB6BDbp/SaCCizHdS+Imve6PEIJUeZ5n3RusYeAWLLkATiZF8PzacD9Q1sswxzi7i
         JVVOEW8CfvOcGAQY3nWYXeTnr7vCF7TYMdf3+wl0ABL1VO/vfJg11fwK9ZkSzwPb9DIW
         MU4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=G7q4MddQh2Qki7wvcHF8MIsvZAyVqJ4sXwbvqTqIetQ=;
        b=Vks7mgKohT0PScJ472eYkzduYoDySjCQnC5dWmq699jQacr/QtaD5sEmMPCgfBb2zJ
         nYjmOgOM0hC55ZkZnOBkJTXLv73RlQqRYg/5STMMAzJyDRGA76ALQRcIT5hCoZTwBFgr
         6IB5JuBAsBMujan8R46zI16OkHx7jtv2yfwMxoi7wlp3NYEQs1ehtS/4alS6BlY7dzcX
         Grt+uG0jyrJIMH6xKsxksy56bkV9mwYLyi2H/4N9YIh8fHJ5pAiUDqn3K4Xv8zIomiZR
         6CMyuZnkOVyZUNQAkOBpijwWlCC8jQzbmwZb0cmpnLEZ2NIT5Gs25EC6svKx2J+iJuBt
         9vGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iIFIdW8A;
       spf=pass (google.com: domain of 3h5auxqukciaipzivksskpi.gsqpmry1-qqozego.svk@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3H5AUXQUKCIAipzivksskpi.gsqpmry1-qqozego.svk@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c13sor754326vsj.11.2019.06.27.02.45.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 02:45:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3h5auxqukciaipzivksskpi.gsqpmry1-qqozego.svk@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iIFIdW8A;
       spf=pass (google.com: domain of 3h5auxqukciaipzivksskpi.gsqpmry1-qqozego.svk@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3H5AUXQUKCIAipzivksskpi.gsqpmry1-qqozego.svk@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=G7q4MddQh2Qki7wvcHF8MIsvZAyVqJ4sXwbvqTqIetQ=;
        b=iIFIdW8AGFd89LJxBaWWybfiMjDFHCabZe9xHyImXhv671LcsmIa7K7Tofzu9sXAul
         J6bNWjuGkFUHeR2krrbECMJePceBifglobPRtKN/cXZJsjYIVeoD4lXItkrM38T76+jA
         zwtMOzMy1KNIRVR5YxIkdxpocBQ10jwq9Wn/CKqhoOYZRRfJkGiPsIFYeXjhzm/uJYXV
         v7C/Zsm4y+VwHU1CR/WXLCSAIDGnE3xn92f7bl+aU9itCoELLmmeSwEV1kyIXYznyYCW
         Bk4UVaxCl6s5guRQ60IGuUBkhWKMoPZaR4f9zT+72vZEk7nMWv0Mn4fEQk7pbXUE9u0f
         CRuw==
X-Google-Smtp-Source: APXvYqxzyiSxraxoQcgmvDUSkWBKWNaU3/TfGuQXyTBHlYvu2COk1tr4TQDRG849kXyhCzR4wstX8R617w==
X-Received: by 2002:a67:f795:: with SMTP id j21mr1954700vso.226.1561628703889;
 Thu, 27 Jun 2019 02:45:03 -0700 (PDT)
Date: Thu, 27 Jun 2019 11:44:40 +0200
Message-Id: <20190627094445.216365-1-elver@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v4 0/5] mm/kasan: Add object validation in ksize()
From: Marco Elver <elver@google.com>
To: elver@google.com
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, 
	Kees Cook <keescook@chromium.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This version only changes use of BUG_ON to WARN_ON_ONCE in
mm/slab_common.c.

Previous version:
http://lkml.kernel.org/r/20190626142014.141844-1-elver@google.com

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
 mm/slab_common.c             | 46 +++++++++++++++++++++++++++++++++++
 mm/slob.c                    |  4 +--
 mm/slub.c                    | 14 ++---------
 12 files changed, 148 insertions(+), 65 deletions(-)

-- 
2.22.0.410.gd8fdbe21b5-goog

