Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6895C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:41:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 839622089E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:41:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NooVa7od"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 839622089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEB626B0008; Tue, 11 Jun 2019 10:41:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4D0D6B000A; Tue, 11 Jun 2019 10:41:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 878AF6B000C; Tue, 11 Jun 2019 10:41:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC996B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:41:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a5so7903356pla.3
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:41:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=o2J4Gd6aGMYycQc2Cgd8ykATa6/NVo6qP3SsoSO5AUQ=;
        b=bqCN4hZlTyPd/+kyZ8i+xcIToRtObQY0quBiwz3Bp2NmVYHkuad5sbpj36w9PQvS9d
         kI7Bmnq4nj02wducByih71qEQ0QRif0f43y9SUTwTmSCpBXmTrN3eniHZbp0EnEWWtm/
         p4KeXf3e2mtSgWk0oY05XQXzJOuePyPh9V2bAyEnFkTLRLpw5vIuwyxQRcZxkYLOZ6Uz
         SkAf33oqEHEYaJdfMUy0QLBqQCY7vtMqqr462ZavzvyWXfPpszJLuCoUXnPxbNIuECRd
         yd9xGHqLHKfnTV6TxwCKI9key2hxugNtiRBILaLEg1K4lUNdJmXT1AT8IZ4B4ja+9R6X
         mTUw==
X-Gm-Message-State: APjAAAXzTidpCnh2ixedg7CKNgWRSUMDcutYxaQZN+T5INo+vPt3vTy0
	EMK0KgvaAC26vkSlGvn/QbTTh/04j9EAJu6lcMoLaPdirX78Al92LQJzdR3n+6iqnuKn2+CA0a5
	FpjnOKZdC0WWttABZoOzBGWxOZfLvEhwAjuW96m7TGmzA50WF76thLMG9wL8wO50=
X-Received: by 2002:a65:4b88:: with SMTP id t8mr21226505pgq.374.1560264103813;
        Tue, 11 Jun 2019 07:41:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8W+1yB/6sK+qo2+hLo8Lm8Rr/LitTt6SOP7MB3pMoEitnBrX9ddL0uOL0QF8kuY6UjJFs
X-Received: by 2002:a65:4b88:: with SMTP id t8mr21226459pgq.374.1560264102995;
        Tue, 11 Jun 2019 07:41:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264102; cv=none;
        d=google.com; s=arc-20160816;
        b=JBww9NYwhV7udr4dcfWUYuWAEtLm7CKOn6cwDIY/w2AtmGCuKyEVszEJrK5F3Y/zcn
         K/BTmst31lg6b1XyJSyzZWY4ZK3DHomg6iSPoRZZK463sG+CKQYr5aJeGHbtTv09X5Gu
         2VZ7CzLyQ2/nvseNmu1MjfVq4c8GwkugVIMtPwOuzE4NImyU3Q+NNUo73zLTdbekjnXr
         13+K1SSh1JjCXiOYfktzWmrhnoPor7jVOY+ueGNttOt5jdNIDrYDpJakOO6eDDaO6V8g
         ADAsOMUKqzriYOTz2wOEUrcUqP8DrV1eSe1hE4SzBimsPlvApzb7iykUWO4wASAPh4n4
         2Jgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=o2J4Gd6aGMYycQc2Cgd8ykATa6/NVo6qP3SsoSO5AUQ=;
        b=mu8OfjcLXrfO+SI6uB9U7hBl4Vgi0wh+3F6egikRMuFJcyUd2j1V7kNvxws3r8/19x
         o1OMIXp46UQEbDy5Whmkwqmob8c8WAUruTC8LAhO+5TIwrzoXTZJdkbxr83Bb5tDohME
         sj3HetRYvssZ5u35lzwqlm/vdBkjLGJCwtcmk6DuuVyRl9XG7GmaXuRhY9D4UUtTteeB
         BuLtpZiIXy6M1YFc5F6u9+ZLN0wOJhZPpYKjsegNi6k7rWg7v4CNJbIwi1yKjU7nE2kv
         tQB7skmpU2LAOI4WDm0JsFBpBK7I4aFD9NTkXNI9PUzX2eIqPvTUcjJRy0LpqBUAtE2I
         pzGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NooVa7od;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k18si12891824pgh.244.2019.06.11.07.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 07:41:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NooVa7od;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=o2J4Gd6aGMYycQc2Cgd8ykATa6/NVo6qP3SsoSO5AUQ=; b=NooVa7odzLv7IOhiLuJXRzdAT
	9847NXr6KbmlQQbCdm/roXtU733/1c0TujxJALV/CRskCxkSZJxIjTuvYje4Hu2HIx2/18lsT2IkT
	V4S9ZLfKxOjzNiNdjE9YSFiOAuEFWncLCMqFlld9C8E0tZO1blw/UZUNEDSAKtGyMp1ujFWNiFfe7
	bemGU+fEPeBzJVI3EYWYyNcNlr9PPjI0kHfUCTEX9tUwAnnuaSJSqAOCWqlHSD1idi9GIdvUa4nKM
	oFIEUMzaP5Hxm/4DCKB8Fju5R0z5GUcY9hrj8tNMF/3Z6P45ZzjIK8YKFH6ozHQKYWGLVdntjkdeO
	jfIDBIm1w==;
Received: from mpp-cp1-natpool-1-037.ethz.ch ([82.130.71.37] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hahxS-0005NR-8l; Tue, 11 Jun 2019 14:41:06 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: switch the remaining architectures to use generic GUP v3
Date: Tue, 11 Jun 2019 16:40:46 +0200
Message-Id: <20190611144102.8848-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus and maintainers,

below is a series to switch mips, sh and sparc64 to use the generic
GUP code so that we only have one codebase to touch for further
improvements to this code.  I don't have hardware for any of these
architectures, and generally no clue about their page table
management, so handle with care.

Changes since v2:
 - rebase to mainline to pick up the untagged_addr definition
 - fix the gup range check to be start <= end to catch the 0 length case
 - use pfn based version for the missing pud_page/pgd_page definitions
 - fix a wrong check in the sparc64 version of pte_access_permitted

Changes since v1:
 - fix various issues found by the build bot
 - cherry pick and use the untagged_addr helper form Andrey
 - add various refactoring patches to share more code over architectures
 - move the powerpc hugepd code to mm/gup.c and sync it with the generic
   hup semantics

