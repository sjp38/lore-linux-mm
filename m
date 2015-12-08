Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A50BC6B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 04:45:52 -0500 (EST)
Received: by wmvv187 with SMTP id v187so205314047wmv.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 01:45:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uq9si3312237wjc.17.2015.12.08.01.45.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 01:45:51 -0800 (PST)
Date: Tue, 8 Dec 2015 09:45:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/compaction: restore COMPACT_CLUSTER_MAX to 32
Message-ID: <20151208094546.GD19677@suse.de>
References: <1449115900-20112-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20151207170041.c470d362915ae1b42a8a4ef8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20151207170041.c470d362915ae1b42a8a4ef8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Dec 07, 2015 at 05:00:41PM -0800, Andrew Morton wrote:
> On Thu,  3 Dec 2015 13:11:40 +0900 Joonsoo Kim <js1304@gmail.com> wrote:
> 
> > Until now, COMPACT_CLUSTER_MAX is defined as SWAP_CLUSTER_MAX.
> > Commit ("mm: increase SWAP_CLUSTER_MAX to batch TLB flushes")
> > changes SWAP_CLUSTER_MAX from 32 to 256 to improve tlb flush performance
> > so COMPACT_CLUSTER_MAX is also changed to 256.
> 
> "mm: increase SWAP_CLUSTER_MAX to batch TLB flushes" has been in limbo
> for quite a while.  Because it has been unclear whether the patch's
> benefits exceed its costs+risks.
> 
> We should make a decision here - either do the appropriate testing or
> drop the patch.
> 

At this point, drop it. The benefits that apply to some corner cases are
marginal but the concerns about potentially isolating and reclaiming too
much persist.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
