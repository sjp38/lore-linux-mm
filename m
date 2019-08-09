Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B21DBC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8003E2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8003E2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FDF06B0005; Fri,  9 Aug 2019 01:49:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AF2E6B0006; Fri,  9 Aug 2019 01:49:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDDE06B0007; Fri,  9 Aug 2019 01:49:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8F8F6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 01:49:02 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e39so87518210qte.8
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 22:49:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=zWX+Vst6yzY7OhZtep0LtnfA2lsBkYYYYav7XqT8UVw=;
        b=D+XkAYmfxOIcw/Q32WHCqSNyA9lPL93DaksyxeQ4r8LbF7u4K16YZM9HNLaj+FqGi/
         tbJV2sAVx0m1m5h1UFVQIJkHk7bE4PxZQ/vLvLxH5bhmfgqMfnGnngKXwsNclu0Y/cgP
         +wpxHbeARhUPhCT0GMbMFX6FPMi61AZMTzUBQYS9kj4E1eboVhFN+zbsoaUg5W8SChvc
         iZjGkNSGGgMdFRyUU5+FXZb3gv/jG1Bav+2SRoPFLHoLrNMLeISnqd2xEzM4bVEb05fq
         N5ccQ6jL+4jKRDh2fnGmpEnoX67sdj4oh2trHj5zCDPFVwdjroCWp88+E/WMs9RIJAWI
         KNiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUquYePlRmdWJRu8eK5Sn6rc+Q/02aMljg0hbzOcCEdxhPoUdbK
	ejk2zQbEyns0h47QlnY2vzLgbIiGiuAhonoCxjLNn4c7m0+6JezHlUYrpNzOHTqpL59wzYsyUEH
	lXmnIZsdIBYPmZubWhGnmkvarOhavDCQyFIIkt2g2nVooxzhp0MktAiY/29J2lAL/aw==
X-Received: by 2002:ac8:1410:: with SMTP id k16mr16210568qtj.335.1565329742604;
        Thu, 08 Aug 2019 22:49:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxd2E547ruhNf1fc/gg4sxs9r6/+zzabr7JG0HLQepJcrgoHnH9oI7ciNjPsirmyNDhK7CD
X-Received: by 2002:ac8:1410:: with SMTP id k16mr16210549qtj.335.1565329742001;
        Thu, 08 Aug 2019 22:49:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565329741; cv=none;
        d=google.com; s=arc-20160816;
        b=0F6UX3leyvpf0vXIS0kMzrloPTOX4NnaJp7UeIkxI8t5ljFIcFEvQ8mXWv4cYceCth
         e4U2/LiNTQXVk+7UhNOQZXRqT85c6aXd4yNY+Bvqko/WXgGVa5Td4PfEf0eacEp1XMwz
         HrN3jXuE4x1sguEq16VFcxfzGJEHOlOI2+E5jIZIWwqu5rIYYa2pPaac4FMxmIJmnW11
         d6vkGhGENxkP6cgW5aB1Cr/Xee3KPSUERiun1/vkWDmevMeKRs9trg1i699vjT/dEWHL
         Fb7WJahe+L7VIZnrCIDWmCq4jw++FrZ3d+aPn5njG84QGfq/RBvqjYu2UsgKyeZ332F9
         9xDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=zWX+Vst6yzY7OhZtep0LtnfA2lsBkYYYYav7XqT8UVw=;
        b=EZWfMW1wBBqSlcEIerOS8ODpoERwbcK3HGudnjd82Af9puUiTXgeMIGb7CL+sgBiov
         IaOieAweKscGmDOTqpNSoKLOgICXtkBCA4DqoKRMtyrrDEPOlyXeIl53kQLZe6JlRFVR
         U2C8eLzWDVL6qypcHjMtlIAKuuhJ7sq7GP5zeNDTdI1aAAdTfQ4ZGuyFs10IqX84b+cD
         mwLs38lIJ2fI5Pcl5UJ1XdxdRmIT2zb1+8aA2x2AzpJWbjvnXoT6k7pQeQCzN/TzmXbC
         qzovFrK+0RdIu+q6y8lrLaNjQZ9TTOCC5gZsB4T0WIdBgt5L+RsMs9AYKRDw90Sx+kxT
         j0jQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o48si59829919qvh.213.2019.08.08.22.49.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 22:49:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0B06E7FDCA;
	Fri,  9 Aug 2019 05:49:01 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7F0835D9CC;
	Fri,  9 Aug 2019 05:48:56 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V5 0/9] Fixes for vhost metadata acceleration
Date: Fri,  9 Aug 2019 01:48:42 -0400
Message-Id: <20190809054851.20118-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Fri, 09 Aug 2019 05:49:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all:

This series try to fix several issues introduced by meta data
accelreation series. Please review.

Changes from V4:
- switch to use spinlock synchronize MMU notifier with accessors

Changes from V3:
- remove the unnecessary patch

Changes from V2:
- use seqlck helper to synchronize MMU notifier with vhost worker

Changes from V1:
- try not use RCU to syncrhonize MMU notifier with vhost worker
- set dirty pages after no readers
- return -EAGAIN only when we find the range is overlapped with
  metadata

Jason Wang (9):
  vhost: don't set uaddr for invalid address
  vhost: validate MMU notifier registration
  vhost: fix vhost map leak
  vhost: reset invalidate_count in vhost_set_vring_num_addr()
  vhost: mark dirty pages during map uninit
  vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
  vhost: do not use RCU to synchronize MMU notifier with worker
  vhost: correctly set dirty pages in MMU notifiers callback
  vhost: do not return -EAGAIN for non blocking invalidation too early

 drivers/vhost/vhost.c | 202 +++++++++++++++++++++++++-----------------
 drivers/vhost/vhost.h |   6 +-
 2 files changed, 122 insertions(+), 86 deletions(-)

-- 
2.18.1

