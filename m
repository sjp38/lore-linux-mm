Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B8EDC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:09:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4832F20840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:09:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4832F20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBADC8E0003; Thu,  7 Mar 2019 13:09:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9B138E0002; Thu,  7 Mar 2019 13:09:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C81638E0003; Thu,  7 Mar 2019 13:09:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7603F8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 13:09:30 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id h2so8967475wre.9
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:09:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=orfBePFDVPvptP/SIEB4LRUszsdy1P7zJ6ur8xGTkSA=;
        b=p3Dm8oMQEXNHfcieIkjKgPyYB5m7ya/8NrKUlcOCjEhPqVcMgPJiA/lmhP81w3reJn
         ts98VhH5bPJ898WUeQI7kz1sRnrERv3s9mXtGtdEGMkC8OJ5qUF/6conBF9xZNtLIKBB
         Oiz4gUkARgDTsBIvavMEXWlgfDMEeQvMN09k/F0TwHCZ/DnC9rXkxu7dCG73Wdu55/J3
         xwRWq36n2lIg7gyrkZzIz9aLxq5e5M+cq+usE1jWzT0ej2qB6mfahTCZJoQrubwCmQ5Y
         o2+IT8FEb/PofFzsrTfi3f0PlrDmiB9zTGNowFUCz4JeXaLbkRpkrlChnkR00nYOQhQI
         FXfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: APjAAAUBCGcuKzuVi/T50tzTvaDFFxSEvqEFhZOqEtGOC4gqWQArmkeD
	+VYt8sJ2E3BQ0w3Oa3sBrHAVg2hdpaXwgK5pE6LqAbpWqRgr9UWGD5tDcT+zpgC+jgqXkQrGVBF
	rHekwl3W8LyyX4TjKt65o6ilKcf6oZnFZrZnSNRlZejpLTog2wOzF+EEbHdqXnNgmBRHskLk5oQ
	EmaL6mf5kRExHdT40d0BVSbTbleS5aE1R+9Lan3ImLiIGHkLTBsbK7q2Ib6WPUDq0q3xBDd8qLv
	P970BfBGK5kQtw3D26LE1UlBQs02NdrMqaUKEy74T/88iWJpOIzE4icdi/87alGuFkS+eRqplBf
	U7NpQSlrizEFJh5+s66ZTsGJPJIKdWzI1AU/q1hJvkQyrGkB7whnmIATkUwQ2HtU950f+aDEqka
	rLpSKItJXvzkGYPO6Q6NZ2m2+By8VJbSLGeOmmXw6S1SY8R1b++Z8OeRUhDWSe4ZBGJl8SUCf5K
	A93V8zZq6fKMTZICFCW+OjkmOCVa6h7TmkxjTNgqTbRN5OAH+mTnF+NesF+VY2VJpZu9QBB0CDg
	VI3RjmPob05HTKGKSzqLs0aMw1jBfKEMfp9BLH6HGdU033ITYEI33VEFbO8925eRaaNd3njglxd
	rGHtg47KuVL3
X-Received: by 2002:a05:600c:219a:: with SMTP id e26mr6861016wme.93.1551982169629;
        Thu, 07 Mar 2019 10:09:29 -0800 (PST)
X-Google-Smtp-Source: APXvYqzHj7E+cVvHYdyR5xtWYPEI6EXFZoAWeis4d/2G0Y9Si9Zwene5VTxONuwQf6zgSpC5ddNm
X-Received: by 2002:a05:600c:219a:: with SMTP id e26mr6860945wme.93.1551982168275;
        Thu, 07 Mar 2019 10:09:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551982168; cv=none;
        d=google.com; s=arc-20160816;
        b=y9Bb1EWJj9aNUzCT6k0XclHZoKqJAkcR7Q8sxf2F+5uewupNXKeSshVaZa79XwXN8g
         btT/insAnBUw2lHGcXy0JdsVdHO6D6MqprKpEIgQnlLj18ot+IG8okFxcm/Tk8On9lMI
         PmBSHop5TV+ejgwSbD+1yu3Q6VGVCfOeyTIqRnWj/Mb8pu6pvDfomojS7h6nEZPUjbWJ
         CfY0pULG7uxH/rDW7CTk8OlM+I7oG60Sd6osyoqAwQK+ajSSmjpY/9bBO7YPDmStWUwW
         RKLhL94+46cx8FEpqTV0BQqpKuqUL2I/OnFzsTz8UtAPk2mRkfdwS4yvEMhwPWAviKQK
         FBlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=orfBePFDVPvptP/SIEB4LRUszsdy1P7zJ6ur8xGTkSA=;
        b=e56736ee1xpctC5CHiDei7XmHxn9EhVQDNvJM4EimBXtSbi0IZMGMAPlHC3wsGbmSe
         uVOqUpX7DmHAmTX3azCKIHr+c5VaTwxI741FVfqbPAhqQ1rJIZotbgcUjT6ocqvdopxs
         tCymP88+6f+QcYxeOsrxpym2epXE6NgLJ+d0XjQ9jbmdPjtkqHYd20yKa1Wqw5M7zyD8
         VMoioUrkZ94mYsyEXJ+WbGaEcUQvnLu5jpQoVLLOjC/a7COPixSks+Pc9vs8M6adNi9s
         3TkpJD6VjKGNlMyV0BZL3gSovk/kJlfolxRMU8FlS/YcvTtoA0QnNJzGbUb0//YmxY1G
         XqaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id p13si3452491wrq.131.2019.03.07.10.09.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Mar 2019 10:09:28 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from mail-wr1-f69.google.com ([209.85.221.69])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <andrea.righi@canonical.com>)
	id 1h1xSR-0001je-Fd
	for linux-mm@kvack.org; Thu, 07 Mar 2019 18:09:27 +0000
