Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22077C04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB155206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bsnsYjO2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB155206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89CB36B0006; Tue,  7 May 2019 00:06:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84D316B0007; Tue,  7 May 2019 00:06:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 627EA6B000A; Tue,  7 May 2019 00:06:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4D06B0006
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:13 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o8so9452293pgq.5
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=L71+yke0jcNUvSrjkUhr8nSUGqUb15lbMNsnDsCyRJ8=;
        b=tvNFrEdm8BFckI1rt4D4esSZyjwZaLxwa9csyx3rZ5D2pKdj9UsaQqYRogDgM6PFuV
         9zTSWVuFbqPazBGP+P+mjF1PDRYifAjmQ8jbhyMn+OQB12RymrB2L/ghA/leAig41yK4
         1FGreLe2ttM+dUHoi/LjoMJ431Gn3u4YZmMtB2lbFkMDjkHt2qnrw1i4gt/fQgMRC8m1
         9BGBq5K6rjXYbF+BC+5jLgMbfHCR74EXJxZM8p2foGdiKSEZ0m2zl5M0j0GITwHhd6VS
         OfA65u49EGgjzw+N0aG9f9mRIJUyNn+EnAgsQNnR3rYr9Li9zSIEQBVDct3jooiihBQ2
         3IpQ==
X-Gm-Message-State: APjAAAWdMi0kOogUiLMbm6nNR/wvIBK2a2Zfu2ht775VMhWM6zbzivBP
	n8GyIKSpHNg7PbH43V49QMaVbD0Wxr6I+hu+N851gxdkq30O/N1ylkohEngzLILcZ5ZRyOdEpyH
	yklX7LDUxIPL6n86lJkseseic9I1Zvw3akIfMZmsnoxaL49NHsjmfZsfMLiTwBKuGRw==
X-Received: by 2002:a63:4c06:: with SMTP id z6mr27335991pga.296.1557201972660;
        Mon, 06 May 2019 21:06:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPbH8ZNJ8ykPHspyiz7Dk+GdQlgi6/W/YtLYhANjkK7oOnU7Z9E2JkooCKjuzQvuFHD2Ct
X-Received: by 2002:a63:4c06:: with SMTP id z6mr27335918pga.296.1557201971713;
        Mon, 06 May 2019 21:06:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201971; cv=none;
        d=google.com; s=arc-20160816;
        b=GOzmozpRS1CQX9wLfQTGgbvv3tySH6mp59lqGnQECUgs/NgM8uDkDMXYtRIKU0FnKf
         Uk11Se9SR23Rti+YA6F9lDMfazLTup6Xa3XK4uGM8TZZwJw87Ra8+ydJfWXKw0Ck+wQL
         zzo4t4BOQ+cV9Kw0NjI+AdZ3N90oIQ310Hq7tEpvvILG8AinkNEJ03QFDNsJgdIwGWYq
         nu6wUKsjmlbvECi4vJi98b4igvYWdBktVRRUpJofP2sn9n57V2AwnpWswCxjR4DfEIcm
         tmM5KqmYvE8adBuyQ4Vwxwp6Oi1VHjMBZm+S6XdiIiu+9cCaykmt6rbsb45SO0u8TsUd
         ocrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=L71+yke0jcNUvSrjkUhr8nSUGqUb15lbMNsnDsCyRJ8=;
        b=fb+UINrU/qTRyA7uyQloEDN6CX6gq3cuP7M80grXLMVnLbMudYybN1j2+E79PBusl8
         IEdoPrXZwsTAiuuqSySwwhTOToNu8XbqylrGcDRCB4eTIPHA3waspDzvf1mxfPoAjhOg
         TTupxe1hzEjtJNGtWlIc4v9PsBw0sb1a4Wm3v4K44McUywDp3N1nLBtyLAuHLGXA2hZi
         mNcNBhHNQrvV9o9ACkH8skkJ8pPrNnq4WAzLUyTNQkdszHmVn8U3LqnjXpIca4Q73tta
         MyTtNcqIX8FAlhjANoTzLg59duUyJMwtBzHa2q0BFZ7BuSHxIIZgWQjkQsCdtOmSEpXQ
         1vvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bsnsYjO2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p8si17633681plq.225.2019.05.06.21.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bsnsYjO2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Message-Id:Date:Subject:Cc:To:From:
	Sender:Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=L71+yke0jcNUvSrjkUhr8nSUGqUb15lbMNsnDsCyRJ8=; b=bsnsYjO2OwhjxCYJeeBxmLMyp
	mm91ib7XkqcX+iiKbCUHE1eD0ejO8quLJ4rEp+MTIFStwkP9ZgYFUzhx3HqQaDzufAt3q8sqOpJsd
	QhMhS1qtShCkzxEsT6ueZeu3D3FtA/8QQ1Nk/vuXVaJVx+6HqP5f7wYvSH9OAfRoBy06ISzLX+wm6
	roOxW8wY3XXPFenWpPj85AhsoXuhqAGO2y4Zo8rcx6LS95XO9YCRq0BmaIWcyTMqHcsv0JjdOFXel
	iLBb5SW02TAJbgnSa5a95NjT7C2S73fIs5mT8+nWBCz2IKY6ETAJCwJB/+4ZzHBIYG5XdB35zSZNX
	c7310hdEA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMp-0005ha-0G; Tue, 07 May 2019 04:06:11 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [RFC 00/11] Remove 'order' argument from many mm functions
