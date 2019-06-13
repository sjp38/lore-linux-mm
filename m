Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31B80C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:45:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5685208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:45:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gh2zOgr9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5685208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39F426B0007; Thu, 13 Jun 2019 06:45:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 328E66B000A; Thu, 13 Jun 2019 06:45:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F05E6B000D; Thu, 13 Jun 2019 06:45:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9F036B0007
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:45:41 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 59so11696555plb.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:45:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=YHBzv4ECslLKpMkzoxjS6aoXKy/SFXtprHmV+JrqNk0=;
        b=MoXgNcSkBfEC1euuXA0ZDOZSWwENwX9ralV3nU/ISMw/lvpCNRXDgfWDGBLx+TYu6z
         kSw52uWv5rTycvMb8ft0qDsmr8fixVegundROqbE/eto0qMo92cX78OMF0gnkxULKETu
         oVQVQU0CXW/pPkI9nUEUYHffwJEtpnUv+wFU9hbwVIu9ZVYIfSlXexqvCoL1NCK9VjHe
         8xC+1RCGq13NDuzSZjXhxDBUp5/m5CSySSijR21jVfHnYjm/RjEh4+7/Mxv74baKmM2M
         IxHBpqKCJXz2Z9FJJhJWX2sIqPmn/fDaAGc7AKNNvlUTn4s3t7yIh18cO8Eua+Q80BjH
         q04A==
X-Gm-Message-State: APjAAAXWlD3v4p7cZqN2z6RAO/Ki9+rm4hWV3TlEWoPRi/XPEP038FXk
	0wtAq5Pnx9kZ8Ket1/ceD56PjVSw96aQDhWrbMGyu0jYiOVE0A1xXWYo5oPoSYebmuvnPyLs3n+
	4UtJuK3n0U5Lnlr8S3QvCvdVJkJrwYaVm0i3m643Dkj6/W5oqPGphBowFIenp6m9jBg==
X-Received: by 2002:a62:a508:: with SMTP id v8mr90175246pfm.87.1560422741480;
        Thu, 13 Jun 2019 03:45:41 -0700 (PDT)
X-Received: by 2002:a62:a508:: with SMTP id v8mr90175161pfm.87.1560422740780;
        Thu, 13 Jun 2019 03:45:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560422740; cv=none;
        d=google.com; s=arc-20160816;
        b=Ahk31MogOoH2WzYZmsd8VwxIo3abS7zb/O0eSHzDfR9bQOL6cUXeijzseXkUUxPOUk
         mxPmYSj90/VFZ/9cku/FJgqhQU4KOrjuW9dOa5ejit5hd//ZoLw18XrbZh9JY/RiF5oc
         1JVU9Rpn94XzdsloVZlzVsxrDCNMnqiwNUy/hfXJ8SSnYSNa25I+NoyoQM8QTUkRiUoS
         THwYMLfrvqJQU9DyTB10NvQlukSQPXyWLMKwz7nvGg0Ztq6aEG66BUDJNNgM8Ju/eJI0
         qFyvovhZB6yy5vz25YzzC99GtHs1DwaXO7upmnyWnEh2pCW9zkhCV+k94tcyZOEsI07b
         yQOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=YHBzv4ECslLKpMkzoxjS6aoXKy/SFXtprHmV+JrqNk0=;
        b=B2LlbC9ELG5tCQMARxjZIp6fEa/QICZ9LWIFyQGe5WIVHeSNVOQXmLSn6jjG4RgFK3
         L6tmct5IfGc+BZTMUhMH0iATyM+hSXl0B0T/O5tuNLFQZa/IPsQeai7JGLy1VyKlvHHk
         TBXs4ck3EVVPJin8rls17X74k1/DKCFDqui/qltGZZ+orPk4qpHgsIwDxw2SLVu6LDGX
         7XAmVVqqDLpoYR5vj/L8q1PfqJcdbJIJ+8QoX44cnMHPeIeonaML4TiR6k9+v+UGBB+8
         6Iy7WvKxxSc0H0Fm3XTb4kusm974UhWWzocaRHAY6E22kLiBZ3fHS6ntczAWXl9Avmco
         QrTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Gh2zOgr9;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7sor2073461pgm.25.2019.06.13.03.45.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 03:45:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Gh2zOgr9;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=YHBzv4ECslLKpMkzoxjS6aoXKy/SFXtprHmV+JrqNk0=;
        b=Gh2zOgr9bu+Tzr0HnGQ+mDT8OkUXS31CoKZCiImvLZkkl6q69mzX6Y9Hn3GwoO8JVf
         dtnKcxCHRIlz5+dyReJS5fGrudHhR1zZynm80yuqVFRbEs+OiEX3gEGuTDcheVRn8aAJ
         j02IfSd5WvBKV+C64bc+54++b3dRRFC/o446EASAeitsSlmTAJPqetf5dKkuiS8lch3L
         6fVAuTFAbWTED9Nh4GT4TtWektafSz9Mn5YtET6Rvl1yoSmtTWSY2RZ2jBlZGpgqGWLU
         vlFi7+o/YSBV+eCdzjBvwXH3WKZtd9XhuPGcxgmX+QM2DfIhEkp9bl8pREA7G5383mYx
         Rvog==
X-Google-Smtp-Source: APXvYqxCcyskfrhNoa8a6tvucCyA7BESJMT49IgekYmQ2ko0v0dbnBSjI4RkW++kqxhqfDThrA+ABQ==
X-Received: by 2002:a65:42c3:: with SMTP id l3mr30267732pgp.372.1560422739999;
        Thu, 13 Jun 2019 03:45:39 -0700 (PDT)
Received: from mylaptop.redhat.com ([2408:8207:7825:dd90:9051:d949:55f9:678b])
        by smtp.gmail.com with ESMTPSA id a13sm2813285pgh.6.2019.06.13.03.45.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 03:45:39 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	Shuah Khan <shuah@kernel.org>,
	linux-kernel@vger.kernel.org
Subject: [PATCHv4 0/3] mm/gup: fix omission of check on FOLL_LONGTERM in gup fast path
Date: Thu, 13 Jun 2019 18:44:59 +0800
Message-Id: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These three patches have no dependency of each other, but related with the same purpose
to improve get_user_page_fast(), patch [2/3]. Put them together.

v3->v4:
  Place the check on FOLL_LONGTERM in gup_pte_range() instead of get_user_page_fast()

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Shuah Khan <shuah@kernel.org>
Cc: linux-kernel@vger.kernel.org

Pingfan Liu (3):
  mm/gup: rename nr as nr_pinned in get_user_pages_fast()
  mm/gup: fix omission of check on FOLL_LONGTERM in gup fast path
  mm/gup_benchemark: add LONGTERM_BENCHMARK test in gup fast path

 mm/gup.c                                   | 46 +++++++++++++++++++++++-------
 mm/gup_benchmark.c                         | 11 +++++--
 tools/testing/selftests/vm/gup_benchmark.c | 10 +++++--
 3 files changed, 52 insertions(+), 15 deletions(-)

-- 
2.7.5

