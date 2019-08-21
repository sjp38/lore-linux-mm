Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A00CC3A5A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 04:04:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E226822CF7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 04:04:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ejyl/X8L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E226822CF7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93C546B0287; Wed, 21 Aug 2019 00:04:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DA1C6B028B; Wed, 21 Aug 2019 00:04:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C27F6B0289; Wed, 21 Aug 2019 00:04:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id 29EDF6B0288
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:04:02 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 71270877A
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 04:04:01 +0000 (UTC)
X-FDA: 75845091882.08.dock18_22c481df94d2d
X-HE-Tag: dock18_22c481df94d2d
X-Filterd-Recvd-Size: 3979
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com [216.228.121.143])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 04:03:58 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5cc2ad0002>; Tue, 20 Aug 2019 21:03:57 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 20 Aug 2019 21:03:57 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 20 Aug 2019 21:03:57 -0700
Received: from HQMAIL101.nvidia.com (172.20.187.10) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 21 Aug
 2019 04:03:57 +0000
Received: from hqnvemgw02.nvidia.com (172.16.227.111) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 21 Aug 2019 04:03:57 +0000
Received: from blueforge.nvidia.com (Not Verified[10.110.48.28]) by hqnvemgw02.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d5cc2ac0001>; Tue, 20 Aug 2019 21:03:56 -0700
From: John Hubbard <jhubbard@nvidia.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ira Weiny
	<ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 2/4] For Ira: tiny formatting tweak to kerneldoc
Date: Tue, 20 Aug 2019 21:03:53 -0700
Message-ID: <20190821040355.19566-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190821040355.19566-1-jhubbard@nvidia.com>
References: <20190821040355.19566-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566360237; bh=N6ccyzf5PMKW+koaJVWa/WJ5yd4Gtcd+1v71ttVDCNg=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Transfer-Encoding:Content-Type;
	b=ejyl/X8LGp01d3V/HJlJwY+MWLCCvGZ39TTEg9R9pYbOpOmFI0ccB+jQnpnh9VgIH
	 dhWOd9LD5FqATRk2iyAHYsquSGNX0Xo2wNigIAsNVWdBCRelcHUQQsxpIQxXl0Rs3j
	 aJKpdDavlZNbpn9cPq29Qnxefgfefjf45gDj4mhxS9r1YIpIiIiRhBbZyOALotnhL/
	 zCqK+dG9WRz+1OGythS2WTZ2NiWsRhGnj9KI4bY1dIRXHMU9RMxxX2OYaE9obDVejW
	 OYakeTAaS4XHjrpRPDWfyhbjQJ5nbOyzY6cO75mhq/xJwCHEtDrt8CK+tNaRkhsIpa
	 pEMwZF6ZD4oTQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For your vaddr_pin_pages() and vaddr_unpin_pages().
Just merge it into wherever it goes please. Didn't want to
cause merge problems so it's a separate patch-let.

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/gup.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 56421b880325..e49096d012ea 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2465,7 +2465,7 @@ int get_user_pages_fast(unsigned long start, int nr_p=
ages,
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
=20
 /**
- * vaddr_pin_pages pin pages by virtual address and return the pages to th=
e
+ * vaddr_pin_pages() - pin pages by virtual address and return the pages t=
o the
  * user.
  *
  * @addr: start address
@@ -2505,7 +2505,7 @@ long vaddr_pin_pages(unsigned long addr, unsigned lon=
g nr_pages,
 EXPORT_SYMBOL(vaddr_pin_pages);
=20
 /**
- * vaddr_unpin_pages - counterpart to vaddr_pin_pages
+ * vaddr_unpin_pages() - counterpart to vaddr_pin_pages
  *
  * @pages: array of pages returned
  * @nr_pages: number of pages in pages
--=20
2.22.1