Date: Mon,  6 May 2019 21:05:58 -0700
Message-Id: <20190507040609.21746-1-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

It's possible to save a few hundred bytes from the kernel text by moving
the 'order' argument into the GFP flags.  I had the idea while I was
playing with THP pagecache (notably, I didn't want to add an 'order'
parameter to pagecache_get_page())

What I got for a -tiny config for page_alloc.o (with a tinyconfig,
x86-32) after each step:

   text	   data	    bss	    dec	    hex	filename
  21462	    349	     44	  21855	   555f	1.o
  21447	    349	     44	  21840	   5550	2.o
  21415	    349	     44	  21808	   5530	3.o
  21399	    349	     44	  21792	   5520	4.o
  21399	    349	     44	  21792	   5520	5.o
  21367	    349	     44	  21760	   5500	6.o
  21303	    349	     44	  21696	   54c0	7.o
  21303	    349	     44	  21696	   54c0	8.o
  21303	    349	     44	  21696	   54c0	9.o
  21303	    349	     44	  21696	   54c0	A.o
  21303	    349	     44	  21696	   54c0	B.o

I assure you that the callers all shrink as well.  vmscan.o also
shrinks, but I didn't keep detailed records.

Anyway, this is just a quick POC due to me being on an aeroplane for
most of today.  Maybe we don't want to spend five GFP bits on this.
Some bits of this could be pulled out and applied even if we don't want
to go for the main objective.  eg rmqueue_pcplist() doesn't use its
gfp_flags argument.

Matthew Wilcox (Oracle) (11):
  fix function alignment
  mm: Pass order to __alloc_pages_nodemask in GFP flags
  mm: Pass order to __get_free_pages() in GFP flags
  mm: Pass order to prep_new_page in GFP flags
  mm: Remove gfp_flags argument from rmqueue_pcplist
  mm: Pass order to rmqueue in GFP flags
  mm: Pass order to get_page_from_freelist in GFP flags
  mm: Pass order to __alloc_pages_cpuset_fallback in GFP flags
  mm: Pass order to prepare_alloc_pages in GFP flags
  mm: Pass order to try_to_free_pages in GFP flags
  mm: Pass order to node_reclaim() in GFP flags

 arch/x86/Makefile_32.cpu      |  2 +
 arch/x86/events/intel/ds.c    |  4 +-
 arch/x86/kvm/vmx/vmx.c        |  4 +-
 arch/x86/mm/init.c            |  3 +-
 arch/x86/mm/pgtable.c         |  7 +--
 drivers/base/devres.c         |  2 +-
 include/linux/gfp.h           | 57 +++++++++++---------
 include/linux/migrate.h       |  2 +-
 include/linux/swap.h          |  2 +-
 include/trace/events/vmscan.h | 28 +++++-----
 mm/filemap.c                  |  2 +-
 mm/gup.c                      |  4 +-
 mm/hugetlb.c                  |  5 +-
 mm/internal.h                 |  5 +-
 mm/khugepaged.c               |  2 +-
 mm/mempolicy.c                | 30 +++++------
 mm/migrate.c                  |  2 +-
 mm/mmu_gather.c               |  2 +-
 mm/page_alloc.c               | 97 +++++++++++++++++------------------
 mm/shmem.c                    |  5 +-
 mm/slub.c                     |  2 +-
 mm/vmscan.c                   | 26 +++++-----
 22 files changed, 147 insertions(+), 146 deletions(-)

-- 
2.20.1

