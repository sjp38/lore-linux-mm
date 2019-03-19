Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05634C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83D602175B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:56:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TWam6T+q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83D602175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93ECA6B0003; Tue, 19 Mar 2019 19:56:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EB9B6B0006; Tue, 19 Mar 2019 19:56:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B2AC6B0007; Tue, 19 Mar 2019 19:56:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 444516B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:56:29 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z12so743498pgs.4
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:56:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=kx1U4HzcGCDUD7FXkKAwi3uQa2G8CItUW21Wgf4ughs=;
        b=aivXDllxM5cz3ExLfa4EDcdJ1gQgVUyZAclFySJf7QHelDRJDpe6aCgsksz3PpKUQj
         Hg6or25wKDrMJBUkNTjy9PAcPIusfqe0aUmqDsi4bwRvjqKjzhSWTepu1QN1dJoDWM0N
         C8Lx37zENTH+LyG9PehtzvdfW8xqCmLf+MqDvOYGjVJrcN5B7s4bRuweZCw/uuwuuGaT
         TLi2hSMa7h4sZPM3laH4UT45RYQ+oOazgSfJ+Hg6Xy2J81T6qAG8g8NO/XugDM9lzm4H
         rV8DAX33qNzvZD0zXzQFVMAq3ssaOkzxBd2Ez2mRMubl3+O4xvXzEbuUYAf67EF1QqSG
         UdPA==
X-Gm-Message-State: APjAAAULu8iw3gDCyC06CPT1JLe+jlPNuxw7SM73TxoesRlJBT5zcLP5
	K+AwVjWsQ03a59kbiMjzzheO57puYvdAECto+KXibVcQkgRTPFZ6i8LNzn8u90WnTN+omB+sr2N
	RKICe2yOdUUQ2hKMIGBXBJhWbtWnVzF48TRb876VnZ+balNI5OLoLWYeNW503MmazLQ==
X-Received: by 2002:a63:104e:: with SMTP id 14mr4342113pgq.185.1553039788753;
        Tue, 19 Mar 2019 16:56:28 -0700 (PDT)
