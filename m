Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FC16C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:39:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3857D20665
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:39:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JvA/At6K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3857D20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6F956B02C4; Wed, 18 Sep 2019 10:39:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A20866B02C6; Wed, 18 Sep 2019 10:39:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 936BE6B02C7; Wed, 18 Sep 2019 10:39:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0007.hostedemail.com [216.40.44.7])
	by kanga.kvack.org (Postfix) with ESMTP id 722AE6B02C4
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 10:39:04 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0C62BBEF3
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:39:04 +0000 (UTC)
X-FDA: 75948298608.07.word09_4f15f368d001f
X-HE-Tag: word09_4f15f368d001f
X-Filterd-Recvd-Size: 7376
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:39:03 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id q10so119634pfl.0
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 07:39:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=9JcxK53FZm41dsdkmHTZFxMR9/ow92BRA5QtCOLMTqI=;
        b=JvA/At6KxqCIT2TkoRxJhIZ86JYauc/e8toiz53hGvSovTZjhRC211Umhm+C25x+S1
         SU6xXohKCmUHeyjMSJFUG3GPgiOd/PSVFybFzW0MeCCVWTOa8Y5RrpNI+l9ibK0m5Aen
         2HWyL1+h505SyniP6JFrNFbLH90S3lhMAWp2cqFexLRzvF9HRElf6Z0S2cATFjFKCnqk
         MvWCwPwH7I1u2fRJ8C/CV6YPcd9b1HX1MDYpC8vxS2el13F5bidZbmmj/NrlCjXKndLJ
         UXNam3idKXVS5RX0Turo8c257XITRSjPirXsIjOwx24VUvnBwqGNgpesHBcGRBasDBm7
         rQhA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=9JcxK53FZm41dsdkmHTZFxMR9/ow92BRA5QtCOLMTqI=;
        b=k8S74otLya2lyeYmK9XxbKYZCxmTej/thR+uH61bJyr8bw7MSP+qjYDRcSe67QzkAT
         hCV4lXn9akQZr5iwXXNkOJ/IijpE5l8SjC7XIYQPu7fSgmeA+oP3tJ+cPc2AFxS23nxf
         3sPV0w03oqc1xqX5KiFZZV9R/Yu34WXW+RaBV4kbcDZuXArkDb3e2GHfd2EskxH/stJv
         hrlTGpjJEHhyjZMAXtb7doaLtFQjvnxGUBvz3MfFEHwVM1GQIvCLRWKowDYPWvTsfZU5
         4KFDEiLjaISaXHXbHQ2xfvButcsOLy3PiqIYFqluZAX6zUZJbvavC5GCm1UtFnPgEYlC
         GuXQ==
X-Gm-Message-State: APjAAAWoKT2U2LEFnPeEGYfRYlgZCCM6h+CxQLrNNIdJ4EuEDD0DIAQ2
	VxhiYRggbIpcQS+33Tjcl4c=
X-Google-Smtp-Source: APXvYqxC0zahmUi6NqLYM3uVLJyt7dyjxoLxaQX/Y2vEFda5iT3k1vD2Lkdzl42Q9qBHYNb4BdSEpg==
X-Received: by 2002:a62:1cf:: with SMTP id 198mr4689068pfb.31.1568817542266;
        Wed, 18 Sep 2019 07:39:02 -0700 (PDT)
Received: from dev.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id l11sm5272197pgq.58.2019.09.18.07.38.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Sep 2019 07:39:01 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: peterz@infradead.org,
	mingo@redhat.com,
	acme@kernel.org,
	jolsa@redhat.com,
	namhyung@kernel.org,
	akpm@linux-foundation.org
Cc: tonyj@suse.com,
	florian.schmidt@nutanix.com,
	daniel.m.jordan@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH 0/2] introduce new perf-script page-reclaim
Date: Wed, 18 Sep 2019 10:38:40 -0400
Message-Id: <1568817522-8754-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A new perf script page-reclaim is introduced in this patchset.
This new script is used to report the page reclaim details. The possible
usage of this script is as bellow,
- identify latency spike caused by direct reclaim
- whehter the latency spike is relevant with pageout
- why is page reclaim requested, i.e. whether it is because of memory
  fragmentation
