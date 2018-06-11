Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E86DC6B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:54:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w21-v6so4964288wmc.4
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:54:57 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y95-v6si3837492ede.17.2018.06.11.10.54.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 10:54:56 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v2 0/3] memory.min fixes/refinements
Date: Mon, 11 Jun 2018 10:54:15 -0700
Message-ID: <20180611175418.7007-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

Hi, Andrew!

Please, find an updated version of memory.min refinements/fixes
in this patchset. It's against linus tree.
Please, merge these patches into 4.18.

Thanks!

Roman Gushchin (3):
  mm: fix null pointer dereference in mem_cgroup_protected
  mm, memcg: propagate memory effective protection on setting
    memory.min/low
  mm, memcg: don't skip memory guarantee calculations

 mm/memcontrol.c | 33 ++++++++++++++++++++++++---------
 1 file changed, 24 insertions(+), 9 deletions(-)

-- 
2.14.4
