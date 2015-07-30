Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 462826B0259
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:34:10 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so25179551qge.3
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 07:34:10 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id h52si1387258qgf.43.2015.07.30.07.34.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 07:34:09 -0700 (PDT)
Date: Thu, 30 Jul 2015 09:33:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC v2 1/4] mm: make alloc_pages_exact_node pass
 __GFP_THISNODE
In-Reply-To: <20150729133043.GE19352@techsingularity.net>
Message-ID: <alpine.DEB.2.11.1507300933170.4143@east.gentwo.org>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz> <20150729133043.GE19352@techsingularity.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Wed, 29 Jul 2015, Mel Gorman wrote:

> The change of what we have now is a good idea. What you have is a solid
> improvement in my view but I see there are a few different suggestions
> in the thread. Based on that I think it makes sense to just destroy
> alloc_pages_exact_node. In the future "exact" in the allocator API will
> mean "exactly this number of pages". Use your __alloc_pages_node helper
> and specify __GFP_THISNODE if the caller requires that specific node.

Yes please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
