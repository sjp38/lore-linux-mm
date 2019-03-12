Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E40F5C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93CAF2077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h9UOI736"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93CAF2077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D16D8E0004; Tue, 12 Mar 2019 18:34:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 280558E0002; Tue, 12 Mar 2019 18:34:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 123258E0004; Tue, 12 Mar 2019 18:34:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C36038E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:34:09 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n10so4211266pgp.21
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:34:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=CG8VBs5njjsmOqTJucGpp1GQp/U3yTJMZSM/HvLW4gk=;
        b=r7V6funvJf9NVG8G7KBPdnobMDeIUh4xTV/8nHYZ9ejBMm+wWErMz3lE+CSv426S+4
         t7GcoUz4G3qgEOH50st/HHFF5+tvTHYYsee1AbfTdTqTyRuGkDLg3k1f/6bugQB9nIIX
         CSpe8pMbL/wHaFmrP81Swk0pVQuMCdFRHbLLqfm/xWLDBhR/LGbBeAhgMNKnyXcB/V82
         X/+2oj6fDwFyqX1bePEGlHP8Kci+UwGUuALI1WXDnDrhM6ryZjxR4Q/VHIKn151sqB8R
         2wF2Uz2qePium1mhjX5i+bxeJYUuAmrND4PqNcfKPftQnXxgf9rUNZtluEusmuWNJyA/
         nLog==
X-Gm-Message-State: APjAAAVSwvp+V/vXQDJIT7gbS5QLxhJ84ijel3iCpWeri0WAEnvPJFNV
	Q7ID80NPwg6tG5U1icYCA5/WT54U5NsFusETmMYMCBy6MvL3QhL06QRAsMPtjbc0LYhYQf9tLOA
	tGfJasULkBJR6f6KOxRzyPPJLgLndNDdeXQIE9TV+5sTyhEyWukVoXAYlVE0qj2fdZkoq9okNEV
	qD94YxQ7X9EuPga40/AG2M7q+wqVnfCERRayoiQj94MurovzSbVorghoC6u5iHcZO8s33lLG2GN
	LeVGE8Npmatc9J2ZshBmM/9zqsEh3bJOZzK0eNy5LW+HKKl2dzz7eRgpOJYhSfWTcwdSwQ9R8vO
	1HYllIGMLaHUXajztkuVQCZo3ETEwCKo0hao7Y5X/FXx9K95NwozGSIT9EBE5wQ1Y0EfsnMZpa/
	Y
X-Received: by 2002:a65:5c49:: with SMTP id v9mr139728pgr.150.1552430049438;
        Tue, 12 Mar 2019 15:34:09 -0700 (PDT)
X-Received: by 2002:a65:5c49:: with SMTP id v9mr139656pgr.150.1552430048218;
        Tue, 12 Mar 2019 15:34:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552430048; cv=none;
        d=google.com; s=arc-20160816;
        b=ufb8CwG9ODRaXdc+h15e3zbxFeJcTy8HgkD4AHI2+n2B4X9rtzjbNTPUddrbzl7Wug
         rA1XISRwUXRgiIft5aktP8oLPoSEH6tRoL7SQZfsP0PKfKIk05NjSW6+3fCj7nhtAfF0
         mCzHHbTpLA9b2PhgMwaRYMlny1RyOa7juOct7Jwa9eevFzOOOPSI7oL40kJebSdtCX4Z
         qp/icWRqKEYHpc5QTwZ5MxptfFy14o1eHMw7xBbPstK8nAK75Gqy64iv4BYVdsQA/eH2
         jUVNLi/rOEEnJy1KT7kozgzOoNIey06tOdvzzTL8C2XrEGSV13tDwOAdG0TE/VVPt44b
         yaMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=CG8VBs5njjsmOqTJucGpp1GQp/U3yTJMZSM/HvLW4gk=;
        b=W0sIN2xlkzzN9/qPlBwyxoO7IIwI91cYFqo4WY1fzQfvQBhnlRk/yRFXGRWzMGLb0a
         rtQf2/jTP52OaUOOX0G8MnHkc4Wr6Kqf+hTko80SP7a6zo3kNKlE/GT2jhweJYvqF4g2
         hmaMXa3CBfW6CRDL4h9S8NdjKOUaqHOAz2YfaTc1ImIdRUZk7x1NOAA89WNdfpu2oWOo
         jwHXSTEmp/E4dFcD/0S8wzd/KyOWXXc3+rE89FJiXtbzq9ZlQ5/Zh0XCGwUGmP+hZzo2
         mvC6st9jJAKyHMVV1/gO8R6vrUPtUCjrzqoErKCpXwxuKXtGxs51A3P+u22LGOmmDsAH
         i/Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h9UOI736;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ck3sor15566378plb.62.2019.03.12.15.34.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 15:34:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h9UOI736;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=CG8VBs5njjsmOqTJucGpp1GQp/U3yTJMZSM/HvLW4gk=;
        b=h9UOI736Jx8iXrIAW5OPQIbfTw5h4YbGzRbG/vYeMXWaWJOxBybprNrbv4O+Tu+XAp
         Xz5UJG4r2OR2oJwLhH/SYygF3nWcDR6f/K1FfVliZXnjYXNX0BiwDnugHX/7+U2Ooixz
         cUggfKM+93MVHidmn0HHx96nbtXCm+90bq//g8SAcGYa/sVorTsYEJvn4qQc6WqL4bpf
         pL6LqHWecY2HOTC5ASTMunxu/cveQxG03yRiGfEgZ2JNVLAVJnxnry4Fhi7aSUBjBJ3T
         DK6kiYcnApv2T3uDE55OilUSc3eR7GOQszr0gowGNe/ITjB3LPrB3gD5qbs1siRZGjMq
         /oCg==
