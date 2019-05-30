Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2CD0C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:53:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69C79261E3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:53:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DrgK6T7p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69C79261E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5A176B000A; Thu, 30 May 2019 17:53:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0CE26B0266; Thu, 30 May 2019 17:53:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF9226B026A; Thu, 30 May 2019 17:53:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 826BE6B000A
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:53:38 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id r11so3462949otk.20
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:53:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=L4eRJoRAM9BshBnywrSkE8cQ8ajHKA/DqmlOsjnC6aU=;
        b=ZuVNF0fczW7QoJCgAw5HjsMHDBaUAI9mB6C3/Y+MolauH2uMJLJc05cKkGIMMDVzLA
         YkEgHF0lSfzoSMpgvMbNQs8/4QD7/ixc8Fbvdvl17dGtSfjmfygiXTTiK9YhV+QkByhQ
         wnCwyIT3hfidsLYELoQ0Eve6iLNN1Pa+9UOHbH2rDKkugFF7B3xdFCG15A0aRF8jsSie
         RoV5bymfgOo3NyagtGTiZVGrg9patV6ZU2ZkcKaMyxE43hb5kXJaODOna9lZG2Fu/Zol
         IJ5dUc9zHx3PiRMDC/YLOi5FLvh/3q1mlyx7SC0052nNbcVZQy6n8RGGszYlotfS4Caq
         khqw==
X-Gm-Message-State: APjAAAWzfry7ffPUpcp5pzsf13QZDkJ+IOAjpDtXnELYwoVN0XM46Etp
	JOokwS7ZGCsvFCGOA5IEXg/BzgHZgZjw3AOrrq5hlVj89++M8+W7IA6vQglDR07saR029cyzxBM
	Jprem3gmQI0NB1ohlD2vjrvhX5EGtNUQV6QaxP8ShZ2Dpmx2Ua76apGDrLDMtEug9Mg==
X-Received: by 2002:a9d:469e:: with SMTP id z30mr4653839ote.311.1559253218083;
        Thu, 30 May 2019 14:53:38 -0700 (PDT)
X-Received: by 2002:a9d:469e:: with SMTP id z30mr4653795ote.311.1559253217216;
        Thu, 30 May 2019 14:53:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559253217; cv=none;
        d=google.com; s=arc-20160816;
        b=HUSsMKg2Qa/NzPjSmeftw5qqT+bt2BCCpcCgZwON/7B9kYSESeF3v19uQVgGKnGCnt
         JfX3odv0ND2bdwUi8flgurKbKN6In/uETGdDdANnDSapDPv30u7Cu7VmVyeZS8nzUdzn
         8jPTV0zEK0MPe3wBGzePkoNU2A/hGh6Yh0XDwhUXd7XlX7bus0KJAg3j0S2+UFEAoTrm
         drjIO+R+QVUk2Eh0HPSyyk4hpQlWStijpDRyDYaa5qlyhWRgWAbtp9FLuL2vMtDoxZ2C
         cv6LO6dTzaRKKBg+YYRzcmpBg41njR9OyBuN88KARAhwTEdDWvIjS7YcUkcE7oYrOPsc
         3a8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=L4eRJoRAM9BshBnywrSkE8cQ8ajHKA/DqmlOsjnC6aU=;
        b=DCuZf3oMQ7KOBx53r37X/IHh1iPfO4tt2dunlT6k5Awwo9/p+uzoJUAu8zDY63PFOq
         1Q8Vz0FuQSvKlGPB1hhMlJhn/TXd2zsvVkZk9WhAfi/TYJOGwhD5o0gDhWZfq3NY3nbz
         CnlTBrPCgjYmohk1ZZQYqpn7PLQTLIO9w+8R/f092NtTzbiQ5v+wCKZon6eMxodDYOJT
         erTniMz9s8AWH5T6XcX7b0pKsUI4o/rHGqg9fSRFxXnbtwSILq/ETiXCzvoS4YqEPzdl
         pmp7KMZ6kmY3iWsziSoXkxeZWdZRZLcWcoeVbdNnxxt1uM7I4VDU/aPL3P3lMfOlSi+m
         XShw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DrgK6T7p;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor1614678oix.78.2019.05.30.14.53.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 14:53:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DrgK6T7p;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=L4eRJoRAM9BshBnywrSkE8cQ8ajHKA/DqmlOsjnC6aU=;
        b=DrgK6T7pO2KGErcPsenn6+dgrK5pYhXn1+wL/FHloXypSYcxVhuuFIcgp3mZZdPpO7
         znr5fDthSEHXSBn0urZKNPauubicT85wwoRDbjY/XAvZjGgEnW83XCGc6KG4wGcUyoka
         eZjtLlLKozdey6w7A6Yqi3yO/XCFSfSm/GgmDHQ0UCDzCxLZmuLBnQ0n4ZLMcudRoT2s
         UTBBdTmwz5GhlW2PWNRhpo/aeKN/B+tN1xMSwAUrpsMPSdICbdawNhP1rTWjU4YW3AoQ
         ArhdHt1cN+GD4z0ZFxlnFnD/pTsYbCwEvJtp5kYdMQrSgLur3PRx3kmaw34F9amOAACA
         s+Dg==
