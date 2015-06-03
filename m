Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id DAF0C900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 22:39:06 -0400 (EDT)
Received: by padj3 with SMTP id j3so80168177pad.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 19:39:06 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id yf4si24905476pbc.185.2015.06.02.19.39.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 19:39:05 -0700 (PDT)
Received: by payr10 with SMTP id r10so63359514pay.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 19:39:05 -0700 (PDT)
Date: Wed, 3 Jun 2015 11:38:59 +0900
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH -mm 2/2] memcg: convert mem_cgroup->under_oom from atomic_t
 to int
Message-ID: <20150603023859.GB7579@mtj.duckdns.org>
References: <20150603023824.GA7579@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150603023824.GA7579@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