X-Google-Smtp-Source: APXvYqy8tOPejVH25UDtkqcgofc+5QUcNdJIMGt8cfCJjTCXftBKArtxUyMWs1dIsenafkn68gXx8w==
X-Received: by 2002:a17:902:e713:: with SMTP id co19mr43680plb.102.1552430047540;
        Tue, 12 Mar 2019 15:34:07 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::1:3203])
        by smtp.gmail.com with ESMTPSA id i13sm14680592pfo.106.2019.03.12.15.34.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 15:34:06 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org,
	kernel-team@fb.com
Cc: linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH v2 0/6] mm: reduce the memory footprint of dying memory cgroups
Date: Tue, 12 Mar 2019 15:33:57 -0700
Message-Id: <20190312223404.28665-1-guro@fb.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A cgroup can remain in the dying state for a long time, being pinned in the
memory by any kernel object. It can be pinned by a page, shared with other
cgroup (e.g. mlocked by a process in the other cgroup). It can be pinned
by a vfs cache object, etc.

Mostly because of percpu data, the size of a memcg structure in the kernel
memory is quite large. Depending on the machine size and the kernel config,
it can easily reach hundreds of kilobytes per cgroup.

Depending on the memory pressure and the reclaim approach (which is a separate
topic), it looks like several hundreds (if not single thousands) of dying
cgroups is a typical number. On a moderately sized machine the overall memory
footprint is measured in hundreds of megabytes.

So if we can't completely get rid of dying cgroups, let's make them smaller.
This patchset aims to reduce the size of a dying memory cgroup by the premature
release of percpu data during the cgroup removal, and use of atomic counterparts
instead. Currently it covers per-memcg vmstat_percpu, per-memcg per-node
lruvec_stat_cpu. The same approach can be further applied to other percpu data.

Results on my test machine (32 CPUs, singe node):

  With the patchset:              Originally:

  nr_dying_descendants 0
  Slab:              66640 kB	  Slab:              67644 kB
  Percpu:             6912 kB	  Percpu:             6912 kB

  nr_dying_descendants 1000
  Slab:              85912 kB	  Slab:              84704 kB
  Percpu:            26880 kB	  Percpu:            64128 kB

So one dying cgroup went from 75 kB to 39 kB, which is almost twice smaller.
The difference will be even bigger on a bigger machine
(especially, with NUMA).

To test the patchset, I used the following script:
  CG=/sys/fs/cgroup/percpu_test/

  mkdir ${CG}
  echo "+memory" > ${CG}/cgroup.subtree_control

  cat ${CG}/cgroup.stat | grep nr_dying_descendants
  cat /proc/meminfo | grep -e Percpu -e Slab

  for i in `seq 1 1000`; do
      mkdir ${CG}/${i}
      echo $$ > ${CG}/${i}/cgroup.procs
      dd if=/dev/urandom of=/tmp/test-${i} count=1 2> /dev/null
      echo $$ > /sys/fs/cgroup/cgroup.procs
      rmdir ${CG}/${i}
  done

  cat /sys/fs/cgroup/cgroup.stat | grep nr_dying_descendants
  cat /proc/meminfo | grep -e Percpu -e Slab

  rmdir ${CG}


v2:
  - several renamings suggested by Johannes Weiner
  - added a patch, which merges cpu offlining and percpu flush code


Roman Gushchin (6):
  mm: prepare to premature release of memcg->vmstats_percpu
  mm: prepare to premature release of per-node lruvec_stat_cpu
  mm: release memcg percpu data prematurely
  mm: release per-node memcg percpu data prematurely
  mm: flush memcg percpu stats and events before releasing
  mm: refactor memcg_hotplug_cpu_dead() to use
    memcg_flush_offline_percpu()

 include/linux/memcontrol.h |  66 ++++++++++----
 mm/memcontrol.c            | 179 ++++++++++++++++++++++++++++---------
 2 files changed, 186 insertions(+), 59 deletions(-)

-- 
2.20.1

