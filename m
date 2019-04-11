Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EBA4C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:44:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E252204EC
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:44:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sVv0xkpT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E252204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF8B86B0275; Wed, 10 Apr 2019 21:44:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA87B6B0276; Wed, 10 Apr 2019 21:44:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBDDD6B0277; Wed, 10 Apr 2019 21:44:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 847726B0275
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:44:02 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a3so3135026pfi.17
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:44:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc:content-transfer-encoding;
        bh=nMpKzlGnRjDmkTf14iU5Inuh5KPox7tkPv+EdiTrd5w=;
        b=B78DqsLHhnALVqRVunLM88k02LdL83b+QkyjV8oaefsUHIfDlMlUW1MECgphTE3Xeh
         ZKnIBd1aO/JA8Q5SYAugSmoLCxnqzzg1xHNMbxHDc7O8BnxHH9GYApphH4CedmZvDzv6
         JwnEtNP7EqXrTmj4NF+qdZZGEKlMhaXnhOSvSv9ehXl1ajYcUtikC2IraIwwQG5KFUvh
         2tFem8qu8lIXUEX3wrLQIXF/PM35y+iGCXt6o1yq8/NE1uZhc0omlNK5rmO3fkp7ezF2
         84mbjX1QhNXwN3Z23mpQlq5n7mB+9bxQPPisTrYu8KcRTRENiPxgqT1PiHGtIStSIlDt
         UoWQ==
X-Gm-Message-State: APjAAAVlUOkLCWSIOUj7P2cmT9YhmkD/5x/kanB2s2VoAX9JvCWttjyk
	AGAKPo+kO0IvziQxDdpfr81yVTEqYMjVsWV66ImaCak1GpVFZz6ACm6AhlakMM826uUVuT/AEPj
	E5Cp5CXjOEYNfWnefBCMusyc/fhN1lvBBzrSoClU+qPNUtgAOmi6TviffqOPaUi6bPw==
X-Received: by 2002:a63:3188:: with SMTP id x130mr42654203pgx.64.1554947041609;
        Wed, 10 Apr 2019 18:44:01 -0700 (PDT)
