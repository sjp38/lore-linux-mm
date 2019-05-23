Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E487C282DE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 07:26:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EED52175B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 07:26:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="miPz6BwB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EED52175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02ECC6B0007; Thu, 23 May 2019 03:26:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F21436B0008; Thu, 23 May 2019 03:26:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE9F16B000A; Thu, 23 May 2019 03:26:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A97F76B0007
	for <linux-mm@kvack.org>; Thu, 23 May 2019 03:26:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id b3so3286099pgt.12
        for <linux-mm@kvack.org>; Thu, 23 May 2019 00:26:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=jlgXheI8cakQJ3hxWBVQn//xqmqtv7/wivwFD999U00=;
        b=NenYWiNcqfDDFVunsDM4jF+oUMzcpRyO64MCD3wwutp9KcO7TUpu55E+ljXlKCSJqj
         2wzHqhKGyEckXspQPxNhNFvW8ylcYU8AIKAR6ZcasqcQhrchFSzeid3v5v6V+kFe5CG1
         RHvhSuw5dY6N2UxYIelUwVQdq8I8BzSk4zP8pyTN94l0ZS2rR3u4s0Uo6/ORZxjF7DYV
         V1UOKI8oNZktIniT/PzN9gWkle5/sXzJmETXq5w5JOS0/av1iwUHp+TDPU2Gg1mtLk3k
         OoVCTySW+zNrp3TmKiySftdo/NxzRsdcK39iMLETuAslAQLU4bVquQZFijB/05NSbTOY
         +FNA==
X-Gm-Message-State: APjAAAW1AkCmWmDOIQUPBVTC5TYzG8/di7cia/G6dQ2rhk9cJ1HC85py
	7f0ucMIld9wKv9GnPPz1A8/5kJThKLmTBHUH/NZuqdLO/QBbJGFS3vtzxxQKqxXMl4mxkpq77H1
	+5Ig0SK1inMgq61echoxdIqI1IQcJP8se1hPJHVpMwp72ZCz5Dviem1l+icDnlOc5WA==
X-Received: by 2002:a17:902:8214:: with SMTP id x20mr73330303pln.308.1558596412282;
        Thu, 23 May 2019 00:26:52 -0700 (PDT)
X-Received: by 2002:a17:902:8214:: with SMTP id x20mr73330255pln.308.1558596411346;
        Thu, 23 May 2019 00:26:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558596411; cv=none;
        d=google.com; s=arc-20160816;
        b=WQlKRxj1Llm1IxJ/ryH0Z3/5ct5wMU2XAQsqsC/bdBGAQxiWxAo5dyVoBd5pwc2FBn
         7zC0vfEb415bw4H0CEJHdazHWSuCxOO1y5FZNv/DvU9voCxQHLkiUiJo9OnjDGOQbWyY
         KE5sxXI85zWfqgpMxGnEep/bsX6cqob7ZK7GDuDLpv2n4+VYcSLRFPnQDEG+K7TAOoNt
         85BV0ax+LG1r0zh0eECEf0CxHeUyniI1TUHQjBfXtQObKdfBXLOMRjJ/cBtNA/fnUMI3
         Gg8Fs9rfGekulZ1GbpEaBLvTBwdph/eKlzyTUuDqPbg4GgCfcLbGshq8c8Qrv7fBI+js
         TkJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=jlgXheI8cakQJ3hxWBVQn//xqmqtv7/wivwFD999U00=;
        b=Hr0eArx5uIHVhYZCNznd9KdtA89prbipjrIY0kUMMJpEDfD7OruG6K0mIEBy/bt0wf
         66TOQfo5/eoX1WOKgou0rppy7/DTf82rVAwaBtDdUqlalI6np1rmfiyFw0huw5w2yJIm
         GKrqiJM60HmJOTzmT9LQS5/8cSVOunFCT6xe/B56aN08DAxMAIqzmzygTbSitvpQfXtK
         zKXfsS0oCOawlZgYGFY0wx70Y8/QPEFVJRcy/qAHV+ZsoIR7iG9guBSsqq1RN1BDpKk+
         t02XnTe+D62oQn8SQaBP5PGvcSaHyNdfyBQPKVJVZdfIjxA1FHeVScWT5FpCgeDTslag
         cbXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=miPz6BwB;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d12sor28757820pfh.21.2019.05.23.00.26.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 00:26:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=miPz6BwB;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=jlgXheI8cakQJ3hxWBVQn//xqmqtv7/wivwFD999U00=;
        b=miPz6BwBvCH/RwStiWjuSr1wakdqBdEhGehwuMJC4tO21Cw8ngK6NXuRGZ2I5CWEg4
         WleCVkkpJ9zCcpvwW7NirYcjPdM7WxWnwjsOjpDkOJuHLgXB9Azi6BCQOJC2rxzxObo/
         rFwHQgUe5y6j6V7golq2+nWhc58gg72Q6WQ95IBEfq1NeWEHmmu8tpmagq+WJDplyTI/
         1B4Edp3PxMoN13A0VtjmgUU3SWYeokLlAd+8cbYTJNS6ihRDMNpjXBONnvqkU71mdRnj
         wDtlRBdO/GTSgGNbezXpJMcWScq97PkWVgYwu3zbMf7D+AzZDTwIrfIA16vKv9F/yKRr
         xZ+w==
X-Google-Smtp-Source: APXvYqwf8LWIvH1gPuRB+qfMGWb6tJdZL0eVa2OLEmxDxHtdyyOSvGVrXYSWrhxK4E/sp3TNPYSyjA==
X-Received: by 2002:a62:5487:: with SMTP id i129mr100345262pfb.68.1558596410687;
        Thu, 23 May 2019 00:26:50 -0700 (PDT)
Received: from sandstorm.nvidia.com (thunderhill.nvidia.com. [216.228.112.22])
        by smtp.gmail.com with ESMTPSA id i7sm25052054pfo.19.2019.05.23.00.26.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 00:26:49 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-rdma@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Doug Ledford <dledford@redhat.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH 0/1] infiniband/mm: convert put_page() to put_user_page*()
Date: Thu, 23 May 2019 00:25:36 -0700
Message-Id: <20190523072537.31940-1-jhubbard@nvidia.com>
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

Hi Jason and all,

IIUC, now that we have the put_user_pages() merged in to linux.git, we can
start sending up the callsite conversions via different subsystem
maintainer trees. Here's one for linux-rdma.

I've left the various Reviewed-by: and Tested-by: tags on here, even
though it's been through a few rebases.

If anyone has hardware, it would be good to get a real test of this.

thanks,
--
John Hubbard
NVIDIA

Cc: Doug Ledford <dledford@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
Cc: Christian Benvenuti <benve@cisco.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Ira Weiny <ira.weiny@intel.com>

John Hubbard (1):
  infiniband/mm: convert put_page() to put_user_page*()

 drivers/infiniband/core/umem.c              |  7 ++++---
 drivers/infiniband/core/umem_odp.c          | 10 +++++-----
 drivers/infiniband/hw/hfi1/user_pages.c     | 11 ++++-------
 drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +++---
 drivers/infiniband/hw/qib/qib_user_pages.c  | 11 ++++-------
 drivers/infiniband/hw/qib/qib_user_sdma.c   |  6 +++---
 drivers/infiniband/hw/usnic/usnic_uiom.c    |  7 ++++---
 7 files changed, 27 insertions(+), 31 deletions(-)

-- 
2.21.0