Received: by mail-wr1-f69.google.com with SMTP id a5so8960391wrq.3
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:09:27 -0800 (PST)
X-Received: by 2002:adf:e8c7:: with SMTP id k7mr8149002wrn.298.1551982167159;
        Thu, 07 Mar 2019 10:09:27 -0800 (PST)
X-Received: by 2002:adf:e8c7:: with SMTP id k7mr8148976wrn.298.1551982166849;
        Thu, 07 Mar 2019 10:09:26 -0800 (PST)
Received: from localhost.localdomain (host22-124-dynamic.46-79-r.retail.telecomitalia.it. [79.46.124.22])
        by smtp.gmail.com with ESMTPSA id a74sm7872747wma.22.2019.03.07.10.09.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 10:09:26 -0800 (PST)
From: Andrea Righi <andrea.righi@canonical.com>
To: Josef Bacik <josef@toxicpanda.com>,
	Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>,
	Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>,
	Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 0/3] blkcg: sync() isolation
Date: Thu,  7 Mar 2019 19:08:31 +0100
Message-Id: <20190307180834.22008-1-andrea.righi@canonical.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

= Problem =

When sync() is executed from a high-priority cgroup, the process is forced to
wait the completion of the entire outstanding writeback I/O, even the I/O that
was originally generated by low-priority cgroups potentially.

This may cause massive latencies to random processes (even those running in the
root cgroup) that shouldn't be I/O-throttled at all, similarly to a classic
priority inversion problem.

This topic has been previously discussed here:
https://patchwork.kernel.org/patch/10804489/

[ Thanks to Josef for the suggestions ]

= Solution =

Here's a slightly more detailed description of the solution, as suggested by
Josef and Tejun (let me know if I misunderstood or missed anything):

 - track the submitter of wb work (when issuing sync()) and the cgroup that
   originally dirtied any inode, then use this information to determine the
   proper "sync() domain" and decide if the I/O speed needs to be boosted or
   not in order to prevent priority-inversion problems

 - by default when sync() is issued, all the outstanding writeback I/O is
   boosted to maximum speed to prevent priority inversion problems

 - if sync() is issued by the same throttled cgroup that generated the dirty
   pages, the corresponding writeback I/O is still throttled normally

 - add a new flag to cgroups (io.sync_isolation) that would make sync()'ers in
   that cgroup only be allowed to write out dirty pages that belong to its
   cgroup

= Test =

Here's a trivial example to trigger the problem:

 - create 2 cgroups: cg1 and cg2

 # mkdir /sys/fs/cgroup/unified/cg1
 # mkdir /sys/fs/cgroup/unified/cg2

 - set an I/O limit of 1MB/s on cg1/io.ma:

 # echo "8:0 rbps=1048576 wbps=1048576" > /sys/fs/cgroup/unified/cg1/io.max

 - run a write-intensive workload in cg1

 # cat /proc/self/cgroup
 0::/cg1
 # fio --rw=write --bs=1M --size=32M --numjobs=16 --name=writer --time_based --runtime=30

 - run sync in cg2 and measure time

== Vanilla kernel ==

 # cat /proc/self/cgroup
 0::/cg2

 # time sync
 real	9m32,618s
 user	0m0,000s
 sys	0m0,018s

Ideally "sync" should complete almost immediately, because cg2 is unlimited and
it's not doing any I/O at all. Instead, the entire system is totally sluggish,
waiting for the throttled writeback I/O to complete, and it also triggers many
hung task timeout warnings.

== With this patch set applied and io.sync_isolation=0 (default) ==

 # cat /proc/self/cgroup
 0::/cg2

 # time sync
 real	0m2,044s
 user	0m0,009s
 sys	0m0,000s

[ Time range goes from 2s to 4s ]

== With this patch set applied and io.sync_isolation=1 ==

 # cat /proc/self/cgroup
 0::/cg2

 # time sync

 real	0m0,768s
 user	0m0,001s
 sys	0m0,008s

[ Time range goes from 0.7s to 1.6s ]

Changes in v2:
 - fix: properly keep track of sync waiters when a blkcg is writing to
   many block devices at the same time

Andrea Righi (3):
  blkcg: prevent priority inversion problem during sync()
  blkcg: introduce io.sync_isolation
  blkcg: implement sync() isolation

 Documentation/admin-guide/cgroup-v2.rst |   9 +++
 block/blk-cgroup.c                      | 178 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 block/blk-throttle.c                    |  48 ++++++++++++++-
 fs/fs-writeback.c                       |  57 +++++++++++++++++-
 fs/inode.c                              |   1 +
 fs/sync.c                               |   8 ++-
 include/linux/backing-dev-defs.h        |   2 +
 include/linux/blk-cgroup.h              |  52 +++++++++++++++++
 include/linux/fs.h                      |   4 ++
 mm/backing-dev.c                        |   2 +
 mm/page-writeback.c                     |   1 +
 11 files changed, 355 insertions(+), 7 deletions(-)

