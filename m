Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 731A49003C7
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 11:15:29 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so249308977wib.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 08:15:29 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kb7si2374465wjc.205.2015.07.30.08.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 08:15:28 -0700 (PDT)
Date: Thu, 30 Jul 2015 11:14:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC v2 1/4] mm: make alloc_pages_exact_node pass __GFP_THISNODE
Message-ID: <20150730151448.GA14488@cmpxchg.org>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
 <20150729133043.GE19352@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150729133043.GE19352@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Wed, Jul 29, 2015 at 02:30:43PM +0100, Mel Gorman wrote:
> The change of what we have now is a good idea. What you have is a solid
> improvement in my view but I see there are a few different suggestions
> in the thread. Based on that I think it makes sense to just destroy
> alloc_pages_exact_node. In the future "exact" in the allocator API will
> mean "exactly this number of pages". Use your __alloc_pages_node helper
> and specify __GFP_THISNODE if the caller requires that specific node.

+1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
