Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC3A38E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:52:04 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e89so5675949pfb.17
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:52:04 -0800 (PST)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id i1si1589029pgi.480.2019.01.16.13.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 13:52:03 -0800 (PST)
Date: Wed, 16 Jan 2019 14:52:01 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] doc: memcontrol: fix the obsolete content about force
 empty
Message-ID: <20190116145201.3000520b@lwn.net>
In-Reply-To: <1547596295-14085-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1547596295-14085-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, shakeelb@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 16 Jan 2019 07:51:35 +0800
Yang Shi <yang.shi@linux.alibaba.com> wrote:

> We don't do page cache reparent anymore when offlining memcg, so update
> force empty related content accordingly.
> 
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  Documentation/cgroup-v1/memory.txt | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)

Applied, thanks.

jon
