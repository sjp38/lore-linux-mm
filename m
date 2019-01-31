Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E12E1C282D8
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 02:04:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9811E20B1F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 02:04:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ptO0kRn4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9811E20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 160DD8E0003; Wed, 30 Jan 2019 21:04:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10E858E0001; Wed, 30 Jan 2019 21:04:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3F318E0003; Wed, 30 Jan 2019 21:04:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD11E8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 21:04:49 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id d3so1060404pgv.23
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 18:04:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject:in-reply-to:references
         :message-id;
        bh=9u+YV5IcvYsQJ8cY1MX2zpgFq03ogjt0USJCUCHFOBI=;
        b=PrfJWS3J2QLJ4g5U/LmMtkFWyB6vd8XV6yh73JK3XyVi7yikcuCuWglt7wRQfAGvnw
         D0IjKBjlOpFdx23PvBbihQABvNAkVjIn79HojeQNl5fgMgoDW3oSWHcbcBWQ6x1jWWqB
         yxPWDmRTenLnfd3AU/KKZ9U3RstZhj5tzbI+OtXHCKUwtpyNFRcXv6yvhrZSBQm9pZNT
         VSt2GynOjl1K+nlHBpW3UNPuzRToK79e1YVJ5fHN0yMN8qaThOaHpAyjuw7lRBZCFbaB
         xZ4RDopJg0CVQuF9m6V25tRckxEKEngZGQaDlo0Aieg9dxvspKhqyAxumV6V7+YKNGd+
         qBVw==
X-Gm-Message-State: AJcUukd2r3o0Jmgg0ZmIxUhXdYHv7nzUg7MhI/GOyfPidZ/K9vQdZsAb
	WwpvEooouk4yLXpr6+v/hAHqtMp+AB+SMBciTkQqFlAQWhZIGAI+VEJmu+ImHq4F/LJf/qDdUlN
	iVrpJsm8YvES2I58MUNnkYvaEpDnMOxqhbznfSCkOoeCSbZTJsR7vnx5wsdOoOkuu0w==
X-Received: by 2002:a63:1013:: with SMTP id f19mr29983137pgl.38.1548900289349;
        Wed, 30 Jan 2019 18:04:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5xaw6IOCooAVd32WgPU+1KJaVIYB3AjsS14wI+W2zPJbOTU22RT74FeqkL16AI+h1TdLC4
X-Received: by 2002:a63:1013:: with SMTP id f19mr29983102pgl.38.1548900288593;
        Wed, 30 Jan 2019 18:04:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548900288; cv=none;
        d=google.com; s=arc-20160816;
        b=WDueG+Uu2rHHyT9VJcxZh+lzp540f/RewjWZTz9ftqW0ytOML9LRmTw+ChquXiinqP
         WBDP970FiJyeuxKPj/bZowjpTr7eudec9zhsDph1BLVG7S1LV1wd/vYpyy9QNNyNLbi/
         A5mUwORrp0bG2GtrzGwezR82g4Rb3vcruO9HsjjuvWlvZLqGeLMn6DTY2p7bo/p/bq+f
         QFw0X8VuKuHrobCuErDCCqT/yYw6JR7Gt/nER1WVQJR1skqfubFqyXlVJX4C5x5ORc7B
         H4fReVc0SgwwuPp7ymN7m9tE6T74z1c1MkuoXT2xZggQ882l3JAnEsj4T97o6WqFyHpz
         npBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:cc:to:to:to:from:date:dkim-signature;
        bh=9u+YV5IcvYsQJ8cY1MX2zpgFq03ogjt0USJCUCHFOBI=;
        b=EuzK9Hm4ekXAFtKiCR6ZaCAacMPfaJXqYDASfcphMfFSDvX314Y53jMqQAGjkxQVX2
         EHRrWHbpP4gWYn2V9J3BUy5gfAHB9bREESFFP4g73HAhphoHD34XVKf5s4Gk57kMIEWV
         U6oGwbQPQ3OSciRxDOPXLLsX05fFT0J7k7dottbCBgRpnc+ROrXG3iCKjklYEBEHTxEw
         dVAJ2SIFDAC7eEJ+RXicvUM/U7NM2LCtDFUzPTSKfLq0xKTqyORHP2WV8fCnOixakxet
         lkbCKjvp0/hQ8bbtmnsLgMGkj6yum6KPiUkRi7s8hjVnWXUgETTIKS11kH2iPCC7zNPd
         QhEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ptO0kRn4;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h188si3136670pfg.44.2019.01.30.18.04.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 18:04:48 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ptO0kRn4;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 072FE218AF;
	Thu, 31 Jan 2019 02:04:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548900288;
	bh=RT5d2QR9t1oI07s93gTOqf0QDHmAo2ReSrHMvjAvtak=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:
	 Subject:In-Reply-To:References:From;
	b=ptO0kRn4+7b+qtIowhlJg3MEWqi6xCUm0ZO/zRsXbmlm3PwkWAEo5TAoYNNPeFRvp
	 lbdt8dgTXdorFAXm0xPVCHiHb1h5KhZh/sygVjl4FH/9guA0emFIhj/iDFzccT68ah
	 rKfSIcA9GoGLiTaoKkcrKYXOxu7pbNCov3KYfOz4=
