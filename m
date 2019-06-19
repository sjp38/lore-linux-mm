Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E78B6C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:32:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0363215EA
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:32:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BUWIZKTc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0363215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A15C6B0003; Wed, 19 Jun 2019 18:32:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22BE78E0002; Wed, 19 Jun 2019 18:32:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F3518E0001; Wed, 19 Jun 2019 18:32:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id E33566B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:32:58 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id h4so1498850iol.5
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 15:32:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=7Bg82A9f7f4RunQMoMmcdR9mp3vDHwjyz3/uf1/B6Co=;
        b=C68kwzMwaMKH9WXqa8/O+Ni8K6CEcG9jJ1osU1M79zMwr2lnfpHMMSGRqf5xjZLDL5
         ot6fE5tIKpkAHzfwlHPXnWVXxyBSZKirDlbhGYSz7LsgkVR3OEt5hyW3zxsrSU4QWDuz
         IRh3PcKviW/dWOXmGsijk40Wt19FhLKhttB9RTMDWyiOhCUSuwAOlRsy3qj7qeQsb4Od
         uKNUJaxyBsNYmwrdRgGmtnaqKikVhcJM8y3YXlCJnDc1+QLoroh+f/KcLuo/QLqwxOec
         lKAhIl/xIvHp+wERNQEEp7M8ur7RwrUnkv2hoe/u2B9Uson9CoLlkpLxFjhdAnCfku1F
         HvwQ==
X-Gm-Message-State: APjAAAViDQeFAG/InLQXPOXMH9p/1WoE7gELZ6rayfYRbsAd9TJ0U3ij
	O6X7QoGf4UNJFKxJ4GYq4G9MJ2JipuVwwzHC7RiAi++fQfeWwiy+6hER7i3a88Bo6nLcPPyRPbm
	9NBB/LmTOru+2GVmcY4uGjiZc1ygp+ia9jYP0ho6boWs/xxGPkYiJsBz/hwQuLR7uEA==
X-Received: by 2002:a05:6638:cf:: with SMTP id w15mr4576387jao.136.1560983578602;
        Wed, 19 Jun 2019 15:32:58 -0700 (PDT)
X-Received: by 2002:a05:6638:cf:: with SMTP id w15mr4576309jao.136.1560983577660;
        Wed, 19 Jun 2019 15:32:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560983577; cv=none;
        d=google.com; s=arc-20160816;
        b=SjN6zQwoWd8tJgNuY024t2f6ieM6PXou6N+xvokHfmM7pA7qk6C6W0n/RMNjcaJKDo
         pkLekJZJhbjY7KFA0YwIh/vaRFZy7PJAjCkzOaswcUoTb/tnmGkI7tuXuk/OIFWbU36d
         n118zOCv4jbUBhDGy/wEGwc27MifvGxCJLAFPqzjsP83ZU95FeYoU3hsD4UO/groNxOY
         9MbtbIMN0EC89RlQpGMetsYtrins4OoBPk9HbG5AjSWrL07J7Hox7ouWSNJjeuJG+X6M
         p9yHkLgog+/E42riBJOQNrzTDcF6KNwf3O/FB/IlqDZsczxu00+TS9LsWRRPz9CTK/CF
         fNXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=7Bg82A9f7f4RunQMoMmcdR9mp3vDHwjyz3/uf1/B6Co=;
        b=vfhtyXuetKmzczicNOykP6fx3p13glqNT0hvAexdzqLNB4v19yQdDxmpiwmblPH/WP
         FtC8BLwz6vzVuscuyyLS3DIJQaeQzd5Hl8c4p8dpg/gs7GXzP3vkMqr20goGNMN+n2M9
         IB/nSddXnxURzDddsyDu3OHuURjS7f6dcJtv12mqmv2gJZjw9lICNSq2I0KLFRtJskT1
         M1bJbL3Nt03m3qwb0erWmT7vBUIOFnt+3BD0InHkKYkQKS/7OnAvwrrK2JOSneNhC7gQ
         HVI8zwtbbJw54GwaH1pF021IhjKWeR61Qw7B+lXp5suJLrvvHLAkJW4i4EZmP8L5xmtd
         BTlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BUWIZKTc;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16sor15720147ioj.130.2019.06.19.15.32.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 15:32:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BUWIZKTc;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=7Bg82A9f7f4RunQMoMmcdR9mp3vDHwjyz3/uf1/B6Co=;
        b=BUWIZKTclx11jnrux4XAhfYbZb9dSGSj1E/6bQvoHLxuhBPkUPu+YWpQ485Vs0fgH9
         07d2hF9Ei42SbqfTz984tQe6vqxnkQskw3rVsNYEfHbaKnaapGBySK1QxiHzOTSkV97Y
         6nBcXGDDUa6a3/FQJ75AFUZ8Tfqbp6W19XMBPKiy7uCayarvngTU14fVWpSfa9vbcxgq
         itBs3i+QdUrBieBHvKaJFmqha5z4vfKkgEDoLx/lQq+jrJ9bUWhR/UDWckGSlqSqZ46R
         5SNU3TaZX9oNwUrIneafyL+AqhBCgSHTL5ePKBzU0IIimsQwTAPNrEU9Z+BjjRxXXB4d
         p6nQ==
