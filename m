Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9231D900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 22:38:30 -0400 (EDT)
Received: by padj3 with SMTP id j3so80158402pad.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 19:38:30 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id a13si28880196pbu.153.2015.06.02.19.38.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 19:38:29 -0700 (PDT)
Received: by pdjm12 with SMTP id m12so63157502pdj.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 19:38:29 -0700 (PDT)
Date: Wed, 3 Jun 2015 11:38:24 +0900
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH -mm 1/2] memcg: remove unused mem_cgroup->oom_wakeups
Message-ID: <20150603023824.GA7579@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