X-Received: by 2002:a63:3188:: with SMTP id x130mr42654139pgx.64.1554947040555;
        Wed, 10 Apr 2019 18:44:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554947040; cv=none;
        d=google.com; s=arc-20160816;
        b=G7bvhBC9UVEJYv4HTG16jzO5oiWHR0qGcsHBo/TfuFMqpNyg1qf9Lmna3yMPNvK29/
         z5TnQ+ee5XefzRJytIolhK5l9K2K8W7F5LPfGHxiGXkj0PP6rqjd2EDKPB/LDIxU/a0v
         SNTN1J9t29PEOSjilGZS0n9pg/4gYuKyih/cpC5G4TXXvEZOZ8/dhgiJv2d1OykAxn0i
         5lWrA2yEAOSucc3dYb6vRNjitJimUDTihfnAAAWMqCcW20mzjWlur7pWEbZ2WZNmau4E
         aTMcbiSjSMb92thwOtzMiZB5l3UddyXFMvZlMyo3Yz1xcw2QBwGg+jexLh9PBaEzPnV9
         /1Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:from:subject:mime-version
         :message-id:date:dkim-signature;
        bh=nMpKzlGnRjDmkTf14iU5Inuh5KPox7tkPv+EdiTrd5w=;
        b=AS8M1Ky1anINjyIDanmA8UBDYZfZCLSKxRt6bYt87dpelbZF/ygxJf7eXwIgedXZuo
         LyLbKmylUSPSQrUU7xtq5mTYE45atM4RtstU1cwQ5ZK8ISMvoj+ETjpyYevosI81OZHJ
         hxBT4lh+M9Z1SJ0MrgQWhY0dPHrq7deA4cZtomQ1SadXbEQgMtfE+zSHL/Ic9GjOmDfi
         cBEUI686qNcLghZLH54TZx84RGPIoZUGf1BQEFVJZ5EaDgeEiwXjGPWciApoG0R/geM4
         4m179IXeHGrvTlFJALOhqAktDkD4xljXpcRN28bsurr2rbK4TsaYDxHwcZCbQhN+gyNp
         nOuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sVv0xkpT;
       spf=pass (google.com: domain of 335uuxaykclwuwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=335uuXAYKCLwuwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id h12sor40953790pgq.71.2019.04.10.18.44.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 18:44:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of 335uuxaykclwuwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sVv0xkpT;
       spf=pass (google.com: domain of 335uuxaykclwuwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=335uuXAYKCLwuwtgpdiqqing.eqonkpwz-oomxcem.qti@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc
         :content-transfer-encoding;
        bh=nMpKzlGnRjDmkTf14iU5Inuh5KPox7tkPv+EdiTrd5w=;
        b=sVv0xkpTwtzSlxpxf7Eh4uPvLQht8KTOHpymErP8ujjl0cROfAcy7azfsZtPXzWhWD
         cPgOu8rqPN+xOWDfdsbN52MxtcOc8fPxkqn1nTl62mmFD96RJ3eCnLvqiljGRTmR+iU2
         u/8Wm3cwbwW0mNn+qKGQvNbBO57ZzMpj+1ZVHMkfxMRgVg+wd1ZXlbaMZjQehFJeS3+D
         I5DtiYpbRf9zi0jJ5YUu0jLfd6NTxO8SXl1KmcijblbJDQNv52x7jwD2KAQNYPIZX5ED
         9ThgeOsWuFoiKZpvcFu2LQm8oDNYWq/0s+1e6KxU9h+JPK2hW29GfO5mc8EA+4hoT0b3
         AMvw==
X-Google-Smtp-Source: APXvYqygCxVEH3ItByD6IxnaQ7ZdqZzlBm5rUdx0sPDioNv5BDwnqxGY49XVXyyMG+u6hN8qQpv1cl41iCU=
X-Received: by 2002:a63:b74b:: with SMTP id w11mr915185pgt.87.1554947039847;
 Wed, 10 Apr 2019 18:43:59 -0700 (PDT)
Date: Wed, 10 Apr 2019 18:43:51 -0700
Message-Id: <20190411014353.113252-1-surenb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [RFC 0/2] opportunistic memory reclaim of a killed process
From: Suren Baghdasaryan <surenb@google.com>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, rientjes@google.com, willy@infradead.org, 
	yuzhoujian@didichuxing.com, jrdr.linux@gmail.com, guro@fb.com, 
	hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, ebiederm@xmission.com, 
	shakeelb@google.com, christian@brauner.io, minchan@kernel.org, 
	timmurray@google.com, dancol@google.com, joel@joelfernandes.org, 
	jannh@google.com, surenb@google.com, linux-mm@kvack.org, 
	lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org, 
	kernel-team@android.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The time to kill a process and free its memory can be critical when the
killing was done to prevent memory shortages affecting system
responsiveness.

In the case of Android, where processes can be restarted easily, killing a
less important background process is preferred to delaying or throttling
an interactive foreground process. At the same time unnecessary kills
should be avoided as they cause delays when the killed process is needed
again. This requires a balanced decision from the system software about
how long a kill can be postponed in the hope that memory usage will
decrease without such drastic measures.

As killing a process and reclaiming its memory is not an instant operation,
a margin of free memory has to be maintained to prevent system performance
deterioration while memory of the killed process is being reclaimed. The
size of this margin depends on the minimum reclaim rate to cover the
worst-case scenario and this minimum rate should be deterministic.

Note that on asymmetric architectures like ARM big.LITTLE the reclaim rate
can vary dramatically depending on which core it=E2=80=99s performed at (se=
e test
results). It=E2=80=99s a usual scenario that a non-essential victim process=
 is
being restricted to a less performant or throttled CPU for power saving
purposes. This makes the worst-case reclaim rate scenario very probable.

The cases when victim=E2=80=99s memory reclaim can be delayed further due t=
o
process being blocked in an uninterruptible sleep or when it performs a
time-consuming operation makes the reclaim time even more unpredictable.

Increasing memory reclaim rate and making it more deterministic would
allow for a smaller free memory margin and would lead to more opportunities
to avoid killing a process.

Note that while other strategies like throttling memory allocations are
viable and can be employed for other non-essential processes they would
affect user experience if applied towards an interactive process.

Proposed solution uses existing oom-reaper thread to increase memory
reclaim rate of a killed process and to make this rate more deterministic.
By no means the proposed solution is considered the best and was chosen
because it was simple to implement and allowed for test data collection.
The downside of this solution is that it requires additional =E2=80=9Cexped=
ite=E2=80=9D
hint for something which has to be fast in all cases. Would be great to
find a way that does not require additional hints.

Other possible approaches include:
- Implementing a dedicated syscall to perform opportunistic reclaim in the
context of the process waiting for the victim=E2=80=99s death. A natural bo=
ost
bonus occurs if the waiting process has high or RT priority and is not
limited by cpuset cgroup in its CPU choices.
- Implement a mechanism that would perform opportunistic reclaim if it=E2=
=80=99s
possible unconditionally (similar to checks in task_will_free_mem()).
- Implement opportunistic reclaim that uses shrinker interface, PSI or
other memory pressure indications as a hint to engage.

Test details:
Tests are performed on a Qualcomm=C2=AE Snapdragon=E2=84=A2 845 8-core ARM =
big.LITTLE
system with 4 little cores (0.3-1.6GHz) and 4 big cores (0.8-2.5GHz)
running Android.
Memory reclaim speed was measured using signal/signal_generate,
kmem/rss_stat and sched/sched_process_exit traces.

Test results:
powersave governor, min freq
                        normal kills      expedited kills
        little          856 MB/sec        3236 MB/sec
        big             5084 MB/sec       6144 MB/sec

performance governor, max freq
                        normal kills      expedited kills
        little          5602 MB/sec       8144 MB/sec
        big             14656 MB/sec      12398 MB/sec

schedutil governor (default)
                        normal kills      expedited kills
        little          2386 MB/sec       3908 MB/sec
        big             7282 MB/sec       6820-16386 MB/sec
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
min reclaim speed:      856 MB/sec        3236 MB/sec

The patches are based on 5.1-rc1

Suren Baghdasaryan (2):
  mm: oom: expose expedite_reclaim to use oom_reaper outside of
    oom_kill.c
  signal: extend pidfd_send_signal() to allow expedited process killing

 include/linux/oom.h          |  1 +
 include/linux/sched/signal.h |  3 ++-
 include/linux/signal.h       | 11 ++++++++++-
 ipc/mqueue.c                 |  2 +-
 kernel/signal.c              | 37 ++++++++++++++++++++++++++++--------
 kernel/time/itimer.c         |  2 +-
 mm/oom_kill.c                | 15 +++++++++++++++
 7 files changed, 59 insertions(+), 12 deletions(-)

--=20
2.21.0.392.gf8f6787159e-goog