Date: Thu, 31 Jan 2019 02:04:47 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   David Hildenbrand <david@redhat.com>
To:     linux-mm@kvack.org
Cc:     linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Vratislav Bendel <vbendel@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH v2] mm: migrate: don't rely on __PageMovable() of newpage after unlocking it
In-Reply-To: <20190129233217.10747-1-david@redhat.com>
References: <20190129233217.10747-1-david@redhat.com>
Message-Id: <20190131020448.072FE218AF@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: d6d86c0a7f8d mm/balloon_compaction: redesign ballooned pages management.

The bot has tested the following trees: v4.20.5, v4.19.18, v4.14.96, v4.9.153, v4.4.172, v3.18.133.

v4.20.5: Build OK!
v4.19.18: Build OK!
v4.14.96: Build OK!
v4.9.153: Build OK!
v4.4.172: Failed to apply! Possible dependencies:
    1031bc589228 ("lib/vsprintf: add %*pg format specifier")
    14e0a214d62d ("tools, perf: make gfp_compact_table up to date")
    1f7866b4aebd ("mm, tracing: make show_gfp_flags() up to date")
    420adbe9fc1a ("mm, tracing: unify mm flags handling in tracepoints and printk")
    53f9263baba6 ("mm: rework mapcount accounting to enable 4k mapping of THPs")
    7cd12b4abfd2 ("mm, page_owner: track and print last migrate reason")
    7d2eba0557c1 ("mm: add tracepoint for scanning pages")
    c6c919eb90e0 ("mm: use put_page() to free page instead of putback_lru_page()")
    d435edca9288 ("mm, page_owner: copy page owner info during migration")
    d8c1bdeb5d6b ("page-flags: trivial cleanup for PageTrans* helpers")
    eca56ff906bd ("mm, shmem: add internal shmem resident memory accounting")
    edf14cdbf9a0 ("mm, printk: introduce new format string for flags")

v3.18.133: Failed to apply! Possible dependencies:
    2847cf95c68f ("mm/debug-pagealloc: cleanup page guard code")
    48c96a368579 ("mm/page_owner: keep track of page owners")
    7cd12b4abfd2 ("mm, page_owner: track and print last migrate reason")
    94f759d62b2c ("mm/page_owner.c: remove unnecessary stack_trace field")
    c6c919eb90e0 ("mm: use put_page() to free page instead of putback_lru_page()")
    d435edca9288 ("mm, page_owner: copy page owner info during migration")
    e2cfc91120fa ("mm/page_owner: set correct gfp_mask on page_owner")
    e30825f1869a ("mm/debug-pagealloc: prepare boottime configurable on/off")
    eefa864b701d ("mm/page_ext: resurrect struct page extending code for debugging")


How should we proceed with this patch?

--
Thanks,
Sasha

