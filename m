Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82D1F6B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:37:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so37547606wme.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:37:54 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id w81si30556824wme.1.2016.04.27.05.37.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 05:37:53 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 4202D1C134C
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:37:53 +0100 (IST)
Date: Wed, 27 Apr 2016 13:37:51 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/3] mm, page_alloc: un-inline the bad part of
 free_pages_check
Message-ID: <20160427123751.GI2858@techsingularity.net>
References: <5720A987.7060507@suse.cz>
 <1461758476-450-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1461758476-450-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Apr 27, 2016 at 02:01:14PM +0200, Vlastimil Babka wrote:
> !DEBUG_VM bloat-o-meter:
> 
> add/remove: 1/0 grow/shrink: 0/2 up/down: 124/-383 (-259)
> function                                     old     new   delta
> free_pages_check_bad                           -     124    +124
> free_pcppages_bulk                          1509    1403    -106
> __free_pages_ok                             1025     748    -277
> 
> DEBUG_VM:
> 
> add/remove: 1/0 grow/shrink: 0/1 up/down: 124/-242 (-118)
> function                                     old     new   delta
> free_pages_check_bad                           -     124    +124
> free_pages_prepare                          1048     806    -242
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

This uninlines the check all right but it also introduces new function
calls into the free path. As it's the free fast path, I suspect it would
be a step in the wrong direction from a performance perspective.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
