Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D08E6C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:20:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95A8B21019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:20:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95A8B21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 274816B0008; Wed, 12 Jun 2019 11:20:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FD1F6B000A; Wed, 12 Jun 2019 11:20:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C5A06B000D; Wed, 12 Jun 2019 11:20:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC5F6B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:20:33 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id b13so2756079lfa.3
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:20:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Q6MqF1ts/5oNR9B4Krtu0dIyXDeKHMy63gxwTWHMzRY=;
        b=eS9QVooAFm+QtWTADo2/1cYHoN9rGoZX+eyIKFU6n1fqExzchSA6MS9FbfgC/NKaFE
         LtKumrU1i0BS3SXivUn5fdc0lIOyV8OYsPp+wkJuTMOdgNIxixeqZijzo5p8fb/KEgyJ
         EOSkUdiTkh4W7fz5ww5OPyLQpyiiMjMIcYH8E9FZV0J5xIURt9iI6KgNmSb6A6EIUJWG
         cP7z3o4VZIJyw3xBqmsctPIpLY3dXRaItZ3S69giv19A2bs9BXOVzExQJsKBrg8ukXla
         io7Ef2uSxEli0j/Psflp0Q0+m32RRdKcczLashlara20W0StiuX4//SMbYkQCwJ7LjHq
         22wA==
X-Gm-Message-State: APjAAAVXdePxyitoJ28A5FU02R4XUgAhO9u/FoPBTbgepKy2ZqITbVpF
	mQityMx6YmJjkePn/gng8JP8HYSf7XelmiGjpGsYzZ/Cq8epQbEnMN5nJV+BnpepGz/8AK1HOW9
	ZNldxaIuHjiMZzTR3cf9oFK3fivGXQogYz7/D1yC73D9ubvOOuzXOu1aWrcPCUeHnXw==
X-Received: by 2002:ac2:4ace:: with SMTP id m14mr2689013lfp.99.1560352832899;
        Wed, 12 Jun 2019 08:20:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDyKmUS0aSWEMbaAo/MWg8llsvNZDHXvSl51T4jo1fjm4BHP2tF5TlCc1wbLvaN2Xecu4R
X-Received: by 2002:ac2:4ace:: with SMTP id m14mr2688966lfp.99.1560352831765;
        Wed, 12 Jun 2019 08:20:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560352831; cv=none;
        d=google.com; s=arc-20160816;
        b=fUQbR1SyThUiXJIM5ZEY/WzC7tt0wEjST9MhTb7ozBH2oxhXbWtcsn5J6AawwCFuev
         tjOF11SMNzngj4ZNfs3izQlY6qR6H1m29vs+CXQsKggDef1+dJ2y5uGGgVkDNeO9/0/B
         NTIdLgUqvekIy7suejHUshpVI/P2tro8tx3sCkVH5Zd2h9VmTD+hGWQWhz3fIVpzswIH
         sfdCzTw+v7hDqxfYAFLLaToMlYmUGdliIOZgBMoYRlNhztJGAEkCqRSYGU6uA9io5KEc
         pL6RbAeZgQELr7pWfFh6kF0h503ZJ0KYXRaKnUpAoZU/txokr9s6VfRmkcJyKxp9B/nz
         VKWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Q6MqF1ts/5oNR9B4Krtu0dIyXDeKHMy63gxwTWHMzRY=;
        b=en0PrIxmzele43GijUjRc7YYhxPjX8MbpMUbqMaHITNzYH4t2Y55argnyhgTY/pPI2
         tbmsdJ9DV423FW6RAN/xoeYJMOewEfAcBph515JGET4YNL9KldHB8JCdFUcw4iCY/PIH
         n0jdWQFWz7McWkokeaRfoujBbovlmCOSQQqGPSy2xrUFn81xr8zta3wZ1z+PGURFgBFP
         x3LT1zwSicimWrO6fJiaYRnZFx4f5MCRIf/mo1ReyIih7Ykot5hyvPOxx3ZNZcRFx2G0
         nhns36tEG/TOLIYM4z1La6SB/p2H6OVTVBHyL1qYrUOUqRbEtNoG5qPoR+jn/n6BvKPb
         oUiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=yhEIAnyl;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se (ste-pvt-msa2.bahnhof.se. [213.80.101.71])
        by mx.google.com with ESMTPS id h5si18271701ljk.108.2019.06.12.08.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 08:20:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) client-ip=213.80.101.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=yhEIAnyl;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTP id 080E73FFD7;
	Wed, 12 Jun 2019 17:20:26 +0200 (CEST)