X-Google-Smtp-Source: APXvYqzc0qIqzB4wleX54UjkFOne7zbe/eiQNSOhbgTRX7xXVEA+CpQehXrV2IP+mVuZvNGNcBZyqg==
X-Received: by 2002:a6b:7b09:: with SMTP id l9mr12963476iop.114.1560983577080;
        Wed, 19 Jun 2019 15:32:57 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id e188sm21987403ioa.3.2019.06.19.15.32.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 15:32:56 -0700 (PDT)
Subject: [PATCH v1 0/6] mm / virtio: Provide support for paravirtual waste
 page treatment
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 19 Jun 2019 15:32:54 -0700
Message-ID: <20190619222922.1231.27432.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series provides an asynchronous means of hinting to a hypervisor
that a guest page is no longer in use and can have the data associated
with it dropped. To do this I have implemented functionality that allows
for what I am referring to as waste page treatment.

I have based many of the terms and functionality off of waste water
treatment, the idea for the similarity occurred to me after I had reached
the point of referring to the hints as "bubbles", as the hints used the
same approach as the balloon functionality but would disappear if they
were touched, as a result I started to think of the virtio device as an
aerator. The general idea with all of this is that the guest should be
treating the unused pages so that when they end up heading "downstream"
to either another guest, or back at the host they will not need to be
written to swap.

When the number of "dirty" pages in a given free_area exceeds our high
water mark, which is currently 32, we will schedule the aeration task to
start going through and scrubbing the zone. While the scrubbing is taking
place a boundary will be defined that we use to seperate the "aerated"
pages from the "dirty" ones. We use the ZONE_AERATION_ACTIVE bit to flag
when these boundaries are in place.

I am leaving a number of things hard-coded such as limiting the lowest
order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
determine what batch size it wants to allocate to process the hints.

My primary testing has just been to verify the memory is being freed after
allocation by running memhog 32g in the guest and watching the total free
memory via /proc/meminfo on the host. With this I have verified most of
the memory is freed after each iteration. As far as performance I have
been mainly focusing on the will-it-scale/page_fault1 test running with
16 vcpus. With that I have seen a less than 1% difference between the
base kernel without these patches, with the patches and virtio-balloon
disabled, and with the patches and virtio-balloon enabled with hinting.

Changes from the RFC:
Moved aeration requested flag out of aerator and into zone->flags.
Moved boundary out of free_area and into local variables for aeration.
Moved aeration cycle out of interrupt and into workqueue.
Left nr_free as total pages instead of splitting it between raw and aerated.
Combined size and physical address values in virtio ring into one 64b value.
Restructured the patch set to reduce patches from 11 to 6.

---

Alexander Duyck (6):
      mm: Adjust shuffle code to allow for future coalescing
      mm: Move set/get_pcppage_migratetype to mmzone.h
      mm: Use zone and order instead of free area in free_list manipulators
      mm: Introduce "aerated" pages
      mm: Add logic for separating "aerated" pages from "raw" pages
      virtio-balloon: Add support for aerating memory via hinting


 drivers/virtio/Kconfig              |    1 
 drivers/virtio/virtio_balloon.c     |  110 ++++++++++++++
 include/linux/memory_aeration.h     |  118 +++++++++++++++
 include/linux/mmzone.h              |  113 +++++++++------
 include/linux/page-flags.h          |    8 +
 include/uapi/linux/virtio_balloon.h |    1 
 mm/Kconfig                          |    5 +
 mm/Makefile                         |    1 
 mm/aeration.c                       |  270 +++++++++++++++++++++++++++++++++++
 mm/page_alloc.c                     |  203 ++++++++++++++++++--------
 mm/shuffle.c                        |   24 ---
 mm/shuffle.h                        |   35 +++++
 12 files changed, 753 insertions(+), 136 deletions(-)
 create mode 100644 include/linux/memory_aeration.h
 create mode 100644 mm/aeration.c

--

