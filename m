Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 146DF6B026B
	for <linux-mm@kvack.org>; Mon,  7 May 2018 10:46:46 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q67-v6so6836328wrb.12
        for <linux-mm@kvack.org>; Mon, 07 May 2018 07:46:46 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g23-v6si1594776edg.322.2018.05.07.07.46.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 May 2018 07:46:45 -0700 (PDT)
Date: Mon, 7 May 2018 10:48:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: drain stocks on resize limit
Message-ID: <20180507144835.GA5163@cmpxchg.org>
References: <20180504205548.110696-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180504205548.110696-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, May 04, 2018 at 01:55:48PM -0700, Shakeel Butt wrote:
> Resizing the memcg limit for cgroup-v2 drains the stocks before
> triggering the memcg reclaim. Do the same for cgroup-v1 to make the
> behavior consistent.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
