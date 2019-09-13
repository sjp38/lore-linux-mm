Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 238A3C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:32:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB17620644
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:32:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=shipmail.org header.i=@shipmail.org header.b="C8h0pnZj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB17620644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shipmail.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE0E26B000D; Fri, 13 Sep 2019 05:32:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E90EE6B000E; Fri, 13 Sep 2019 05:32:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D585E6B0010; Fri, 13 Sep 2019 05:32:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id B350E6B000D
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 05:32:46 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 63EE4181AC9B4
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:32:46 +0000 (UTC)
X-FDA: 75929382732.28.1A9C751
Received: from filter.hostedemail.com (10.5.16.251.rfc1918.com [10.5.16.251])
	by smtpin28.hostedemail.com (Postfix) with ESMTP id 851261F208
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:32:39 +0000 (UTC)
X-HE-Tag: deer52_171f9a0fd8a56
X-Filterd-Recvd-Size: 5375
Received: from ste-pvt-msa2.bahnhof.se (ste-pvt-msa2.bahnhof.se [213.80.101.71])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:32:38 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTP id 5AEFD3F478;
	Fri, 13 Sep 2019 11:32:32 +0200 (CEST)
Authentication-Results: ste-pvt-msa2.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=shipmail.org header.i=@shipmail.org header.b=C8h0pnZj;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Authentication-Results: ste-ftg-msa2.bahnhof.se (amavisd-new);
	dkim=pass (1024-bit key) header.d=shipmail.org
Received: from ste-pvt-msa2.bahnhof.se ([127.0.0.1])
	by localhost (ste-ftg-msa2.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nb4XqZG-u2Zu; Fri, 13 Sep 2019 11:32:29 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTPA id CE2853F218;
	Fri, 13 Sep 2019 11:32:27 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 2575F360195;
	Fri, 13 Sep 2019 11:32:27 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=shipmail.org; s=mail;
	t=1568367147; bh=AQOLmDnO0mrHB5UncaWVaavZGiTO0sudlEHqCbG4rDA=;
	h=From:To:Cc:Subject:Date:From;
	b=C8h0pnZjwksWBXQoCo18ZijBLNk8D0f0Btz9y5wKAmpYbCXTs9Hdg+Mt2tcALu75Q
	 UHEGnYN+ejDSaj5QWqVNjZGWgQd292g7P9bnVA5WOg7vklzJWwqc+S+zlsSYb6xSn0
	 2ijI86K8GufVXmKpETRWNRblr6BRqN2tijJGauJU=
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
Subject: [RFC PATCH 0/7] Emulated coherent graphics memory take 2
Date: Fri, 13 Sep 2019 11:32:06 +0200
Message-Id: <20190913093213.27254-1-thomas_os@shipmail.org>
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
since it will lead to locking inversion. Instead it uses an operation mod=
e
similar to unmap_mapping_range where the i_mmap_lock is held.
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

I would like to merge this code through the DRM tree, so an ack to do tha=
t
from an mm maintainer would be greatly appreciated.

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

