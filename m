Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD6D6B02F3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 13:15:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 139so4298389wmf.5
        for <linux-mm@kvack.org>; Wed, 31 May 2017 10:15:01 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e32si14869771edd.66.2017.05.31.10.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 May 2017 10:15:00 -0700 (PDT)
Date: Wed, 31 May 2017 13:14:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/6] mm: memcontrol: per-lruvec stats infrastructure
Message-ID: <20170531171450.GA10481@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-6-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530181724.27197-6-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Andrew, the 0day tester found a crash with this when special pages get
faulted. They're not charged to any cgroup and we'll deref NULL.

Can you include the following fix on top of this patch please? Thanks!

---
