Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 751E06B025F
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:41:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s63so37739335wme.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:41:39 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id o203si4080987wmd.121.2016.04.27.05.41.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 05:41:38 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 0A59D98998
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 12:41:38 +0000 (UTC)
Date: Wed, 27 Apr 2016 13:41:36 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/3] mm, page_alloc: pull out side effects from
 free_pages_check
Message-ID: <20160427124136.GJ2858@techsingularity.net>
References: <5720A987.7060507@suse.cz>
 <1461758476-450-1-git-send-email-vbabka@suse.cz>
 <1461758476-450-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1461758476-450-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Apr 27, 2016 at 02:01:15PM +0200, Vlastimil Babka wrote:
> Check without side-effects should be easier to maintain. It also removes the
> duplicated cpupid and flags reset done in !DEBUG_VM variant of both
> free_pcp_prepare() and then bulkfree_pcp_prepare(). Finally, it enables
> the next patch.
> 

Hmm, now the cpuid and flags reset is done in multiple places. While
this is potentially faster, it goes against the comment "I don't like the
duplicated code in free_pcp_prepare() from maintenance perspective".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
