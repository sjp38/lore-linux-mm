Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9E9B6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:30:12 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y84so35578721lfc.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:30:12 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id 71si5851097wmo.92.2016.04.27.05.30.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 05:30:11 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 75BCC987F0
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 12:30:11 +0000 (UTC)
Date: Wed, 27 Apr 2016 13:30:09 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/4] mm, page_alloc: inline the fast path of the zonelist
 iterator -fix
Message-ID: <20160427123009.GH2858@techsingularity.net>
References: <1461759885-17163-1-git-send-email-mgorman@techsingularity.net>
 <1461759885-17163-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1461759885-17163-3-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 27, 2016 at 01:24:43PM +0100, Mel Gorman wrote:
> Vlastimil Babka pointed out that the nodes allowed by a cpuset are not
> reread if the nodemask changes during an allocation. This potentially
> allows an unnecessary page allocation failure. Moving the retry_cpuset
> label is insufficient but rereading the nodemask before retrying addresses
> the problem.
> 
> This is a fix to the mmotm patch
> mm-page_alloc-inline-the-fast-path-of-the-zonelist-iterator.patch .
> 
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

And this is wrong :( . I'll think again.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
