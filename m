Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FF6CC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 08:19:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F27021670
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 08:19:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F27021670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 869816B0003; Tue, 30 Apr 2019 04:19:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81A376B0005; Tue, 30 Apr 2019 04:19:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 708306B0007; Tue, 30 Apr 2019 04:19:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 380B56B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 04:19:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f41so6037382ede.1
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 01:19:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LzrBFyiCT3NW6gf4dZLakChxDJCS2ayk4FCGvycr/8I=;
        b=idTV6NYnQENxaKK3PG8f/nprYzW7oVaHVXgVTbHaTChxsArPcmlMp6wftFtpLmzfwb
         SF2aev3ltNUjlQX2xE0bGofwM8x2v9tEp1TvvjlMvxNT6vcS4GhYCIMm/68mbwIMJzdg
         I1iLYrxEcUxsoI4TU3YncGSxqhzpaYBafZlLyO3gpYckARgb4DbNW/2HJfQ/xrdLXEki
         nXjuODPMB1Z0SIma5JyDfopL7hlyqlV10cHBD1NPzg/pX8s79i78WwwWnkdz48s/p+6C
         8fipHpeIhSRiu4Ba2XKr9d6L3c6h3qhkQbEp1/2M7mP9SIew5WiA7t6swGKl+bWOVlVp
         ahEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAUtH3bxbWJP14linRjh1U0eou37zGkAYu7OyhFm934OkadiwITG
	1HJe4ruf25W0eXLPgPblUImOM29qa9aSopZ8z32zYvQGVulqKbxDLovMXeZD/3bZuyeUkQVz6eL
	D2Zr4vt/RPmV1f4WbKHMKZiSGomjKeu+EcAQTRu+BIWXzx5ujC905P8JLCu00+3kxpA==
X-Received: by 2002:a50:9a02:: with SMTP id o2mr40932604edb.182.1556612366573;
        Tue, 30 Apr 2019 01:19:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqn56Md+aslq3SiqupvmQEaqfgUrKYRoZgZPLJP671tb+68ASZXz2caJrusYMh6o46lwr/
X-Received: by 2002:a50:9a02:: with SMTP id o2mr40932551edb.182.1556612365488;
        Tue, 30 Apr 2019 01:19:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556612365; cv=none;
        d=google.com; s=arc-20160816;
        b=UsR2qZ6A0x0F4lAAbPbdzs2hhbntBHXqObf/r+o7PFn1mKWv5k0T3KgJSQeXmFCQOj
         OzhhWOv31k37RyAhc4QyKv2UyCNm87VRvtdciVKG6086uDatdulO/qMw0xUNXzOc1ALH
         Lq8tca1ZrI+XaN5VWXhUXIKy7P2dxryhUJNCpLQU5eEt9TMxQ7RrIdKpaV02MXPc+/Ip
         MwUWHJZ4j14BETmLcCdJKxoqaJ4OZbTyMdxaoOxigVyeXpqBCWFRP2kDatn14QrqNVT3
         2ppx926Wj5pX9VCeKGJhE5WSLys0bssc0Cms66+AtOWPxi7vHJPAJYdl+wpyZ6ImOfJQ
         MPmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LzrBFyiCT3NW6gf4dZLakChxDJCS2ayk4FCGvycr/8I=;
        b=uYmSaqC3amPBSmqDqqoL9+s+yz3V+irmvvamr6/95CNUiMpStaJuN+cVi3yBrglc97
         HvBx3ep9/w1bjXwcEy4qPvoMYxyruXcoRWCinaT/LpVEuc9dGTaINKf6+FTv6l853nuy
         OwVcYOKmx8I92Dqz8iCYlOGZbfO8+Y0UrEi0Dp17SvnP7z9w4A12AEMJSXzBXQfWgZDg
         jPFgM+zicheh+7aEgXyhODy6dy6a4MLsCDIHZLcYEfV71v0lVIxxj9eEIW0xmwSBZu+/
         i7/0N3e/LUwhcrSfMcu5KUvfau8vNnLKaMyfxvkgHAg6nHqvCJyDWeIyE4nwkxuo0Zt9
         NyDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l7si98882eda.21.2019.04.30.01.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 01:19:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B7A6FAE3F;
	Tue, 30 Apr 2019 08:19:24 +0000 (UTC)
From: =?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>
To: gorcunov@gmail.com
Cc: akpm@linux-foundation.org,
	arunks@codeaurora.org,
	brgl@bgdev.pl,
	geert+renesas@glider.be,
	ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	mguzik@redhat.com,
	mhocko@kernel.org,
	mkoutny@suse.com,
	rppt@linux.ibm.com,
	vbabka@suse.cz,
	ktkhai@virtuozzo.com
Subject: [PATCH 0/3] Reduce mmap_sem usage for args manipulation
Date: Tue, 30 Apr 2019 10:18:41 +0200
Message-Id: <20190430081844.22597-1-mkoutny@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190418182321.GJ3040@uranus.lan>
References: <20190418182321.GJ3040@uranus.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.

(apologies for late reply) I've aggregated the two previously discussed patches
into one series and based on responses made some changes summed below.

v2
- insert a patch refactoring validate_prctl_map
- move find_vma out of the arg_lock critical section


Michal Koutný (3):
  mm: get_cmdline use arg_lock instead of mmap_sem
  prctl_set_mm: Refactor checks from validate_prctl_map
  prctl_set_mm: downgrade mmap_sem to read lock

 kernel/sys.c | 55 ++++++++++++++++++++++++++++---------------------------
 mm/util.c    |  4 ++--
 2 files changed, 30 insertions(+), 29 deletions(-)

-- 
2.16.4

