Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CAB0C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 21:11:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7E372177E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 21:11:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7E372177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5992C6B0005; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56E4E6B0007; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AC5D6B000A; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 108B26B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x29so95352edb.17
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:11:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=YReB/SZd25tJDVYEi7c1Vao07+DoqlvR0siXPnd81b0=;
        b=LZ8Tv3EEvOdqb5P0ErtJbWUBR1aV+TmJ8/le2xam1JfRuBGNz8Jx6w3sxAX0YBww39
         ZiBZ79WM11YoiUR2/0ZrrGr6wRsDknVojwxMXDsuAxI4h79qlqJ9dssNp76CYxbTWp+N
         xyTNEltzRrzsqpdCttrvsjfjMTI+/xnzqMOe38qxg+X1PsXzONxO7eGeDduT5Q9SoryA
         R5ui5/Ebv+0I7aSNpOuUD7PcHPrgddux9HdYdfyK3QENqd2RK7+4coOw8c3/RD2ayQj+
         S8fW5PAdv2LyqoXTjGEDVU5ORZ7FaOFiJF4TWSZIVpYhRaXvQEwj/BOUrmdVf+dazV0I
         J33g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUU6epMZ+UFSADL6mwSoG5s3ev90qXBaBV0CdlsMLMW7fs7XpfN
	heuclVIEXH+H59FJyLwjuNnpPTgdBx/4tEkPbdq+QHnpC43sCnDVfQypOtFqEzPX6oQd/XtwayR
	9VVzNOr8hXc3v00dd3zt5N2MVgY9Gn5Evd1ZKc81NFnpIi7mmRh7iQZnwGxTeHX3nGw==
X-Received: by 2002:a17:906:bce9:: with SMTP id op9mr9193172ejb.65.1553029889443;
        Tue, 19 Mar 2019 14:11:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgHglV+PiykZoNY0Rg0MdxbakxFYbHC3lczSMwrO9D1/LF5kyY37YGGQxnDoFrxmAPRYm8
X-Received: by 2002:a17:906:bce9:: with SMTP id op9mr9193141ejb.65.1553029888535;
        Tue, 19 Mar 2019 14:11:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553029888; cv=none;
        d=google.com; s=arc-20160816;
        b=aKziH3GOCBjzbYD45OjbZi0dY622sys1cvGMUQqCmB4Kmul45eI6q6GftrMzIp3nyu
         Fsp2cdZ3JsOVv3jukCRSkR/arEDVuQrbBBCUXuo2p497NeVNwBZDwIGRFsBltEuQ5Ldk
         JhK3/u2PYv/9CDG6PnO0kwAZqyuywxXEIUrEZVOkRLjlKmI8Q0seT0z/UglO+KEtbMDC
         M02E3hTKLP9uBTdTTUfbKCUemTz2n6mwCco2p7qFZFr7NwT1+FVr5F8s4mhWl6gGunCc
         nnzdkpBPLKqjEM2F3JPOoefWLhI3g+QnwC1n0KEy1/s90msmYQfspCDAUW3f3xQ7e1ab
         ARKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=YReB/SZd25tJDVYEi7c1Vao07+DoqlvR0siXPnd81b0=;
        b=UV+unzVv9o39v/dvQZIaYqkx6Q/ckZNh06nRlG4pycXUyagwp/xk/ADEpWQXLL+omT
         qEPoaTfaL4nxgHpLiuQhicTZn8tNlrED4LBKjCrcxcsXwNX0vbPZ36hT+VI8XgF06RK6
         eMmci95IQTheE1CKj9cwbSvUhZsrb3RNf6hIMVWe1xwPCsnXvH+CVaJtXJkyt4NWSh+M
         qxQuA8HLAWe6QDnmL9nBZuu+qiryVUa5Kyi3eBWSZCdog9SQlQ8lMy+AyMqSiGpF0M09
         +eT5RHCbNELeyVS3xkUYkat4F+LlMDQHqUYhA20sx2fjuKoOdUuO9F57Q/YsZHr7jGAY
         H0RQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o20si3501059ejj.243.2019.03.19.14.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 14:11:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 96729B607;
	Tue, 19 Mar 2019 21:11:27 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>,
	Michal Hocko <mhocko@kernel.org>,
	linux-kernel@vger.kernel.org,
	linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 0/2] guarantee natural alignment for kmalloc()
Date: Tue, 19 Mar 2019 22:11:06 +0100
Message-Id: <20190319211108.15495-1-vbabka@suse.cz>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The recent thread [1] inspired me to look into guaranteeing alignment for
kmalloc() for power-of-two sizes. Turns out it's not difficult and in most
configuration nothing really changes as it happens implicitly. More details in
the first patch. If we agree we want to do this, I will see where to update
documentation and perhaps if there are any workarounds in the tree that can be
converted to plain kmalloc() afterwards.

The second patch is quick and dirty selftest for the alignment. Suggestions
welcome whether and how to include this kind of selftest that has to be
in-kernel.

[1] https://lore.kernel.org/linux-fsdevel/20190225040904.5557-1-ming.lei@redhat.com/T/#u

Vlastimil Babka (2):
  mm, sl[aou]b: guarantee natural alignment for kmalloc(power-of-two)
  mm, sl[aou]b: test whether kmalloc() alignment works as expected

 mm/slab_common.c | 30 +++++++++++++++++++++++++++++-
 mm/slob.c        | 42 +++++++++++++++++++++++++++++++-----------
 2 files changed, 60 insertions(+), 12 deletions(-)

-- 
2.21.0

