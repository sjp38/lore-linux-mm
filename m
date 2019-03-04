Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75623C10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:46:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16EC020823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:46:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sQWEo9K1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16EC020823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 750F18E0003; Mon,  4 Mar 2019 14:46:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 700B28E0001; Mon,  4 Mar 2019 14:46:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C92D8E0003; Mon,  4 Mar 2019 14:46:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B45A8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 14:46:53 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id y1so5899838pgo.0
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 11:46:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Xmz5CLW0FSy25OQrcpPjEI+jhUMsvf19y6/jwFDBJlQ=;
        b=jPrZrGZW4LPdu+UsSaIPfJYc5Euu6yHmCxdh7IYg4hGAMyK1D96B9lCMoLeSnUh0E1
         KXgWkh2SE1z9BsBKnLvBI+MTtdHYq+kJsjp6/tP/cZVzh5FSV/hyCJ7C2egoqvr+DzPq
         ItznU8NPY4Wr45J/E69EMxaQ8dLak/B3QPAVUG49u2vdOftX8Abh62EecaIKgtGyT7xo
         c3bpyG0d7a6PIIgfc1iWkjKaLFC3v0pcyyIpSQdymYXNnPkiHIBqrfrEdFJegSM75VsY
         00QqC8KWoDN4NI3LHft4ls3I2jd5YYY0XESwYsAaczfzBWauTfDzn3KxPIkrjxkfrPi/
         EdfA==
X-Gm-Message-State: APjAAAUUVKm18sRD8fGQo2HuKa+ZXi6qJcjrHMMj+dZbeqrnPJ3PdysZ
	iUKEDR5o4W8DJYLRpTrp0atAYqAzLOmsEnlyzqkgyHVGBsAOi6ZpllpYEn6Cds1WwAv7GUFnUHk
	RbA2A4ul71MFnUF79RBRZHGL7DyoGpYoA71aQS8sv3vXLT0BfIofOy5gIHhvfOI7hOOwNUsBRxx
	aBeemvYRZHxpp0/8x8/WtoNmld17i06EuBdvqOv8uRyM/mpuaA9lcKdinma44q01njMhWZyVOCe
	1qgqDe7avK4NpEtkUAPthqjSfr7Xm1xZMvuUFQTPXPeUgiaiy2VQjEXQ0fE5z8TUsvtRy06v9ej
	SGMDHzM8sf+xbJbFigMLCoT7oG3sf7njBEUUBeFO62b5KEhrDR9s33KBTURmUsGEUp+TsSxxt63
	h
X-Received: by 2002:a17:902:1a9:: with SMTP id b38mr21933959plb.37.1551728812619;
        Mon, 04 Mar 2019 11:46:52 -0800 (PST)
X-Received: by 2002:a17:902:1a9:: with SMTP id b38mr21933845plb.37.1551728811322;
        Mon, 04 Mar 2019 11:46:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551728811; cv=none;
        d=google.com; s=arc-20160816;
        b=NZ6tZB0w2l6zzkL72qNJK5yDFCVaWJKcem8/erqojBtJRXEi74SKFMY8OHpft2N+I2
         /0uZ/z3n0fBKVkSujdsaIThkinhCAi6lKjZSWCWz5X7y6QTNKAJZ6AHXYYUJlzHUJg5M
         YmcVhSyn3o7/7R8tI8lnWdvzq1l5aXN+cW2aueG1G1NrkCh94TMsddjZagECpZi/XTb6
         pD0jwTKLj9ym/KhZlzQTbSrfRicCD4vLQXFb3Hu7jhEbtsU4uMwWz6FPnf/9cB3U7U5b
         83ohdwb18T3Eum+gKq129uRqkopqQpCXGz0BqlFc8eaXEifahuZDlglBji9Z830eBPUt
         bPug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Xmz5CLW0FSy25OQrcpPjEI+jhUMsvf19y6/jwFDBJlQ=;
        b=le8/zUVcSK5nHpfNcu7xTINp/R2FyWetu7oBOeIfmnm4k0io/0U2ICpPCmqtiqzY7+
         IkipNyuFH386KAhefXEUTvKuKB8Vb02O7p38J6iKoDXT7h5pmS9pY/xyOVOrnykfiN7j
         hsdSf72gNphxMJ4096f1SO//r6I4S2B4PeD7MAJnLucoY61X+Ve8pawDMrAe69yKsqx/
         qq2BmGaEsy1hpRlxauggWcc8TsbWDF7HDuWmKHSZqIsAYwHaFt3+L//cEIEll8NWDVXm
         reaAsmoRGkb39DwC+1f5nLzbrgIJ4nFHC4aVyKo8VW9/z72A7UrznLLLhO8k9jpEErXr
         /BIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sQWEo9K1;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p25sor9982611pgl.75.2019.03.04.11.46.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 11:46:51 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sQWEo9K1;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Xmz5CLW0FSy25OQrcpPjEI+jhUMsvf19y6/jwFDBJlQ=;
        b=sQWEo9K1CGxltrMpEXO2LIK894eOWnmM8qXH1cQ+A8sgxCaq8NFdhDnAbfI+RFxqit
         ROUCK8A6X/kbviOJ6RZLIQEKMqb5Lr5qOi7NnkoRBAj+dcJcv1MI+Eqw0e1K7TAxXu79
         GBsuV/VhOEaScy5T55Ed8fR6FHDxwE6sUQxdlseSe9RJFX263YFbwRw6DLTXtcdlroYU
         F1o5tHsA2TAZt59Y3qqPq2PpGgtI0TW0ZMUd+xx/TuBQ0+IRskNaorJ6s2CffjVxgeC6
         7Fdf6skIKB52MA/FRYZhA8aXy6jIQ646pH8q9J7yfVEEMTn6O49yHz+WkGp4bnzJt9xQ
         c64Q==
X-Google-Smtp-Source: APXvYqxXGf+BxuaG8hXTW5NUGoEESrfS6v3Gbr/JMYj+Zojw5syYOQxjoXKNa9Y30ghsqwDey2xXyw==
X-Received: by 2002:a63:440d:: with SMTP id r13mr19917825pga.5.1551728810418;
        Mon, 04 Mar 2019 11:46:50 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id v15sm13499604pfa.75.2019.03.04.11.46.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 11:46:49 -0800 (PST)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Leon Romanovsky <leon@kernel.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>,
	linux-rdma@vger.kernel.org
Subject: [PATCH v3 0/1] RDMA/umem: minor bug fix in error handling path
Date: Mon,  4 Mar 2019 11:46:44 -0800
Message-Id: <20190304194645.10422-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Hi,

Ira Weiny alerted me to a couple of places where I'd missed a change from
put_page() to put_user_page(), in my pending patchsets. But when I
attempted to dive more deeply into that code, I ran into a bug in the
cleanup code. Leon Romanovsky has confirmed that and requested this
simplified patch to fix it, so here it is.

Changes since v2:

1) Removed the part of the patch that tried to delete "dead code",
because that code was dealing with huge pages.

2) Reverted the pr_*() line shortening, so as to keep this to only
the minimal bug fix required.

3) Rebased to today's linux.git.

Cc: Leon Romanovsky <leon@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Doug Ledford <dledford@redhat.com>
Cc: linux-rdma@vger.kernel.org
Cc: linux-mm@kvack.org

John Hubbard (1):
  RDMA/umem: minor bug fix in error handling path

 drivers/infiniband/core/umem_odp.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

-- 
2.21.0

