Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 236DDC4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:59:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF318207FC
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:59:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=shipmail.org header.i=@shipmail.org header.b="XVUzl5dD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF318207FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shipmail.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CD8E6B02A8; Wed, 18 Sep 2019 08:59:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0847C6B02AA; Wed, 18 Sep 2019 08:59:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED55E6B02AB; Wed, 18 Sep 2019 08:59:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id AFD606B02A8
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 08:59:36 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 40D6F1A4C7
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:59:36 +0000 (UTC)
X-FDA: 75948047952.30.space31_53b59161c2e12
X-HE-Tag: space31_53b59161c2e12
X-Filterd-Recvd-Size: 5977
Received: from pio-pvt-msa3.bahnhof.se (pio-pvt-msa3.bahnhof.se [79.136.2.42])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:59:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTP id CAF1E3F869;
	Wed, 18 Sep 2019 14:59:28 +0200 (CEST)
Authentication-Results: pio-pvt-msa3.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=shipmail.org header.i=@shipmail.org header.b=XVUzl5dD;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa3.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa3.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tHoB48kMniVl; Wed, 18 Sep 2019 14:59:25 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTPA id 8C7A03F85E;
	Wed, 18 Sep 2019 14:59:24 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id E06C236020A;
	Wed, 18 Sep 2019 14:59:23 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=shipmail.org; s=mail;
	t=1568811564; bh=nHZ5nrGPkMFImxWZGWHwng2aQcVr1Cjrduddths8zV8=;
	h=From:To:Cc:Subject:Date:From;
	b=XVUzl5dDcqXwgp/9N8S33Dj/Zw+iZxamTyBGTvfwNYoDtCBZxacLKdPszdMZ82MTr
	 Zm5DSQSrR7Ma9rJip6E08bAy/6dQdW3WWRnNWh+mxC6yJUp0Eda44lBzFHJz9uED7k
	 TUVSxGL6qZs601VCYABY16qidqUwAvUhH/PRoGNA=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thomas_os@shipmail.org>
To: linux-kernel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org
Cc: pv-drivers@vmware.com,
	linux-graphics-maintainer@vmware.com,
	=?UTF-8?q?Thomas=20Hellstr=C3=B6m?= <thellstrom@vmware.com>,
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
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 0/7] Emulated coherent graphics memory take 2
Date: Wed, 18 Sep 2019 14:59:07 +0200
Message-Id: <20190918125914.38497-1-thomas_os@shipmail.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Thomas Hellstr=C3=B6m <thellstrom@vmware.com>

Graphics APIs like OpenGL 4.4 and Vulkan require the graphics driver
to provide coherent graphics memory, meaning that the GPU sees any
content written to the coherent memory on the next GPU operation that
touches that memory, and the CPU sees any content written by the GPU
to that memory immediately after any fence object trailing the GPU
operation has signaled.

Paravirtual drivers that otherwise require explicit synchronization
needs to do this by hooking up dirty tracking to pagefault handlers
and buffer object validation.

The mm patch page walk interface has been reworked to be similar to the
reworked page-walk code (mm/pagewalk.c). There have been two other soluti=
ons
to consider:
1) Using the page-walk code. That is currently not possible since it requ=
ires
the mmap-sem to be held for the struct vm_area_struct vm_flags and for hu=
ge
page splitting. The pagewalk code in this patchset can't hold the mmap se=
ms
since it will lead to locking inversion. We have an established locking o=
rder
mmap_sem -> dma_reservation -> i_mmap_lock, whereas holding the mmap_sem =
in
this case would require dma_reservation -> i_mmap_lock -> mmap_sem.
Instead it uses an operation mode similar to unmap_mapping_range() where =
the
i_mmap_lock is held.
2) Using apply_to_page_range(). The primary use of this code is to fill
page tables. The operation modes are IMO sufficiently different to motiva=
te
re-implementing the page-walk.

For the TTM changes they are hopefully in line with the long-term
strategy of making helpers out of what's left of TTM.

The code has been tested and exercised by a tailored version of mesa
where we disable all explicit synchronization and assume graphics memory
is coherent. The performance loss varies of course; a typical number is
around 5%.

I would like to merge this code through the DRM tree, so an ack to includ=
e
the new mm helpers in that merge would be greatly appreciated.

Changes since RFC:
- Merge conflict changes moved to the correct patch. Fixes intra-patchset
  compile errors.
- Be more aggressive when turning ttm vm code into helpers. This makes su=
re
  we can use a const qualifier on the vmwgfx vm_ops.
- Reinstate a lost comment an fix an error path that was broken when turn=
ing
  the ttm vm code into helpers.
- Remove explicit type-casts of struct vm_area_struct::vm_private_data
- Clarify the locking inversion that makes us not being able to use the m=
m
  pagewalk code.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
Cc: Christoph Hellwig <hch@infradead.org>

