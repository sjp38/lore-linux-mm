Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69FDDC10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0537F20857
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="J0E6l8PL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0537F20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E26E8E0003; Fri,  8 Mar 2019 13:43:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 593528E0002; Fri,  8 Mar 2019 13:43:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 485228E0003; Fri,  8 Mar 2019 13:43:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 042B38E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 13:43:20 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y1so21160605pgo.0
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 10:43:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=ACm0jVzCyuutlk8CKHsubOzb2TygYzufZCwbrPfQ1JQ=;
        b=dvsA7om6jZZzLTpT4OJBlz80ahkdd/DJUQvQ4rSzSOfP1BtTxg7Gsn3a2KFluhHcKf
         aj29h69WNcv9elY81X3DIxdsAQQUAPg0F1VLiFnbU+7OmOsYn2k3FmBGsfDfGeQyzXad
         XNKBXIZBBkkmDUgTN0mwBaJmYuowfHKzFieeVhiBJ8B274a4lGIaQw7TaO1cyHhZIRfl
         NVp5wALGounXNm5FodDVn/aCk0EcpB1G1v6LP3Ttqryn+3c4pXxOd38P29blNCMU2C5D
         74Op7Lkoqt5NUR9e+3JgwyFNORaBbZe1tmUN/Ys9DzmSA9dzp2aOWr0Oq4Len0grcHtp
         VWJw==
X-Gm-Message-State: APjAAAV0Lo0XEoFBRQcyvWb6Hw9oeNnYkh9prAdAA+Kwc1Ytr22c0e+G
	LH1cxh3ksRfP6tF6BLo8unprT3JPJRCiidlskQd9opByOaDJMHPWFb/f3/CbJvUCWqnzhbUAK3D
	5JwjQfO4azGQAAxqwPJjxK7CHNHb2kG8j8gjyC+9vhpOY6ZyPk8YPs4gjQ4IxUOyeVnKQCaKCwT
	pMGa6ecTfF0QUMxQzIDmijmrECEfG27Duns8MGWoZqvbs7aDBPjR9zVSz8ahjm4kdh3aIvB8pF0
	YBDmwbJNYwKtF7Ce76KNtF4VChv5xr4gFOmznER4FjbBp3dX9jzrDeYOxp5nyApgSrVWcpCPVPj
	K4V6ncfiNmkG9UXcP2zJ/JkUDDA0vLe2wxJDrZHc4aKrjtOlPC9ifjfkljJ5VwLhx814la771PR
	0
X-Received: by 2002:a17:902:6684:: with SMTP id e4mr20272909plk.90.1552070599562;
        Fri, 08 Mar 2019 10:43:19 -0800 (PST)
