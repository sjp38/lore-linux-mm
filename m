Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9A4DC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 19:13:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 752D32082A
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 19:13:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 752D32082A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ACD06B0003; Wed, 10 Apr 2019 15:13:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05D7A6B0005; Wed, 10 Apr 2019 15:13:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8F026B0006; Wed, 10 Apr 2019 15:13:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C862F6B0003
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 15:13:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id q127so2944559qkd.2
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 12:13:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ry3tRyknY9ceQV1IFpbNBowX/0DBFH1I9eSOtVz40P4=;
        b=rhh0Nwekw3unvOFVPqjP8fmM74SmqBYh35mRtVnbe7mTeONvaBV+r/iTl2WqOlepFm
         pk6luUH3Dq1pLVW06WWS6Siok05OhdSNXGLiP8iYVEyfLmUmJEqpQyrjMB6OPlnKh17I
         jW8jKqI88Z+uW3Ydwfmuflh/5K6OoIisSoZix2m6GBWG2+F+eT/pz1Q3d8cJuSI0yevD
         8UKVPRO2vkMPuSCidJscnw/6qAnz2yZwQ+SZBfrIlNlNjKhKjFq2NHOJAvw/mWPnn0Pb
         DRXH3+wkdNZvRS7rlVus93FtxBz3XwNMjLTdDIq/ZDt0gKiRqC5Byu5q5J/aRcw41248
         iGyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVfZiPsBXoY1nRXHumi6A0HMJqqKQEj/vpmpZMp9QVqCvbkCgwr
	7dKQnw9ikhWIsWgHoQE/wM6WOPNNlZVPRtHE2P65i73vQb0kwN0uOW98uta/Hk2VIGLMqyaSkil
	co6vu2ajZFAl+ghogAxk6DVgogpAaifCuCQKh2cerWuJPiU1tCy7BQIfowTt5SD6Iog==
X-Received: by 2002:ac8:38fd:: with SMTP id g58mr38791833qtc.14.1554923636568;
        Wed, 10 Apr 2019 12:13:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRP8pHDupdmefF4DGrtGEwcD8rCIKwKHR/6iir3InvMIfIty8Vxxd611P4a49kOhEtvjVs
X-Received: by 2002:ac8:38fd:: with SMTP id g58mr38791731qtc.14.1554923635260;
        Wed, 10 Apr 2019 12:13:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554923635; cv=none;
        d=google.com; s=arc-20160816;
        b=ikWKFqirwUzrTM/wsPkz4QbZj3I37c/47IaC2zWQL5F1tVq4aPJF7N2818DbYSVkGe
         ZHuFYgIdwdCiIvw9PjxghMYjloHGjIjsHj84UkgoEBKJwF2HXx+veQqJsS2Umkc/C+8r
         3wTr+B4PUyzuOXRHhW03QTAfku8c2yfd/AD3QkIUwUONyHAQjHxUGimKogRBfwj/cfz5
         7PK4Xf2ZLX9creZupoVv17IIYCf1qjE24rko4kjHNiYr4NV0uHsRbjolRYgXTUTL1Vrz
         4It7pNxTpABjezfoMjwZIdys3UO++jFmYV+Gfukh85A4M1mlK6oe8hsCUB25K/vupqew
         8QOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ry3tRyknY9ceQV1IFpbNBowX/0DBFH1I9eSOtVz40P4=;
        b=vGA+L+IifSa59IyVazrQUEyr1v0Bj5UFM5yebGkK2j1cMSwHUsWHd5y8i4sk18ZS8W
         uvvXDZ14H+wk3VULCzIUAZYhTyk22E4rNSX1QV1c6fHKNz/wGoUDfzio6efFA2V1JNu0
         5sopyuOpK5pOvPxk9xA5LOLNCnNXMJf/UthQvcRgGwFdC+gPtVbO64H5xnV2u8296TOd
         nUCcGdyWiVlfEOAOPXK3nyhvhinhr3v7ruMn9+KvZkOSIT4Ebm4whD6nOqaaMyribeUd
         V+2lzfHhLkQE6R4N/FBDJtPyuEwh1nY35QYzzdu3YzvB+9I3Xjhbi0iFqvoR09xUCI/u
         iuFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a20si7409287qvd.39.2019.04.10.12.13.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 12:13:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4E259316891D;
	Wed, 10 Apr 2019 19:13:54 +0000 (UTC)
Received: from llong.com (ovpn-120-189.rdu2.redhat.com [10.10.120.189])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C3138600CC;
	Wed, 10 Apr 2019 19:13:49 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jonathan Corbet <corbet@lwn.net>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Aaron Lu <aaron.lu@intel.com>,
	Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
Date: Wed, 10 Apr 2019 15:13:19 -0400
Message-Id: <20190410191321.9527-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 10 Apr 2019 19:13:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current control mechanism for memory cgroup v2 lumps all the memory
together irrespective of the type of memory objects. However, there
are cases where users may have more concern about one type of memory
usage than the others.

We have customer request to limit memory consumption on anonymous memory
only as they said the feature was available in other OSes like Solaris.

To allow finer-grained control of memory, this patchset 2 new control
knobs for memory controller:
 - memory.subset.list for specifying the type of memory to be under control.
 - memory.subset.high for the high limit of memory consumption of that
   memory type.

For simplicity, the limit is not hierarchical and applies to only tasks
in the local memory cgroup.

Waiman Long (2):
  mm/memcontrol: Finer-grained control for subset of allocated memory
  mm/memcontrol: Add a new MEMCG_SUBSET_HIGH event

 Documentation/admin-guide/cgroup-v2.rst |  35 +++++++++
 include/linux/memcontrol.h              |   8 ++
 mm/memcontrol.c                         | 100 +++++++++++++++++++++++-
 3 files changed, 142 insertions(+), 1 deletion(-)

-- 
2.18.1