X-Google-Smtp-Source: APXvYqxFvLQbXtfmzGSX+Ab6mYng9B7q/SFrUu2Vi2ikCBcKwjb0GT4lghL89v6z5fdD+2Y9eB47Og==
X-Received: by 2002:aca:c057:: with SMTP id q84mr4092001oif.135.1559253216673;
        Thu, 30 May 2019 14:53:36 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id a31sm1557360otc.60.2019.05.30.14.53.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 14:53:36 -0700 (PDT)
Subject: [RFC PATCH 00/11] mm / virtio: Provide support for paravirtual
 waste page treatment
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Thu, 30 May 2019 14:53:34 -0700
Message-ID: <20190530215223.13974.22445.stgit@localhost.localdomain>
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
for what I am referring to as "waste page treatment".

I have based many of the terms and functionality off of waste water
treatment, the idea for the similarity occured to me after I had reached
the point of referring to the hints as "bubbles", as the hints used the
same approach as the balloon functionality but would disappear if they
were touched, as a result I started to think of the virtio device as an
aerator. The general idea with all of this is that the guest should be
treating the unused pages so that when they end up heading "downstream"
to either another guest, or back at the host they will not need to be
written to swap.

So for a bit of background for the treatment process, it is based on a
sequencing batch reactor (SBR)[1]. The treatment process itself has five
stages. The first stage is the fill, with this we take the raw pages and
add them to the reactor. The second stage is react, in this stage we hand
the pages off to the Virtio Balloon driver to have hints attached to them
and for those hints to be sent to the hypervisor. The third stage is
settle, in this stage we are waiting for the hypervisor to process the
pages, and we should receive an interrupt when it is completed. The fourth
stage is to decant, or drain the reactor of pages. Finally we have the
idle stage which we will go into if the reference count for the reactor
gets down to 0 after a drain, or if a fill operation fails to obtain any
pages and the reference count has hit 0. Otherwise we return to the first
state and start the cycle over again.

This patch set is still far more intrusive then I would really like for
what it has to do. Currently I am splitting the nr_free_pages into two
values and having to add a pointer and an index to track where we area in
the treatment process for a given free_area. I'm also not sure I have
covered all possible corner cases where pages can get into the free_area
or move from one migratetype to another.

Also I am still leaving a number of things hard-coded such as limiting the
lowest order processed to PAGEBLOCK_ORDER, and have left it up to the
guest to determine what size of reactor it wants to allocate to process
the hints.

Another consideration I am still debating is if I really want to process
the aerator_cycle() function in interrupt context or if I should have it
running in a thread somewhere else.

[1]: https://en.wikipedia.org/wiki/Sequencing_batch_reactor

---

Alexander Duyck (11):
      mm: Move MAX_ORDER definition closer to pageblock_order
      mm: Adjust shuffle code to allow for future coalescing
      mm: Add support for Treated Buddy pages
      mm: Split nr_free into nr_free_raw and nr_free_treated
      mm: Propogate Treated bit when splitting
      mm: Add membrane to free area to use as divider between treated and raw pages
      mm: Add support for acquiring first free "raw" or "untreated" page in zone
      mm: Add support for creating memory aeration
      mm: Count isolated pages as "treated"
      virtio-balloon: Add support for aerating memory via bubble hinting
      mm: Add free page notification hook


 arch/x86/include/asm/page.h         |   11 +
 drivers/virtio/Kconfig              |    1 
 drivers/virtio/virtio_balloon.c     |   89 ++++++++++
 include/linux/gfp.h                 |   10 +
 include/linux/memory_aeration.h     |   54 ++++++
 include/linux/mmzone.h              |  100 +++++++++--
 include/linux/page-flags.h          |   32 +++
 include/linux/pageblock-flags.h     |    8 +
 include/uapi/linux/virtio_balloon.h |    1 
 mm/Kconfig                          |    5 +
 mm/Makefile                         |    1 
 mm/aeration.c                       |  324 +++++++++++++++++++++++++++++++++++
 mm/compaction.c                     |    4 
 mm/page_alloc.c                     |  220 ++++++++++++++++++++----
 mm/shuffle.c                        |   24 ---
 mm/shuffle.h                        |   35 ++++
 mm/vmstat.c                         |    5 -
 17 files changed, 838 insertions(+), 86 deletions(-)
 create mode 100644 include/linux/memory_aeration.h
 create mode 100644 mm/aeration.c

--

