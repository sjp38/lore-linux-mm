Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 855DCC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:27:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29FC2206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:27:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZrRacyXd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29FC2206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD20E6B0003; Thu,  1 Aug 2019 18:27:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B82B56B0005; Thu,  1 Aug 2019 18:27:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A24626B0006; Thu,  1 Aug 2019 18:27:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 788F36B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 18:27:04 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id r2so40111064oti.10
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 15:27:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=jjVaiL9PlJtpvUqKX80XgUrDQiaG4FJpJKI6tyDVArI=;
        b=IXuDIUMs7wLcWCA8i4nMjoIq5tlrr2KsM6BU5X4MM1IoWzJpaG117rGeQgMO18NGQ8
         9+isGtFriIQYnd8DbJPb+2khercZQrVyBr/TxKBTZUrcg0SuCGRqd36qO/Lrynk/SQKi
         qfXreE51wh4KtawMGhEolVtYHDrwGC8Qvp43pdCREtAGPc+8nKp+c5LX/OTDGsmBGIzi
         fiZ2RDwN0gp6iLNC02spV9MFEVh5bBcF1kknfixUC9khxC9gPPXbi7WvXHhiWclvRh4n
         YF725VVC57FfCmfM+ObyYuMSz6LG8MXHjod+rfbSNIN8X7m8zqHGX6lvVt+ui1TsNgWW
         IoZg==
X-Gm-Message-State: APjAAAU4nGFZT5ndsav5d+f6TLTGzSGV2jiPSxlqNoy8Ubm6I4VCONsc
	yIKWpqeHfTH+mQWaSRVQATxyd9KNp6BDyYH+c/fLDOkHoJOTBqWgv8bCOg4+Fus+4tXvzGJygUH
	Tfz387ewA3U7Ll7SVy9h8QNgBImESkbyYN5dmRKuWGAfhd0VdvspZX2EMrbOUWr5+wQ==
X-Received: by 2002:a05:6830:204e:: with SMTP id f14mr2887204otp.19.1564698424033;
        Thu, 01 Aug 2019 15:27:04 -0700 (PDT)
X-Received: by 2002:a05:6830:204e:: with SMTP id f14mr2887138otp.19.1564698422730;
        Thu, 01 Aug 2019 15:27:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564698422; cv=none;
        d=google.com; s=arc-20160816;
        b=CIsmp+cgmMLUb0OsMRLAsyGTV6mRJeVa9CFkRvijN+21mRvOw/1ZyKhtH4crkFBEBC
         Ri46bqEDysN+EblJIcoHuoT+QqiJW3aSXNzti7ZdG+3OB0Ha7dZD9iluO++m+RV3VP42
         bVnz/VAGvGn5jEsbLSTv62y+zAY1+zV95tLGOiPWc6mEhCWsuvE9jsREOjGCnisi359a
         q0rWh6KKtoDSorfcVlp4d2+rROINzgJSQjFtCYEU0+g5IIvnLskk0SGCAtT3XAgLlgJD
         okEAy+WsOCHlhzvk8pYfGhRXyzogZjR8Vr+4lkazJ4mZYQlCum18WlsJ6pPX+dSfmgPP
         Z+2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=jjVaiL9PlJtpvUqKX80XgUrDQiaG4FJpJKI6tyDVArI=;
        b=YyaWnKKGdJ01gtrzzcxmHDrV9w2wIemdr6aeYXir/979STuxBpBMgTnX6goD/m9H/A
         cq1Sjx8vCzSMD0FFwyBlsJfonZvH0VqjXzijkNl1Yw+jfXToJ/aOK5R4BLOXUJPc9pYy
         lEmyoNiyICzloBkdJVWC9ur/nLaKkhIfLNaQazcEd2y0sfJIi14UwFVEmWAOHBbu5Om1
         GcGVoHjx1zoVXeBOAk0Etc9w4Wm12zJV9vsNEMl9Yy/NHlo4CTNypvGS2DmSfAGb4Hmq
         XDTTVLdxaVYwRelcvqjrZZFo9EluBZhzvv4EFCn+/Yus76/ILtFVsvW8dRd/9LVhp9LC
         KlXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZrRacyXd;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r186sor32028546oie.76.2019.08.01.15.27.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 15:27:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZrRacyXd;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=jjVaiL9PlJtpvUqKX80XgUrDQiaG4FJpJKI6tyDVArI=;
        b=ZrRacyXdKI8lnbczd4//nr2xpTwQ3BkyvQbkNShzIE1E0SDVfeul5NXlmgkWqQfJTG
         omf/6sfYJ95+PhEEsADPMGwTXt2GOvqIDxePdxXajthC8lzqpON1/ZHPp7/YI3F2HvtX
         L/4pSxQvxeC40ffelKuabrC9d5+9G3Zca2k1WVIsj+pIK/8DrACq9tky0Ssc5t//qtZY
         y27zx5mVNxtBnCOy3OpXcZ30VWvM8T6XyBiMJm853KEJlphOE6SDcZRM1STFMg1kQnUp
         ej0iCu1ArOTU7GjQicbQAfy9u5GCQphYefiPdQ4vu406H8OIWTGJlpZTYn6TagPI927N
         sXEg==
