Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDE39C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80303218A2
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80303218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CB848E0004; Wed, 27 Feb 2019 21:18:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17BD48E0001; Wed, 27 Feb 2019 21:18:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 091838E0004; Wed, 27 Feb 2019 21:18:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D199F8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:18:44 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id h6so14632554qke.18
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:18:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=AYoc/PM0O7RXeXdYPsnMgGnnG9KkzoC78/ddtavKcnM=;
        b=Ff6kxMTNT0nehtuAiNzp/6N0wVtG7Qa1ve0qiR2UM29nrORE3yz+SOsO6sDxT6ikNW
         cViPlLVaDlhFHmaueztBfadWl04MlfgnbCib/nxoB37zJJMr/jhmR4DVA1s5whtSsuXY
         nRvXNN1xoZxa2V5jLjH41LfDvLib+VOSVtewv101puYNffpM/KJ8AqV7I6gwHkzszSMT
         4dfbTTU1vN2s/B1K99BWYO4w13NPMyGagp2h3xlMuy0Mwa0t+ydSRGoomipJ2XN2wu3V
         4J88iNzud/JzYwvoJK8iU3c4Frdju0xto80T0TmfVFEIiQ6W8qjGrDeWPK8ATcHqKAtD
         d+QA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVkpiaX+ZagSk/5o6AFUTt2pKnctjyIqBZeNp89E2rbzv+hgPAo
	MvhAGPRpLreW/laOhIa9Umf9sx9XX3QovBlNnrq+fwZxMBEO105LCW2/zDWKR41lYLdTuS9YUwu
	9+bi3VwBgemjLkOdHklUzYSd+3Mz2duEe/v/JYbilLZ88w928X3Z/oLVIufKIcGfoEJSp3+Nckb
	KX89AFwE3A9+XDjBtNM0aOOdGsuulSSh0ZrxKZIGmWOeb/an4wdxSDzo4F6RR/KkbjhHJlfHyjK
	Pqi9Pgz0LPGcinWdBr2yoli8dwgI+jNpzYXRZ8AMOC1h+/cT6PgWcwCqsmlHnef3peXm9csk/4w
	PZXBUpSh8BENSfMtO84dVCSO9xmVIz/gk5YZAU4pHC/moT2BSQralEuQjYMxD9PFdi28aDRxKg=
	=
X-Received: by 2002:ac8:263d:: with SMTP id u58mr4265305qtu.295.1551320324587;
        Wed, 27 Feb 2019 18:18:44 -0800 (PST)
X-Received: by 2002:ac8:263d:: with SMTP id u58mr4265265qtu.295.1551320323486;
        Wed, 27 Feb 2019 18:18:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320323; cv=none;
        d=google.com; s=arc-20160816;
        b=o3CSko4bbT0p/52PhF7eu5edvc9Zlzsy6KKOI+KmurDgK8ABwCea9V6tmZMRZCjglP
         OhoFgIAuOCZXODqJKlNktqOwP57/K5Bn0KiGk6Svc2RSAiqm5FZ32CNUSrioHpFKmV63
         cVJczaIUYru/Z5t4J14almpR3dzFg3AgHbJlYWIN/Gdkr4IiFR6O1jSzl5FVD7d+YXME
         j05DdvbB2EU/Z2ZwO3CvL8eE50tSbxGxPwJNka8aV/7+4K1NOXPkwzwXIXeV4LSxJeVv
         ZBuMGwmslPGKTQLgfDGh8W3CThbp8a3QRT/6LDEg5wMRf+ybJc6Zb8e1ML6sAGqieaBF
         oa2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=AYoc/PM0O7RXeXdYPsnMgGnnG9KkzoC78/ddtavKcnM=;
        b=rjiv1llPE0G7o25guZ1O3ifUtrrVW9FdbNXlnlg0/2Hk5JKT2rE4m4f9koI3G2665E
         9Ya39Y4nXsFDLMJF+alE3n6OuPRgODcWXtTHvGliElwSK+j2rNfG9T2nsKhHBbcOYtxT
         ywUzuGYC+ng+IfRi8gATEug0IrgwCnctEL1BIoqO4usPJpK03DUgdGGJebik/xMotF3k
         ROegmNSO1CLWlhsr3U81jNAftuVBpMOXpz1S47kj4gIGTs0Vm8pwKzn+5saiH/YDLcYA
         zSXvd2iXSG4HqYhkYa84HSllwqI0W5eR49LpC1MfxC02tl6VDAYnqxHtPr0MZ+9COIlb
         oY0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g190sor10626258qka.70.2019.02.27.18.18.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:18:43 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqy0mzil+0zAVGSelr8mB4+l9uSMHs6jlOK7HfpNiP0KJg3N3BKUDnO1DFvo/+/hEq/+Rm8MIg==
X-Received: by 2002:a37:e10e:: with SMTP id c14mr4525046qkm.317.1551320323146;
        Wed, 27 Feb 2019 18:18:43 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:42 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 00/12] introduce percpu block scan_hint
