Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id C85036B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 10:45:47 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so113477146igb.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 07:45:47 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id m9si4343308igx.65.2015.08.12.07.45.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 12 Aug 2015 07:45:46 -0700 (PDT)
Date: Wed, 12 Aug 2015 09:45:45 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 05/10] mm, page_alloc: Use masks and shifts when converting
 GFP flags to migrate types
In-Reply-To: <1439376335-17895-6-git-send-email-mgorman@techsingularity.net>
Message-ID: <alpine.DEB.2.11.1508120944450.18762@east.gentwo.org>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net> <1439376335-17895-6-git-send-email-mgorman@techsingularity.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 12 Aug 2015, Mel Gorman wrote:

> @@ -149,14 +150,15 @@ struct vm_area_struct;
>  /* Convert GFP flags to their corresponding migrate type */
>  static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
>  {
> -	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
> +	VM_WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
> +	BUILD_BUG_ON(1UL << GFP_MOVABLE_SHIFT != ___GFP_MOVABLE);
> +	BUILD_BUG_ON(___GFP_MOVABLE >> GFP_MOVABLE_SHIFT != MIGRATE_MOVABLE);

Add some parenthesis here. Difficult to read. Compiler takes this as is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
