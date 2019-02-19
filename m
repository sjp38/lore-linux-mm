Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7A6CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:27:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 651F021738
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:27:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qjsik3eW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 651F021738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB1F68E0003; Tue, 19 Feb 2019 10:27:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E61778E0002; Tue, 19 Feb 2019 10:27:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D78148E0003; Tue, 19 Feb 2019 10:27:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 817948E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 10:27:43 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id t9so855450wmb.6
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:27:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=QRLeOF9sct2PPfTZBOGt3U1G0PtSP4YDwZzbf5CfyMs=;
        b=FIXvawW3mElrKEpK6ILKho7uCYdhs9WLInHFGPXxiNeGGTNKPEExrg4sQelMp0hH60
         07SpIWK96fWjV3N+/phOnOg4G2EkKgVlPngpz+8Pm7+Y9rjgwSUKq540ANC8SEnntB6J
         bqxCgYcfl5KgCgFJNxSjgn23a/f1RVxr6NI6aYyu/6EDRNjA/LKZCsCGivQFNZysEAAz
         Q4cdmb3ptP/79ItpR39mL11M9S7zINwAGQrkkDW9ror0ykErz9GE0a25bAumPXMIH3af
         7Kp+guhzhIdAjY/EsT5Qvje0i9/SnjoM7POdH0jE8xKya97HUN2ak9baMonpl5z6m4/F
         LwTA==
X-Gm-Message-State: AHQUAubkl7kZK2y7ZI0kT/+X/J3BlJ/BULQMiZX6ZLBxUUdJvL0t+6vM
	OfMQLLvny61UeN6Zzg1QSOXSmdoiXu430wiiLInUoqblndqNXENeIzFJ0/xLCm/yn8gjFtQ4kUt
	xtPM8mtsZyoHLmRK+PVJCghOMOdlFtWU0LI/WsTPmDYTkeKN7ovRv/NABMO56TyHl2Em0pu9OXm
	tZndHeoyqKjMprzR5MUy9fAbIYB0muNow79hqKeVdPZdSq53mCgLq0kwrxw6f5yv/gsGkTupi4J
	Jtlgun455cy5ltrAFDe//MQjomYzqs0+lZFyfghWqYQ5tY4gXrfsFI4iE78D3/mHTMxgYWvFNL7
	Q8iFwvEXjYV+eAbanEW/HUjtdWNnVy6DJQbD7nKEU8NdDENbs1BKz07GBpytGzzgyVr+m2FivBf
	A
X-Received: by 2002:a7b:c04f:: with SMTP id u15mr3128513wmc.49.1550590063000;
        Tue, 19 Feb 2019 07:27:43 -0800 (PST)
X-Received: by 2002:a7b:c04f:: with SMTP id u15mr3128440wmc.49.1550590061439;
        Tue, 19 Feb 2019 07:27:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550590061; cv=none;
        d=google.com; s=arc-20160816;
        b=QlCojM/KvzHlSKh2NGqf2vqlxBAGJG1V+bGqSLUGNX27RV/Sj+dbdl4td70jfP9pEQ
         x7PTyuHsCY5BKyd060bylv0hfuD4FGZqM5q8VbP4Z0nSf8zkm19FdjAgcTR//T5ANDWx
         LVSGjcdIrnTrjezziYZXwdhq3geEwWXdB8p+GIMqkUfjT8iQzs/KakTb4rX+EblbxGUS
         kYgqBlIY6VYzje3vpnBwKeHBtc1KIg/ycBk901h36wfsKJvdqbY79oxylxjZ2540qtO8
         PwDMViWxcuuRPWeplCa5oh1T5oyqQlAtOzb+WZj1A53X2m3D6p5gwAB+ZEllQcV9fxFX
         ZHpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=QRLeOF9sct2PPfTZBOGt3U1G0PtSP4YDwZzbf5CfyMs=;
        b=M6y8GmpgXoINV0+UeTORhvMmqyysI946Wu1w79IDEwjqAyJRnvBNsh5qPpFf9UduTj
         RUcocYFsp7bE93VR8ipAfHgDD5wJnf29TtH81Iux39KaGU6UTBa3xP60nremG7qe39NF
         Wh7A8hv7ecf8eIlZBOZYvVt3/tA0RZjbhVdXaXcb0T3RDPEaWyuBGu2pkd6zWe8waqBf
         hBXrQGBuMuRA5Zo7EI2talFVEGOXM7bV9SpBcL9eBcmLj2WkTnesxd5ykEvK04i8vKaJ
         ug9B/AuLmZN0SOMl+ZOKIwf3qe49gM6QI/Lr3zqcOfR2nnlMYTVkPTQ8DYovFuX6nbDS
         8WNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qjsik3eW;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x4sor1812683wmk.14.2019.02.19.07.27.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 07:27:41 -0800 (PST)
