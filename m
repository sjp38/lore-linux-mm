Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59297828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 18:32:08 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id x68so71737112ioi.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 15:32:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 2si42495333pfh.24.2016.06.21.15.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 15:32:07 -0700 (PDT)
Date: Tue, 21 Jun 2016 15:32:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 16/27] mm: Move page mapped accounting to the node
Message-Id: <20160621153206.2d72954b22dddee7f1d8b9a5@linux-foundation.org>
In-Reply-To: <1466518566-30034-17-git-send-email-mgorman@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
	<1466518566-30034-17-git-send-email-mgorman@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 21 Jun 2016 15:15:55 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> Reclaim makes decisions based on the number of pages that are mapped
> but it's mixing node and zone information. Account NR_FILE_MAPPED and
> NR_ANON_PAGES pages on the node.

<wading through rejects>

Boy, the difference between

	__mod_zone_page_state(page_zone(page), ...

and

	__mod_node_page_state(page_pgdat(page), ...

is looking subtle.  When and why to use one versus the other.  I'm not
seeing any explanation of this in there but haven't yet looked hard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
