Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C19C96B0274
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:48:57 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d25-v6so10697792qtp.10
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:48:57 -0700 (PDT)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id r6-v6si6324156qvb.185.2018.07.30.08.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Jul 2018 08:48:57 -0700 (PDT)
Date: Mon, 30 Jul 2018 15:48:56 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3 7/7] mm, slab: shorten kmalloc cache names for large
 sizes
In-Reply-To: <20180718133620.6205-8-vbabka@suse.cz>
Message-ID: <01000164ebe0d06f-8f639717-8d32-4eb9-9cc1-708332b12ca6-000000@email.amazonses.com>
References: <20180718133620.6205-1-vbabka@suse.cz> <20180718133620.6205-8-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On Wed, 18 Jul 2018, Vlastimil Babka wrote:

> +static const char *
> +kmalloc_cache_name(const char *prefix, unsigned int size)
> +{
> +
> +	static const char units[3] = "\0kM";
> +	int idx = 0;
> +
> +	while (size >= 1024 && (size % 1024 == 0)) {
> +		size /= 1024;
> +		idx++;
> +	}
> +
> +	return kasprintf(GFP_NOWAIT, "%s-%u%c", prefix, size, units[idx]);
> +}

This is likely to occur elsewhere in the kernel. Maybe generalize it a
bit?

Acked-by: Christoph Lameter <cl@linux.com>
