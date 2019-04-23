Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6491BC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 05:54:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FE7620674
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 05:54:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FE7620674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78A886B0003; Tue, 23 Apr 2019 01:54:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 739FE6B0006; Tue, 23 Apr 2019 01:54:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64F996B0007; Tue, 23 Apr 2019 01:54:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44E776B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:54:34 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c2so5222294qkm.4
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 22:54:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ozHkI1tdHT6K9njS2BHY6xzBbBZOu+x6Avha9rpzQeA=;
        b=SftQiPH5PpUqQxnLzJheWZLl/kY4zfFwXaegNJRp+vjYMN8gpYR+3D3cUEfnARGYGH
         iahbzQm9Gids3J/CrxAcf+hGCrqjBH/bghT5agJsI3P6jeQaa0ZMYy9seRLehXFfijl1
         /x2hX/K7AKfUeCkFWYxdRqv+LD7FOj9jjWYUzLyFMzTq0MCaLREbgGWYIgoMKmrnaDRd
         Iq//+/g9fW4eiu4eCcAlaDSB9SOE/DFdmkVgFTHkqFAyK4S89BpshalqBoj3RCImHDeJ
         X70bmsLEyriO6x+N2CWIQlGRJSmS8rCg92sMW2Gczk2dy4sDPbMqhefXSP29VDYjtcIR
         WcRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/RccROUHCPz2W/Kr2uSSKHQQudoWMy8eKIms1oRLrE01ffpZ8
	9A7j65yuKO4+9gYiH5gKZQpxxJoS5l7OAvXz8MvGb7bzDcQWRKYdt+hl8wwYEiCBE7HgK4FIjxz
	ICkPhfh661xK+Eb09m53zs7xniaIZ4dHyZdQ6+xvEx46DtdgGQl65G/chF9CyNHmPcw==
X-Received: by 2002:a05:620a:c:: with SMTP id j12mr17999779qki.227.1555998873929;
        Mon, 22 Apr 2019 22:54:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmiNU7Nj5+IiYyBT3LcKbp/V44e7Yd+XtxlEH5JExNtXoxSUNfyCwKtZrAbqfi9Xk8jUZQ
X-Received: by 2002:a05:620a:c:: with SMTP id j12mr17999744qki.227.1555998872817;
        Mon, 22 Apr 2019 22:54:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555998872; cv=none;
        d=google.com; s=arc-20160816;
        b=zUouMoOpI1uAsXQ2jlygKs7WLTL5an81usZpkQ/eHKn+sqZ6+q/1S7xIq6X5K7ob6y
         f58A3noWX2iZ5d6MnqfaFpFSyi3eEDFtm1dWXYNH54xln9QlTNX1SPsktqPGy2tqbjrH
         lA8W/8zblUhURCnmfPFhzduOxym5Lw+V8tIARGwI6+v0n4EVM79GG/KnP95lEGgQd43P
         ATkDecU/I1Ru+IZCDuiHD8MAGN1FMGk2Wp2zCxJ/a/F4/vG6i6O8l+RyiMTju8KDZXUF
         FuL4uQL+XttM7/51CaDwWln12h31RXtoGz4GX4r5Oc0/F396XUxeE1A3jc3251rG46mV
         zIsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ozHkI1tdHT6K9njS2BHY6xzBbBZOu+x6Avha9rpzQeA=;
        b=qCtIj9ah4/ZL37nI6D3WqvGcd6AWYCVW6lTjiXXM4HhiG74/DL88R0vwEnlPIoTv+M
         CbtsFW/kY4eUn4uRZ81h4xLMKtYSbnmEsNhjQ751xEiN6LkwXUxmlDJRhOlGU9ZpJ+LE
         6NhFn4QEJy8lDXxVPjCY9Wq4kuXRUwMcmS3OwvgQ/Xzr5qNqlSvAFIQf8V3ybON2ArV7
         kpzXZp811P7CJ0oEiR93eUaD+19XImbXFZaENtf/R7Wpolm2Wy2HwLKlRPYXyg8iuEyU
         0wCwhwji0oa2QWtDMsJI9iOhrk8qXQpAM+0feTAGbUgIhDUMFfkYyQsf5pxH4ZZWG+H9
         gh5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y7si1012660qkf.119.2019.04.22.22.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 22:54:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D805D20277;
	Tue, 23 Apr 2019 05:54:31 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7040E19C7E;
	Tue, 23 Apr 2019 05:54:22 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: peterx@redhat.com,
	aarcange@redhat.com,
	James.Bottomley@hansenpartnership.com,
	hch@infradead.org,
	davem@davemloft.net,
	jglisse@redhat.com,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org,
	christophe.de.dinechin@gmail.com,
	jrdr.linux@gmail.com
Subject: [RFC PATCH V3 0/6] vhost: accelerate metadata access
Date: Tue, 23 Apr 2019 01:54:14 -0400
Message-Id: <20190423055420.26408-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 23 Apr 2019 05:54:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series tries to access virtqueue metadata through kernel virtual
address instead of copy_user() friends since they had too much
overheads like checks, spec barriers or even hardware feature
toggling. This is done through setup kernel address through direct
mapping and co-opreate VM management with MMU notifiers.

Test shows about 23% improvement on TX PPS. TCP_STREAM doesn't see
obvious improvement.

Thanks

Changes from RFC V2:
- switch to use direct mapping instead of vmap()
- switch to use spinlock + RCU to synchronize MMU notifier and vhost
  data/control path
- set dirty pages in the invalidation callbacks
- always use copy_to/from_users() friends for the archs that may need
  flush_dcache_pages()
- various minor fixes
Changes from V4:
- use invalidate_range() instead of invalidate_range_start()
- track dirty pages
Changes from V3:
- don't try to use vmap for file backed pages
- rebase to master
Changes from V2:
- fix buggy range overlapping check
- tear down MMU notifier during vhost ioctl to make sure invalidation
  request can read metadata userspace address and vq size without
  holding vq mutex.
Changes from V1:
- instead of pinning pages, use MMU notifier to invalidate vmaps and
  remap duing metadata prefetch
- fix build warning on MIPS

Jason Wang (6):
  vhost: generalize adding used elem
  vhost: fine grain userspace memory accessors
  vhost: rename vq_iotlb_prefetch() to vq_meta_prefetch()
  vhost: introduce helpers to get the size of metadata area
  vhost: factor out setting vring addr and num
  vhost: access vq metadata through kernel virtual address

 drivers/vhost/net.c   |   4 +-
 drivers/vhost/vhost.c | 852 ++++++++++++++++++++++++++++++++++++------
 drivers/vhost/vhost.h |  34 +-
 3 files changed, 764 insertions(+), 126 deletions(-)

-- 
2.18.1