Authentication-Results: ste-pvt-msa2.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=yhEIAnyl;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Authentication-Results: ste-ftg-msa2.bahnhof.se (amavisd-new);
	dkim=pass (1024-bit key) header.d=vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se ([127.0.0.1])
	by localhost (ste-ftg-msa2.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id w-DfZwpwH_gn; Wed, 12 Jun 2019 17:20:11 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTPA id E0D1C3FFCB;
	Wed, 12 Jun 2019 17:20:09 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 40B773619A3;
	Wed, 12 Jun 2019 17:20:09 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560352809;
	bh=pGEJYdtLLWrJMrg31kW9zdSgU0dUJ0reBVE+9VgZv4k=;
	h=From:To:Cc:Subject:Date:From;
	b=yhEIAnylogNBfOeQi28R3TPU+54yU+KzrqncZ4dKWRwtzqT3vcepmyK9JPg59dNNq
	 TklWWzrc9GdJZgU8rWqqSwNXO9qfyJoRzo1p/qiOJrk5zM1xNwxnWA7En2+vgYylNS
	 4D6JVBxC7b/4AnVvTe+a/3cnFP6yituWBR3ITlcI=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thellstrom@vmwopensource.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org,
	hch@infradead.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	linux-mm@kvack.org
Subject: [PATCH v6 0/9] Emulated coherent graphics memory
Date: Wed, 12 Jun 2019 17:19:41 +0200
Message-Id: <20190612151950.2870-1-thellstrom@vmwopensource.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Planning to merge this through the drm/vmwgfx tree soon, so if there
are any objections, please speak up.

Graphics APIs like OpenGL 4.4 and Vulkan require the graphics driver
to provide coherent graphics memory, meaning that the GPU sees any
content written to the coherent memory on the next GPU operation that
touches that memory, and the CPU sees any content written by the GPU
to that memory immediately after any fence object trailing the GPU
operation has signaled.

Paravirtual drivers that otherwise require explicit synchronization
needs to do this by hooking up dirty tracking to pagefault handlers
and buffer object validation. This is a first attempt to do that for
the vmwgfx driver.

The mm patches has been out for RFC. I think I have addressed all the
feedback I got, except a possible softdirty breakage. But although the
dirty-tracking and softdirty may write-protect PTEs both care about,
that shouldn't really cause any operation interference. In particular
since we use the hardware dirty PTE bits and softdirty uses other PTE bits.

For the TTM changes they are hopefully in line with the long-term
strategy of making helpers out of what's left of TTM.

The code has been tested and exercised by a tailored version of mesa
where we disable all explicit synchronization and assume graphics memory
is coherent. The performance loss varies of course; a typical number is
around 5%.

Changes v1-v2:
- Addressed a number of typos and formatting issues.
- Added a usage warning for apply_to_pfn_range() and apply_to_page_range()
- Re-evaluated the decision to use apply_to_pfn_range() rather than
  modifying the pagewalk.c. It still looks like generically handling the
  transparent huge page cases requires the mmap_sem to be held at least
  in read mode, so sticking with apply_to_pfn_range() for now.
- The TTM page-fault helper vma copy argument was scratched in favour of
  a pageprot_t argument.
Changes v3:
- Adapted to upstream API changes.
Changes v4:
- Adapted to upstream mmu_notifier changes. (Jerome?)
- Fixed a couple of warnings on 32-bit x86
- Fixed image offset computation on multisample images.
Changes v5:
- Updated usage warning in patch 3/9 after review comments from Nadav Amit.
Changes v6:
- Updated exports of new functionality in patch 3/9 to EXPORT_SYMBOL_GPL
  after review comments from Christoph Hellwig.
  
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: "Christian König" <christian.koenig@amd.com>
Cc: linux-mm@kvack.org

