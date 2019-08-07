Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17CDAC19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE71C219BE
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE71C219BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 896CD6B0006; Wed,  7 Aug 2019 03:06:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 847676B0007; Wed,  7 Aug 2019 03:06:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 736CC6B0008; Wed,  7 Aug 2019 03:06:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5016B0006
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:06:25 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id z13so78202607qka.15
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:06:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=AP5FZTII1n/A8SG7ECXrpCmzGPQ+yGdxbzhifUtQ0w0=;
        b=Yb1y1F0pTA8WdlEKdcw2qAcESa2EvpMHTMnMmWs+IfFDY1aB9K58+i7mq1Qm2IT3AC
         AilfaNKtS0BH/OSOrbR2czmiuEgwTQAtJMGvTzv+yLT/+nufzu6jj5cL1TDXnkdBKm48
         TuP5jDIWuBohGeLwBNTQMs0uXvx+E7uaDxHymgeOXz6Oj5fYjTPfRi3QKanJDqpN6rzJ
         2X3thCgc7bNrEeL+yOuhCbzJwL6sGH09UP5FVKsl6OXOXPI5laWYkH1c+AyqlVdyFbGn
         vanUfi5o124FoABEuPafYahC02635yYX8aTmBoY/Qdbn78Z3fmcbgrg6fKivULhhqLN1
         LAmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUr+IBcABxG2KGlNKGR/6aJDjiLZ+X59uCmlZSV5OyxOv8pSYtx
	7iq9C13+j7/JcRkd/w2nqq7J0HCEHOCRfbsyCdG6Ml5JV2yuisyvWQJL1TybKTf/uLragDx2rvT
	yhr6DQTGpGGwR5AQAkcVgLTkhRHuJx51h+XUMGFq+e6y4hQ9dSmDvhlFhO/nJVqARVA==
X-Received: by 2002:a05:620a:11a1:: with SMTP id c1mr7060962qkk.234.1565161585128;
        Wed, 07 Aug 2019 00:06:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2VsD59IZh7sqfa4WZRutfgf9TqtHwjJDm1xNDldb4zLknOiybnSA4DgalSIcFHkQ/ooKE
X-Received: by 2002:a05:620a:11a1:: with SMTP id c1mr7060935qkk.234.1565161584612;
        Wed, 07 Aug 2019 00:06:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565161584; cv=none;
        d=google.com; s=arc-20160816;
        b=zwbYag6Baar6XnC394XhSG4aUMvNFJ3lQvXujnMg4HPjAm518kizC02NAJXuqbsC4s
         LV6Bnwz1or10yWtGGI7hJy4RGey3jkADTmKvM9M0dWrS0adrSWag/RUETGDV2sqmTUIh
         rbSOmB3nNWThoyGvnws3ntJ+qphkDoWK0y8DV9H9MCl+EPq8oQIitYDn7CgnfRga75La
         K+qaKdSnTP+qwEEVwBGOuoeMcNF92jXk6crLfGGyaL7d10mfy+UQNPNEt3o7ORkLXXOS
         8m7aQzX8cKJNAdq1aPa4rvyfWKS8YzzCNLBm3WA4KW3VBhCdsJq+hMDiNE26h0mgJarf
         uG8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=AP5FZTII1n/A8SG7ECXrpCmzGPQ+yGdxbzhifUtQ0w0=;
        b=mHMIdJHL4wY17evC8CKgFdc16KrtTlQmcian3MTYMURBkJ1rTTZFuia35AChyux6Zc
         PVgGvzYPvMBr4FHb9ub9GL15i/gWEHONepLJk4WztJiXBNWXfgLGCQveGnyyqKIg+kz1
         36bySJ3PBKIlDuakN8R6MKsMl/eIuzBRXzO30phTjgtM6CaiRwKsI2vdLcrME4u6yWjI
         0D8+eCcpliyVm95aJ7Js7FJt03wC7ZO+IUL1t028oa7wK6BLV14DrAAmOTxtgr2HL/nF
         JB5DWv3C5Gw8KTA8XXrLKlLeCxenV+Z91AjUEcpRktD6MzgpwJ20AXKrXTKGKf02HK3d
         aKPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r18si54072607qtr.225.2019.08.07.00.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:06:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DCA1530BA1B4;
	Wed,  7 Aug 2019 07:06:23 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 60E0E1001284;
	Wed,  7 Aug 2019 07:06:18 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 0/9] Fixes for metadata accelreation
Date: Wed,  7 Aug 2019 03:06:08 -0400
Message-Id: <20190807070617.23716-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 07 Aug 2019 07:06:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all:

This series try to fix several issues introduced by meta data
accelreation series. Please review.

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

 drivers/vhost/vhost.c | 228 +++++++++++++++++++++++++++---------------
 drivers/vhost/vhost.h |   8 +-
 2 files changed, 150 insertions(+), 86 deletions(-)

-- 
2.18.1