X-Received: by 2002:a17:902:6684:: with SMTP id e4mr20272841plk.90.1552070598458;
        Fri, 08 Mar 2019 10:43:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552070598; cv=none;
        d=google.com; s=arc-20160816;
        b=SQISQSERbrYMNi/vOzpxqs+guQA98A4RvRkKBw5I2+1NHRgxhOz1WXrLwYsPRKhp2I
         N8W7W7lRliC/9Dk9ZnuFUTduMOx6fA9V4mwdWM0i/HC1g9gzWKLXVOuXpCmVJU7jOX7Q
         LeP0qZZ88fQNHWU+4sLVkGNFEVCminVL7u31mZP4Xr6DBlqKgtIRh7HimRVSfwWc5aaX
         HLbU0+ncK29ESUhSfkDnXpsR09UnExOjWGP/aRWM9SU8/vPZlwo/qWu0qBS39xdvayqN
         y9Jbk4tvBGDMpyQIKIhnQCXeJIlzPIRMjTGxarCNy/fzEWVvmAI7Am0xJSCX0mj1fJ55
         g2+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=ACm0jVzCyuutlk8CKHsubOzb2TygYzufZCwbrPfQ1JQ=;
        b=VnWBvS65U3BSGmQcy07ozG9V+o43Ni0SV1WQ+kpwxWn4Ca0UM28M7cYQkUUW91iB+6
         uHdKwrRAcXYBHkcqfOP8vfED5GCjAYjKgCaOoS5lh4Urlsb+KQJ0vHIv5/U3XVD59Gnm
         sp31DhrBJtWBD2dEP7jVFhUSTDpaQM9uNoQiGitk+2SCsCdBdvYjIfjSz+v0jKFvBFC+
         XArYm2qCFGb0zV5b7w5Xb1X00tbPZfzpcgSK2jrnPaS4DesxHHiaLOQo/CCHg1MuLUDB
         UNqnZOfc/AVIC79jE6bid46LYmSaBHiRobk21ywMas4g8/7XaGUSn1HupbQFMLXHgbPw
         yjzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=J0E6l8PL;
       spf=pass (google.com: domain of 3xbecxaykccoyaxkthmuumrk.iusrotad-ssqbgiq.uxm@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3xbeCXAYKCCoYaXKTHMUUMRK.IUSROTad-SSQbGIQ.UXM@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g67sor13428439plb.5.2019.03.08.10.43.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 10:43:18 -0800 (PST)
Received-SPF: pass (google.com: domain of 3xbecxaykccoyaxkthmuumrk.iusrotad-ssqbgiq.uxm@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=J0E6l8PL;
       spf=pass (google.com: domain of 3xbecxaykccoyaxkthmuumrk.iusrotad-ssqbgiq.uxm@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3xbeCXAYKCCoYaXKTHMUUMRK.IUSROTad-SSQbGIQ.UXM@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=ACm0jVzCyuutlk8CKHsubOzb2TygYzufZCwbrPfQ1JQ=;
        b=J0E6l8PLxa5AD+SoFiGGjQrXKPVXQ7Cx91Pa0ZqDnL4UDnfiPF53kuY9n0IrxtSJiM
         EIMnT7i9kQ+MVedAntcAllJrZpI4iOUum/s1tw+sRsvJ4hwpOnCAsLrq1Bjgn5EAsHn6
         63AjOaYrP0ccldyFwZsJ0TY2SmZpeFs1HC280O5/5PUWcwrYCg0URIhkoBBt3tD121nY
         gjebWK2xb+jE87wqcSqDIS3q9gc5xe2SgWxrcUBr2POsuqcgVIgQ4zLSHPNt3Ba/++Iu
         08MHlYhpV7pNvDPrwT9m2ejAUuXL5nsURLT6CZT97fJchmrfMW81badeAl+Zd4jnRhF6
         1OMg==
X-Google-Smtp-Source: APXvYqy9OwpfshRBnwEzf4DRMpDWh9yi53/pJqTjDnVCsZY46HDQRmUGVPGKcekhVOLLENr+XNITRbfI8MY=
X-Received: by 2002:a17:902:8f92:: with SMTP id z18mr6275215plo.17.1552070597966;
 Fri, 08 Mar 2019 10:43:17 -0800 (PST)
Date: Fri,  8 Mar 2019 10:43:04 -0800
Message-Id: <20190308184311.144521-1-surenb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v5 0/7] psi: pressure stall monitors v5
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
  https://lwn.net/ml/linux-kernel/20190206023446.177362-1-surenb%40google.com/

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

The patches are based on 5.0-rc8 (Merge tag 'drm-next-2019-03-06').

Suren Baghdasaryan (7):
  psi: introduce state_mask to represent stalled psi states
  psi: make psi_enable static
  psi: rename psi fields in preparation for psi trigger addition
  psi: split update_stats into parts
  psi: track changed states
  refactor header includes to allow kthread.h inclusion in psi_types.h
  psi: introduce psi monitor

 Documentation/accounting/psi.txt | 107 ++++++
 include/linux/kthread.h          |   3 +-
 include/linux/psi.h              |   8 +
 include/linux/psi_types.h        | 105 +++++-
 include/linux/sched.h            |   1 -
 kernel/cgroup/cgroup.c           |  71 +++-
 kernel/kthread.c                 |   1 +
 kernel/sched/psi.c               | 613 ++++++++++++++++++++++++++++---
 8 files changed, 833 insertions(+), 76 deletions(-)

Changes in v5:
- Fixed sparse: error: incompatible types in comparison expression, as per
 Andrew
- Changed psi_enable to static, as per Andrew
- Refactored headers to be able to include kthread.h into psi_types.h
without creating a circular inclusion, as per Johannes
- Split psi monitor from aggregator, used RT worker for psi monitoring to
prevent it being starved by other RT threads and memory pressure events
being delayed or lost, as per Minchan and Android Performance Team
- Fixed blockable memory allocation under rcu_read_lock inside
psi_trigger_poll by using refcounting, as per Eva Huang and Minchan
- Misc cleanup and improvements, as per Johannes

Notes:
0001-psi-introduce-state_mask-to-represent-stalled-psi-st.patch is unchanged
from the previous version and provided for completeness.

-- 
2.21.0.360.g471c308f928-goog

