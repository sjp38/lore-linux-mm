Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E614C43331
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 21:41:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 201E42081B
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 21:41:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EF6LYsvW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 201E42081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9601B6B0005; Sat,  7 Sep 2019 17:41:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E94F6B0006; Sat,  7 Sep 2019 17:41:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B05C6B0007; Sat,  7 Sep 2019 17:41:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id 54DBD6B0005
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:41:19 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0469B180AD7C3
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 21:41:19 +0000 (UTC)
X-FDA: 75909445878.13.fruit89_45a54c6001726
X-HE-Tag: fruit89_45a54c6001726
X-Filterd-Recvd-Size: 3594
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 21:41:18 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id b10so4813412plr.4
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 14:41:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=wEzd7dh/YfO3zGLSxxCdwFOAGiIma8fe0owdbCkXYmQ=;
        b=EF6LYsvWkXNSwOEXeE/6qHUB7pHfQ83htTle+NmPGwqybQ6Pt0jKRg4Wa27sovW/ni
         NmrFujKRHtQXBDBdP9pkAfvI/6w4T+Y436JlzgoPW7FqV4ThEqdq7dako9+HV19cPW4n
         /uZifgpZfEjT1YGD9+BmbMXz3a54nSaZZ/2PoVfnygssJ6+GC5SuurZ99ysJED63QoPf
         act/g/bReiNpFjOvKy+IJTpJWLw4EZQb53OaOxz4GoJb+2ZCDr1qolmeiWXw2XPvBuxu
         XKQ/cNXPoDcQN5fBaoqD+XzWJqozOZfyfMy9465SkLtiM2n+LCifhb0iKgepQvpSwQcs
         px7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=wEzd7dh/YfO3zGLSxxCdwFOAGiIma8fe0owdbCkXYmQ=;
        b=FiuD0onxwgVNGB0RzXp+Z9K1JoW97vBVRWU/f3ZXy//NngxUvlVh6JzUKL84WE27oI
         YfLBd1Hrhc7PcAtVJl//SK8q+wwGHCnfdLEXk9T6HWE5TyejzrO/kcKMmYxc5rURfDEw
         lpLqcZxLRagNMNHZEpA0ln9ioLIb6sY1kCtiKSo9NVkHQeTHDXiJFyOE8e5Wyl4RyG/g
         H4LwXN1o0v7gQJ8/iXM51xPFuQveFkuVvItu2rnMQi4lcZv+aAZwqtVd29nDLKJIPc+o
         FoitutwgHs0rDDf8d5Wq30isukdfWCNxgvKCgenbVGSgMk6LNd4Il4ntHRY66YQCovdT
         TliA==
X-Gm-Message-State: APjAAAU/EJO/TevwTJi4XmBBZeepF9nYBCvGgtRmeDTDbDrFkJ7VgHes
	77+NVhxHhZ4TPRDyacGHtwY=
X-Google-Smtp-Source: APXvYqz+VvW5vydphQSj0ObTAVGfP2jazOrVP9sq7QamakSG2pDZ3tjxjHqAy590l89owgeU1hfKhg==
X-Received: by 2002:a17:902:8686:: with SMTP id g6mr16403651plo.175.1567892477461;
        Sat, 07 Sep 2019 14:41:17 -0700 (PDT)
Received: from localhost.localdomain ([112.79.80.177])
        by smtp.gmail.com with ESMTPSA id h11sm9078516pgv.5.2019.09.07.14.41.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 07 Sep 2019 14:41:15 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com,
	sashal@kernel.org,
	boris.ostrovsky@oracle.com,
	jgross@suse.com,
	sstabellini@kernel.org,
	akpm@linux-foundation.org,
	david@redhat.com,
	osalvador@suse.com,
	mhocko@suse.com,
	pasha.tatashin@soleen.com,
	dan.j.williams@intel.com,
	richard.weiyang@gmail.com,
	cai@lca.pw
Cc: linux-hyperv@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH 0/3] Remove __online_page_set_limits()
Date: Sun,  8 Sep 2019 03:17:01 +0530
Message-Id: <cover.1567889743.git.jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.004685, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__online_page_set_limits() is a dummy function and an extra call
to this can be avoided.

As both of the callers are now removed, __online_page_set_limits()
can be removed permanently.

Souptick Joarder (3):
  hv_ballon: Avoid calling dummy function __online_page_set_limits()
  xen/ballon: Avoid calling dummy function __online_page_set_limits()
  mm/memory_hotplug.c: Remove __online_page_set_limits()

 drivers/hv/hv_balloon.c        | 1 -
 drivers/xen/balloon.c          | 1 -
 include/linux/memory_hotplug.h | 1 -
 mm/memory_hotplug.c            | 5 -----
 4 files changed, 8 deletions(-)

-- 
1.9.1


