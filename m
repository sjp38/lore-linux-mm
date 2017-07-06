Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id A576B6B02FA
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 11:02:39 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id m22so3512228ywh.7
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 08:02:39 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id x7si64702ywa.187.2017.07.06.08.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 08:02:38 -0700 (PDT)
Date: Thu, 6 Jul 2017 10:02:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: make allocation counters per-order
In-Reply-To: <1499346271-15653-1-git-send-email-guro@fb.com>
Message-ID: <alpine.DEB.2.20.1707060958010.24679@east.gentwo.org>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Thu, 6 Jul 2017, Roman Gushchin wrote:

> +#define PGALLOC_EVENTS_SIZE (MAX_NR_ZONES * MAX_ORDER)
> +#define PGALLOC_EVENTS_CUT_SIZE (MAX_NR_ZONES * (MAX_ORDER - 1))
> +#define PGALLOC_FIRST_ZONE (PGALLOC_NORMAL - ZONE_NORMAL)


You are significantly increasing the per cpu counters (ZONES *
MAX_ORDER * cpus!!!). This will increase the cache footprint of critical
functions significantly and thus lead to regressions.

Typically counters for zones are placed in the zone structures but
you would also significantly increase the per zone counters ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