Received-SPF: pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qjsik3eW;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=QRLeOF9sct2PPfTZBOGt3U1G0PtSP4YDwZzbf5CfyMs=;
        b=qjsik3eWzetZmcOurISZU93jAfURe1xQJ3zFn1INz0b4uqN0WD/DG6piBFWXI5HIOB
         uHppK7mOw2Ama+bq9uodFNG4GF8b0cVOb0qJ9UJG+c9Pp4f5FfKpipecy0YSJb1D3xqO
         xXGpkRh56J+mOI29KwoucgpXywq93YadzoZVJYZz6nccUTwM25DwesLO/pxPaxEeeQJ/
         GnEbIqmqRt4r9Ad0VT/RDd3js22e9pTGifXFXPEs3d9eWYM8Og0/M1Ax8Uxv69wSH3C0
         YkIt0yTjg5HbIkrN98PUdmPtwexTDvcHxzT/codZO/gEZyLgYH2tTvlCQR2ExjJhskSF
         sapg==
X-Google-Smtp-Source: AHgI3IYCBMozucS/tB1uFAFJO/YRmnkwcj/jMRFwGecFgakTSDbs/8qoGrBo+Mff86tukJ+gKWq/Ew==
X-Received: by 2002:a1c:4946:: with SMTP id w67mr3112790wma.20.1550590060817;
        Tue, 19 Feb 2019 07:27:40 -0800 (PST)
Received: from xps-13.homenet.telecomitalia.it (host117-125-dynamic.33-79-r.retail.telecomitalia.it. [79.33.125.117])
        by smtp.gmail.com with ESMTPSA id v6sm29029503wrd.88.2019.02.19.07.27.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 07:27:40 -0800 (PST)
From: Andrea Righi <righi.andrea@gmail.com>
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
Subject: [PATCH 0/3] blkcg: sync() isolation
Date: Tue, 19 Feb 2019 16:27:09 +0100
Message-Id: <20190219152712.9855-1-righi.andrea@gmail.com>
X-Mailer: git-send-email 2.17.1
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

Andrea Righi (3):
  blkcg: prevent priority inversion problem during sync()
  blkcg: introduce io.sync_isolation
  blkcg: implement sync() isolation

 Documentation/admin-guide/cgroup-v2.rst |   9 +++
 block/blk-cgroup.c                      | 120 ++++++++++++++++++++++++++++++++
 block/blk-throttle.c                    |  48 ++++++++++++-
 fs/fs-writeback.c                       |  57 ++++++++++++++-
 fs/inode.c                              |   1 +
 fs/sync.c                               |   8 ++-
 include/linux/backing-dev-defs.h        |   2 +
 include/linux/blk-cgroup.h              |  52 ++++++++++++++
 include/linux/fs.h                      |   4 ++
 mm/backing-dev.c                        |   2 +
 mm/page-writeback.c                     |   1 +
 11 files changed, 297 insertions(+), 7 deletions(-)