- page reclaim efficiency
etc
In the future we may also enhance it to analyze the memcg reclaim.

Bellow is how to use this script,
    # Record, one of the following
    $ perf record -e 'vmscan:mm_vmscan_*' ./workload
    $ perf script record page-reclaim

    # Report
    $ perf script report page-reclaim

    # Report per process latency
    $ perf script report page-reclaim -- -p

    # Report per process latency details. At what time and how long it
    # stalls at each time.
    $ perf script report page-reclaim -- -v

An example of the script's report,
    $ perf script report page-reclaim
    Direct reclaims: 4924
    Direct latency (ms)        total         max         avg         min
                          177823.211    6378.977      36.114       0.051
    Direct file reclaimed 22920
    Direct file scanned 28306
    Direct file sync write I/O 0
    Direct file async write I/O 0
    Direct anon reclaimed 212567
    Direct anon scanned 1446854
    Direct anon sync write I/O 0
    Direct anon async write I/O 278325
    Direct order      0     1     3
                   4870    23    31
    Wake kswapd requests 716
    Wake order      0     1
                  715     1

    Kswapd reclaims: 9
    Kswapd latency (ms)        total         max         avg         min
                           86353.046   42128.816    9594.783     120.736
    Kswapd file reclaimed 366461
    Kswapd file scanned 369554
    Kswapd file sync write I/O 0
    Kswapd file async write I/O 0
    Kswapd anon reclaimed 362594
    Kswapd anon scanned 693938
    Kswapd anon sync write I/O 0
    Kswapd anon async write I/O 330663
    Kswapd order      0     1     3
                      3     1     5
    Kswapd re-wakes 705

    Per process latency (ms):
         pid[comm]             total         max         avg         min
               timestamp  latency(ns)
           1[systemd]        276.764     248.933       21.29       0.293
           3406860552338: 16819800
           3406877381650: 5532855
           3407458799399: 929517
           3407459796042: 916682
           3407460763220: 418989
           3407461250236: 332355
           3407461637534: 401731
           3407462092234: 449219
           3407462605855: 292857
           3407462952343: 372700
           3407463364947: 414880
           3407463829547: 949162
           3407464813883: 248933444
         163[kswapd0]      86353.046   42128.816    9594.783     120.736
           3357637025977: 1026962745
           3358915619888: 41268642175
           3400239664127: 42128816204
           3443784780373: 679641989
           3444847948969: 120735792
           3445001978784: 342713657
           3445835850664: 316851589
           3446865035476: 247457873
           3449355401352: 221223878
          ...

This script must be in sync with bellow vmscan tracepoints,
        mm_vmscan_direct_reclaim_begin
        mm_vmscan_direct_reclaim_end
        mm_vmscan_kswapd_wake
        mm_vmscan_kswapd_sleep
        mm_vmscan_wakeup_kswapd
        mm_vmscan_lru_shrink_inactive
        mm_vmscan_writepage

Currently there's no easy way to make perf scripts in sync with
tracepoints. One possible way is to run perf's tests regularly, another way
is once we changes the definitions of tracepoints we must keep in mind that
the perf scripts which are using these tracepoints must be changed as well.
So I add some comment for the new introduced page-reclaim script as a
reminder.

Yafang Shao (2):
  perf script python: integrate page reclaim analyze script
  tracing, vmscan: add comments for perf script page-reclaim

 include/trace/events/vmscan.h                     |  15 +-
 tools/perf/scripts/python/bin/page-reclaim-record |   2 +
 tools/perf/scripts/python/bin/page-reclaim-report |   4 +
 tools/perf/scripts/python/page-reclaim.py         | 378 ++++++++++++++++++++++
 4 files changed, 398 insertions(+), 1 deletion(-)
 create mode 100644 tools/perf/scripts/python/bin/page-reclaim-record
 create mode 100644 tools/perf/scripts/python/bin/page-reclaim-report
 create mode 100644 tools/perf/scripts/python/page-reclaim.py

-- 
1.8.3.1


