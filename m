Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49F35C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 01:50:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E44FA20880
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 01:50:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J3n5ZKeo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E44FA20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D1306B0003; Sun, 11 Aug 2019 21:50:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57FCB6B0005; Sun, 11 Aug 2019 21:50:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 421706B0006; Sun, 11 Aug 2019 21:50:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0158.hostedemail.com [216.40.44.158])
	by kanga.kvack.org (Postfix) with ESMTP id 193126B0003
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 21:50:58 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id AC3B28248AA1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 01:50:57 +0000 (UTC)
X-FDA: 75812097354.19.desk36_5fa4b8e71a253
X-HE-Tag: desk36_5fa4b8e71a253
X-Filterd-Recvd-Size: 4485
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 01:50:57 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id 196so1762485pfz.8
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 18:50:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=pfaVFzFF0GvUkP+csExf9mRMYKLakGIqocXWtOijWcs=;
        b=J3n5ZKeoQQ0bmNJgluv6gAytDIfBo9heugCs0XBMhVCrev0LMMnqqYvHMPS/Cr0eBt
         gctxUlCPGnoXwjK2CwzgVvi28Wb22MRLlEhA2lKWros6W4HEdEFgJOn/NBCaUfYs2Th8
         uPiE4ZxUz27VerKWtltJreVV1o5cNvwgiQmm2L4fmmkncjkGTaspegF0sY5rCwFaz1Bj
         NmwHks4rnhNi7uAo/lBpxeuM3ZbiuZQc8DkW7I1xNK4QRa1pZCMUjYzqmjrptEEwb9Fi
         DfhQnMHmRrF6nz3dpmgznKvjSD+eNOrb0yEq+WeDxCYjBjqUNCYLFdD0M1uwwALX4eRZ
         OSMA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=pfaVFzFF0GvUkP+csExf9mRMYKLakGIqocXWtOijWcs=;
        b=PVSC+VSU3ehxHr5j+PqXTUSyDbkfxHxUlYf81kVXl7dmUWtYWWlaVqip9U1QCWaSRk
         3KrGzhjnRB871AkJgha/Ei91tC6QhQRLJtUBPrN/xSjqyxZXTpaqpGjAkuhvTvm+Edcb
         CoM6xRag6RNegHgLtfnIa0Q+agQjKAkCCOASY1xzLHZNkipEk6aS9xhljL5L5X55Q6xJ
         Od019rGzffvwPSCHaK2KWm0E+9EWJxf0H6ymOHd/lJpXCTxttDuJLRxdUiKKjLkTRbMq
         dmeVzU1qEFs8itHPYosUxadG8jHeMnSm+DkDvzrdpB5KQPFqSPI1mx+4OKgcXnrp3bfg
         7sZQ==
X-Gm-Message-State: APjAAAX2GZiOyjZy15joAiI9i6kF1SgXvPsXP/EOvqEkmnhrYrBWniQX
	6iBTldJzWhp/RcFQnuAQ5go=
X-Google-Smtp-Source: APXvYqwiGohojGGhDnygsE9A4cyzbEHPkz9fH4ggMXoJfzmaJzcdAgT3McHJiakV36cLDMyvSwP/zg==
X-Received: by 2002:a65:44cc:: with SMTP id g12mr27761338pgs.409.1565574656022;
        Sun, 11 Aug 2019 18:50:56 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id j20sm100062363pfr.113.2019.08.11.18.50.55
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 11 Aug 2019 18:50:55 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [RFC PATCH 0/2] mm/gup: introduce vaddr_pin_pages_remote(), FOLL_PIN
Date: Sun, 11 Aug 2019 18:50:42 -0700
Message-Id: <20190812015044.26176-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Hi,

Dave Chinner's head didn't seem to explode...much, when he saw Ira's
series, so I optimistically started taking it from there...this builds on
top of Ira's patchset that he just sent out:

  "[RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002   ;-)" [=
1]

...which in turn is based on the latest -mmotm.

If Ira's series and this one are both acceptable, then

    a) I'll rework the 41-patch "put_user_pages(): miscellaneous call
       sites" series, and

    b) note that this will take rather longer and will be quite a bit mor=
e
       intrusive for each call site (but it's worth it), due to the
       need to plumb the owning struct file* all the way down to the gup(=
)
       call. whew.

[1] https://lore.kernel.org/r/20190809225833.6657-1-ira.weiny@intel.com

[2] https://lore.kernel.org/r/20190807013340.9706-1-jhubbard@nvidia.com

John Hubbard (2):
  mm/gup: introduce FOLL_PIN flag for get_user_pages()
  mm/gup: introduce vaddr_pin_pages_remote()

 drivers/infiniband/core/umem_odp.c | 15 ++++----
 include/linux/mm.h                 |  8 +++++
 mm/gup.c                           | 55 +++++++++++++++++++++++++++++-
 3 files changed, 71 insertions(+), 7 deletions(-)

--=20
2.22.0


