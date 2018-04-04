Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3C4D6B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 10:12:36 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p4so11244929wrf.17
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 07:12:36 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e7si4220074edi.410.2018.04.04.07.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Apr 2018 07:12:35 -0700 (PDT)
Date: Wed, 4 Apr 2018 10:13:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm: memcontrol: Remove lruvec_stat
Message-ID: <20180404141355.GB28966@cmpxchg.org>
References: <20180324160901.512135-1-tj@kernel.org>
 <20180324160901.512135-4-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180324160901.512135-4-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: mhocko@kernel.org, vdavydov.dev@gmail.com, guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org, Josef Bacik <josef@toxicpanda.com>

On Sat, Mar 24, 2018 at 09:09:01AM -0700, Tejun Heo wrote:
> lruvec_stat doesn't have any consumer.  Remove it.

This tracks counters at the node-memcg intersection, which is a
requirement for Josef's shrinker rework.

I don't know what happened to that patch series. Josef, Andrew?