Date: Wed, 27 Feb 2019 21:18:27 -0500
Message-Id: <20190228021839.55779-1-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi everyone,

It was reported a while [1] that an increase in allocation alignment
requirement [2] caused the percpu memory allocator to do significantly
more work.

After spending quite a bit of time diving into it, it seems the crux was
the following:
  1) chunk management by free_bytes caused allocations to scan over
     chunks that could not fit due to fragmentation
  2) per block fragmentation required scanning from an early first_free
     bit causing allocations to repeat work

This series introduces a scan_hint for pcpu_block_md and merges the
paths used to manage the hints. The scan_hint represents the largest
known free area prior to the contig_hint. There are some caveats to
this. First, it may not necessarily be the largest area as we do partial
updates based on freeing of regions and failed scanning in
pcpu_alloc_area(). Second, if contig_hint == scan_hint, then
scan_hint_start > contig_hint_start is possible. This is necessary
for scan_hint discovery when refreshing the hint of a block.

A necessary change is to enforce a block to be the size of a page. This
let's the management of nr_empty_pop_pages to be done by breaking and
making full contig_hints in the hint update paths. Prior, this was done
by piggy backing off of refreshing the chunk contig_hint as it performed
a full scan and counting empty full pages.

The following are the results found using the workload provided in [3].

        branch        | time
       ------------------------
        5.0-rc7       | 69s
        [2] reverted  | 44s
        scan_hint     | 39s

The times above represent the approximate average across multiple runs.
I tested based on a basic 1M 16-byte allocation pattern with no
alignment requirement and times did not differ between 5.0-rc7 and
scan_hint.

[1] https://lore.kernel.org/netdev/CANn89iKb_vW+LA-91RV=zuAqbNycPFUYW54w_S=KZ3HdcWPw6Q@mail.gmail.com/
[2] https://lore.kernel.org/netdev/20181116154329.247947-1-edumazet@google.com/
[3] https://lore.kernel.org/netdev/vbfzhrj9smb.fsf@mellanox.com/

This patchset contains the following 12 patches:
  0001-percpu-update-free-path-with-correct-new-free-region.patch
  0002-percpu-do-not-search-past-bitmap-when-allocating-an-.patch
  0003-percpu-introduce-helper-to-determine-if-two-regions-.patch
  0004-percpu-manage-chunks-based-on-contig_bits-instead-of.patch
  0005-percpu-relegate-chunks-unusable-when-failing-small-a.patch
  0006-percpu-set-PCPU_BITMAP_BLOCK_SIZE-to-PAGE_SIZE.patch
  0007-percpu-add-block-level-scan_hint.patch
  0008-percpu-remember-largest-area-skipped-during-allocati.patch
  0009-percpu-use-block-scan_hint-to-only-scan-forward.patch
  0010-percpu-make-pcpu_block_md-generic.patch
  0011-percpu-convert-chunk-hints-to-be-based-on-pcpu_block.patch
  0012-percpu-use-chunk-scan_hint-to-skip-some-scanning.patch

0001 fixes an issue where the chunk contig_hint was being updated
improperly with the new region's starting offset and possibly differing
contig_hint. 0002 fixes possibly scanning pass the end of the bitmap.
0003 introduces a helper to do region overlap comparison. 0004 switches
to chunk management by contig_hint rather than free_bytes. 0005 moves
chunks that fail to allocate to the empty block list to prevent excess
scanning with of chunks with small contig_hints and poor alignment.
0006 introduces the constraint PCPU_BITMAP_BLOCK_SIZE == PAGE_SIZE and
modifies nr_empty_pop_pages management to be a part of the hint updates.
0007-0009 introduces percpu block scan_hint. 0010 makes pcpu_block_md
generic so chunk hints can be managed as a pcpu_block_md responsible
for more bits. 0011-0012 add chunk scan_hints.

This patchset is on top of percpu#master a3b22b9f11d9.

diffstats below:

Dennis Zhou (12):
  percpu: update free path with correct new free region
  percpu: do not search past bitmap when allocating an area
  percpu: introduce helper to determine if two regions overlap
  percpu: manage chunks based on contig_bits instead of free_bytes
  percpu: relegate chunks unusable when failing small allocations
  percpu: set PCPU_BITMAP_BLOCK_SIZE to PAGE_SIZE
  percpu: add block level scan_hint
  percpu: remember largest area skipped during allocation
  percpu: use block scan_hint to only scan forward
  percpu: make pcpu_block_md generic
  percpu: convert chunk hints to be based on pcpu_block_md
  percpu: use chunk scan_hint to skip some scanning

 include/linux/percpu.h |  12 +-
 mm/percpu-internal.h   |  15 +-
 mm/percpu-km.c         |   2 +-
 mm/percpu-stats.c      |   5 +-
 mm/percpu.c            | 547 +++++++++++++++++++++++++++++------------
 5 files changed, 404 insertions(+), 177 deletions(-)

Thanks,
Dennis