X-Received: by 2002:a63:104e:: with SMTP id 14mr4342069pgq.185.1553039787840;
        Tue, 19 Mar 2019 16:56:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553039787; cv=none;
        d=google.com; s=arc-20160816;
        b=oIdwFcO7pZiiOSqR5ou+UTnHeZcQTXB9uR3Y3Uga2ZYtjfev5x7rd2kQt30hR+awZl
         emU+DMPSUEnfdOjO8Jysbdun9q1c2yZf6mjMlBwVF8dJljuRhc9cUaNx2CcMz6FmDSQs
         owWUyuhg46IxvE1CgCXse7Vg+RYt/7/TmkTiIsvVWWDm8kyLjbm/ZoKO/fhrScszuSGp
         RipR1rxiSIq8LLEtwIt6iE5sZxKjwj8REc3eGlYf4NewwZ9x0i8dOQju/MBVeJ+J2xdE
         fNZqc0C34T8TtzEWrIM26ngVbj+R/b6N37H19ZjLxu3ftJO93azO7DvgB8tdOp/Q+CUU
         4HMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=kx1U4HzcGCDUD7FXkKAwi3uQa2G8CItUW21Wgf4ughs=;
        b=r1IWgoij61eXnT6a583Xe+RfUsncKZYUdpLLt+JLQQXyzTupJlELcchpqfjUmPrhEi
         2rb2x6xz+WeFC7f46b/iK5x/JaZUeADeUzC2DA6yoIkWnie8UrpUhrBoTr6ZWZ+rOHRr
         76Q0WmcjHPXGIrMVu9sEA5sYWt7KDsJkGIYux9fyTNuvN+SDqz6uviEUqSvqGy/dRIjI
         lp369pW1fZ545auGmFJ44rabODn7052HCKfoAMZj70WkyF/uc/DbslEEYQPvgVtQNN4l
         Axv9E299v5n7VAyeQ3m+an47hsIn5IZvFA/c5LCzpCI5YkkWrxjH5j36x72gl1snjYC0
         uoLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TWam6T+q;
       spf=pass (google.com: domain of 3q4grxaykcn4surenbgoogle.comlinux-mmkvack.org@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3q4GRXAYKCN4SURENBGOOGLE.COMLINUX-MMKVACK.ORG@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id p25sor275947pgl.75.2019.03.19.16.56.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 16:56:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3q4grxaykcn4surenbgoogle.comlinux-mmkvack.org@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TWam6T+q;
       spf=pass (google.com: domain of 3q4grxaykcn4surenbgoogle.comlinux-mmkvack.org@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3q4GRXAYKCN4SURENBGOOGLE.COMLINUX-MMKVACK.ORG@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=kx1U4HzcGCDUD7FXkKAwi3uQa2G8CItUW21Wgf4ughs=;
        b=TWam6T+qQmrNZ7BniGuFoFdA0Bom65bX9YYOcvGrtw+jSpwzeqDyGdcmm0fjhAgkD+
         5BAR3ZlcHWxbchcmC0Or5zypwA+ur2abK3ZEa+RtFtFWaCHmQ8xiRDw/CrQEBu4wZnuc
         FGpXzWPyLYYxrKlUTQZnEK7A3OfpkBwWp/U5QEB1flxIyHjq0ZcxXy5EOZj6P4NwAPMv
         hw5VrtC2hptHTLyyO/3W0bZpBIko9kaDlaIeHMT+4URsSZRzhdtzsf1dwIULDqHiVqLZ
         4Ypbj7cH7GT7qOb/s+OZUS/VWIhK1IGe/EXblQTIkr1zZKwZHpKUPpEvs+D/fV8Cqzdd
         ucmw==
X-Google-Smtp-Source: APXvYqz/sHzZ+g6QFo17d//l//tblh/zsc+22QsrPhUP5kHVqLG5xyt/2VwRmx08JzSCz52Pk3ado9Ya3y4=
X-Received: by 2002:a63:db08:: with SMTP id e8mr8323996pgg.46.1553039787302;
 Tue, 19 Mar 2019 16:56:27 -0700 (PDT)
Date: Tue, 19 Mar 2019 16:56:12 -0700
Message-Id: <20190319235619.260832-1-surenb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v6 0/7] psi: pressure stall monitors v6
From: Suren Baghdasaryan <surenb@google.com>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, 
	dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, 
	peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, 
	cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, kernel-team@android.com, 
	Suren Baghdasaryan <surenb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is respin of:
  https://lwn.net/ml/linux-kernel/20190308184311.144521-1-surenb%40google.com/

Android is adopting psi to detect and remedy memory pressure that
results in stuttering and decreased responsiveness on mobile devices.

Psi gives us the stall information, but because we're dealing with
latencies in the millisecond range, periodically reading the pressure
files to detect stalls in a timely fashion is not feasible. Psi also
doesn't aggregate its averages at a high-enough frequency right now.

This patch series extends the psi interface such that users can
configure sensitive latency thresholds and use poll() and friends to
be notified when these are breached.

As high-frequency aggregation is costly, it implements an aggregation
method that is optimized for fast, short-interval averaging, and makes
the aggregation frequency adaptive, such that high-frequency updates
only happen while monitored stall events are actively occurring.

With these patches applied, Android can monitor for, and ward off,
mounting memory shortages before they cause problems for the user.
For example, using memory stall monitors in userspace low memory
killer daemon (lmkd) we can detect mounting pressure and kill less
important processes before device becomes visibly sluggish. In our
memory stress testing psi memory monitors produce roughly 10x less
false positives compared to vmpressure signals. Having ability to
specify multiple triggers for the same psi metric allows other parts
of Android framework to monitor memory state of the device and act
accordingly.

The new interface is straight-forward. The user opens one of the
pressure files for writing and writes a trigger description into the
file descriptor that defines the stall state - some or full, and the
maximum stall time over a given window of time. E.g.:

        /* Signal when stall time exceeds 100ms of a 1s window */
        char trigger[] = "full 100000 1000000"
        fd = open("/proc/pressure/memory")
        write(fd, trigger, sizeof(trigger))
        while (poll() >= 0) {
                ...
        };
        close(fd);

When the monitored stall state is entered, psi adapts its aggregation
frequency according to what the configured time window requires in
order to emit event signals in a timely fashion. Once the stalling
subsides, aggregation reverts back to normal.

The trigger is associated with the open file descriptor. To stop
monitoring, the user only needs to close the file descriptor and the
trigger is discarded.

Patches 1-6 prepare the psi code for polling support. Patch 7 implements
the adaptive polling logic, the pressure growth detection optimized for
short intervals, and hooks up write() and poll() on the pressure files.

The patches were developed in collaboration with Johannes Weiner.

The patches are based on 5.1-rc1

Suren Baghdasaryan (7):
  psi: introduce state_mask to represent stalled psi states
  psi: make psi_enable static
  psi: rename psi fields in preparation for psi trigger addition
  psi: split update_stats into parts
  psi: track changed states
  refactor header includes to allow kthread.h inclusion in psi_types.h
  psi: introduce psi monitor

 Documentation/accounting/psi.txt | 107 ++++++
 drivers/spi/spi-rockchip.c       |   1 +
 include/linux/kthread.h          |   3 +-
 include/linux/psi.h              |   8 +
 include/linux/psi_types.h        | 105 +++++-
 include/linux/sched.h            |   1 -
 kernel/cgroup/cgroup.c           |  71 +++-
 kernel/kthread.c                 |   1 +
 kernel/sched/psi.c               | 615 ++++++++++++++++++++++++++++---
 9 files changed, 836 insertions(+), 76 deletions(-)

Changes in v6:
- Fixed psi averaging regression introduced in 4/7 and caused by lack of
checking for avg_next_update before calling update_averages in psi_show
- Fixed missing header include in spi-rockchip.c causing kbuild test bot's
warning in 6/7

-- 
2.21.0.225.g810b269d1ac-goog