X-Google-Smtp-Source: APXvYqwz7cn/2YMdeMQ0x9s9lVejvU6i/X+Wfx1SCCjJ0F2gKCgp6QocGTmCTwFXuNThq4TZh5DfzQ==
X-Received: by 2002:aca:bf54:: with SMTP id p81mr718285oif.1.1564698422089;
        Thu, 01 Aug 2019 15:27:02 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id i19sm24559702oib.12.2019.08.01.15.27.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 15:27:01 -0700 (PDT)
Subject: [PATCH v3 0/6] mm / virtio: Provide support for unused page
 reporting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Thu, 01 Aug 2019 15:24:49 -0700
Message-ID: <20190801222158.22190.96964.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series provides an asynchronous means of reporting to a hypervisor
that a guest page is no longer in use and can have the data associated
with it dropped. To do this I have implemented functionality that allows
for what I am referring to as unused page reporting

The functionality for this is fairly simple. When enabled it will allocate
statistics to track the number of reported pages in a given free area.
When the number of free pages exceeds this value plus a high water value,
currently 32, it will begin performing page reporting which consists of
pulling pages off of free list and placing them into a scatter list. The
scatterlist is then given to the page reporting device and it will perform
the required action to make the pages "reported", in the case of
virtio-balloon this results in the pages being madvised as MADV_DONTNEED
and as such they are forced out of the guest. After this they are placed
back on the free list, and an additional bit is added if they are not
merged indicating that they are a reported buddy page instead of a
standard buddy page. The cycle then repeats with additional non-reported
pages being pulled until the free areas all consist of reported pages.

I am leaving a number of things hard-coded such as limiting the lowest
order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
determine what the limit is on how many pages it wants to allocate to
process the hints. The upper limit for this is based on the size of the
queue used to store the scatterlist.

My primary testing has just been to verify the memory is being freed after
allocation by running memhog 40g on a 40g guest and watching the total
free memory via /proc/meminfo on the host. With this I have verified most
of the memory is freed after each iteration. As far as performance I have
been mainly focusing on the will-it-scale/page_fault1 test running with
16 vcpus. With that I have seen up to a 2% difference between the base
kernel without these patches and the patches with virtio-balloon enabled
or disabled.

One side effect of these patches is that the guest becomes much more
resilient in terms of NUMA locality. With the pages being freed and then
reallocated when used it allows for the pages to be much closer to the
active thread, and as a result there can be situations where this patch
set will out-perform the stock kernel when the guest memory is not local
to the guest vCPUs.

Patch 4 is a bit on the large side at about 600 lines of change, however
I really didn't see a good way to break it up since each piece feeds into
the next. So I couldn't add the statistics by themselves as it didn't
really make sense to add them without something that will either read or
increment/decrement them, or add the Hinted state without something that
would set/unset it. As such I just ended up adding the entire thing as
one patch. It makes it a bit bigger but avoids the issues in the previous
set where I was referencing things that had not yet been added.

Changes from the RFC:
https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
Moved aeration requested flag out of aerator and into zone->flags.
Moved boundary out of free_area and into local variables for aeration.
Moved aeration cycle out of interrupt and into workqueue.
Left nr_free as total pages instead of splitting it between raw and aerated.
Combined size and physical address values in virtio ring into one 64b value.

Changes from v1:
https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
Dropped "waste page treatment" in favor of "page hinting"
Renamed files and functions from "aeration" to "page_hinting"
Moved from page->lru list to scatterlist
Replaced wait on refcnt in shutdown with RCU and cancel_delayed_work_sync
Virtio now uses scatterlist directly instead of intermediate array
Moved stats out of free_area, now in separate area and pointed to from zone
Merged patch 5 into patch 4 to improve review-ability
Updated various code comments throughout

Changes from v2:
https://lore.kernel.org/lkml/20190724165158.6685.87228.stgit@localhost.localdomain/
Dropped "page hinting" in favor of "page reporting"
Renamed files from "hinting" to "reporting"
Replaced "Hinted" page type with "Reported" page flag
Added support for page poisoning while hinting is active
Add QEMU patch that implements PAGE_POISON feature

---

Alexander Duyck (6):
      mm: Adjust shuffle code to allow for future coalescing
      mm: Move set/get_pcppage_migratetype to mmzone.h
      mm: Use zone and order instead of free area in free_list manipulators
      mm: Introduce Reported pages
      virtio-balloon: Pull page poisoning config out of free page hinting
      virtio-balloon: Add support for providing unused page reports to host


 drivers/virtio/Kconfig              |    1 
 drivers/virtio/virtio_balloon.c     |   75 ++++++++-
 include/linux/mmzone.h              |  116 ++++++++------
 include/linux/page-flags.h          |   11 +
 include/linux/page_reporting.h      |  138 ++++++++++++++++
 include/uapi/linux/virtio_balloon.h |    1 
 mm/Kconfig                          |    5 +
 mm/Makefile                         |    1 
 mm/internal.h                       |   18 ++
 mm/memory_hotplug.c                 |    1 
 mm/page_alloc.c                     |  238 ++++++++++++++++++++--------
 mm/page_reporting.c                 |  299 +++++++++++++++++++++++++++++++++++
 mm/shuffle.c                        |   24 ---
 mm/shuffle.h                        |   32 ++++
 14 files changed, 821 insertions(+), 139 deletions(-)
 create mode 100644 include/linux/page_reporting.h
 create mode 100644 mm/page_reporting.c

--

