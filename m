Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E87AC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 10:28:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 377F0206BA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 10:28:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 377F0206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED6886B0006; Fri, 26 Apr 2019 06:28:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E84DC6B0008; Fri, 26 Apr 2019 06:28:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D295C6B000A; Fri, 26 Apr 2019 06:28:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 953516B0006
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 06:28:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d1so1802793pgk.21
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:28:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=JxtaM5xmovEnVzpt0oJ7ANQywZto5sxZMte1kcLSjQA=;
        b=puQs6mZWsqJx4wC2IN1lS5BNvJYbYzCL5PNhmpHk/lCsoI1nTrso23EYafZXsAY/KK
         ffLFvl4aObJlPkJuCx+NgTnXnM4ZpnZgol2QMQ4godVpcw47ejnAmiKG831k/Dfu7Qpp
         3sxEqiOb4klVYlPjQzceq+8KAawmr1MoYnSv8psD3906BghKkLIFA3DMPPdgPoHZuZkF
         CKgo5NBiYzp6mQyqntzb6Wt+Qkegh0Yfd+EriKU9fUwbkv9dO1mB/UdowBiRUfk2mwy4
         2z9S4nf5q/+ivM+WNNXqW4vzt8+LQtPqiepNuaaQ9gRuuOMrMEU94oJ3nm5USktbkVhd
         8cDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX81w+/LXkCg+q9bca9wC1O4ibm14mkxhkVQxV564l86n6JbHuS
	DmaDVt5X/+rWY89SO5yNHuGVqkwMP3E+kxYwBVhm3Uj0xexX9tWHRKiKMV76qOI003rh/qsfvYv
	BzVRWSU+bHldU02XEeVJE9KqyqZKyp1tDctWR/hpemX8Hn+9O9hL2QA1nkI5LPVN1Fg==
X-Received: by 2002:a65:4489:: with SMTP id l9mr41532510pgq.1.1556274502243;
        Fri, 26 Apr 2019 03:28:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwv6CAMvyprnnlv5b9dyhIbGOj4YKDA1knNHFC81pUCzqTNQVGLOLT8nuwlhMmWrvC1RZ8z
X-Received: by 2002:a65:4489:: with SMTP id l9mr41532427pgq.1.1556274501223;
        Fri, 26 Apr 2019 03:28:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556274501; cv=none;
        d=google.com; s=arc-20160816;
        b=g75AsQE7+cLtcGiCvPgyC908b7QzSSum5TrAmxSDpgvQtnt3rdv3b7Rn6k3+pyczJF
         XHrRG+rnlpwAU8dIFVU0fJDu+FaRq6IIBlnq89/mxiPjONrj3KHX85FdwDu6Xl/uB0a7
         008KP6WpJ5V1y5SaUDnS94ZinGSf5TtCowSe6hDYFCz2JSSkwsz2Lh16tU8FPnFP5Q1i
         19nsaI38xmzDbm0LMzEYoD7+mpD2IpbLUhspH/ZtVTtlsglng9MZ2iL9tORobk6HYywU
         2Q7fkqGb36lCumbuNG3IY0X5MF2/Xx4bir9scxCBPLd4Eq4p3ZpXNq8MhWKsQSEfo5TC
         YiOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=JxtaM5xmovEnVzpt0oJ7ANQywZto5sxZMte1kcLSjQA=;
        b=iTo2XKRdsOQmvMGjWu6VBhxdaGUzZtKsxylN644IopLwu23ya5Uijy/iPshB32e+bC
         4Zv4cSky8L4wuL75wz5AJq+uQ7BzVuYJNuwXQFkdZ9sFchxzQB144C+L0828t79xz2vK
         lXH69ylxLkvpS5TCheXHx0iksEsqhCPiHfbo5MJp2zyoJNROmH34ijOHZB07kTGg+DP0
         uj+LVnMSRPIJmrcG1Nk2sEyq0Z5zvswwtELXl16ZEmykdJ/tCYEg2OJ+QWIQ7yRjJUB1
         n8nTTvMUuvDE4O93q4BBIrvxfuycbrfKqNIfRLw1t2wAXbbr96aX4GW9gwBXW8TIkBfa
         KWZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e92si26558261pld.252.2019.04.26.03.28.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 03:28:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Apr 2019 03:28:20 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,397,1549958400"; 
   d="scan'208";a="319168929"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga005.jf.intel.com with ESMTP; 26 Apr 2019 03:28:19 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hJy5a-0002gR-HZ; Fri, 26 Apr 2019 18:28:18 +0800
Date: Fri, 26 Apr 2019 18:27:46 +0800
From: kbuild test robot <lkp@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>,
	Manfred Spraul <manfred@colorfullife.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: [mmotm:master 351/375] drivers/gpu/drm/virtio/virtgpu_prime.c:43:23:
 sparse: sparse: symbol 'virtgpu_gem_prime_import_sg_table' was not declared.
 Should it be static?
Message-ID: <201904261833.Kd9aE58N%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   244c9142b31406e378f2cf5999774ffcbb919753
commit: 4a323f14cbb77c852f8420baababbe20304d8ce4 [351/375] linux-next-git-rejects
reproduce:
        # apt-get install sparse
        git checkout 4a323f14cbb77c852f8420baababbe20304d8ce4
        make ARCH=x86_64 allmodconfig
        make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>


sparse warnings: (new ones prefixed by >>)

>> drivers/gpu/drm/virtio/virtgpu_prime.c:43:23: sparse: sparse: symbol 'virtgpu_gem_prime_import_sg_table' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

