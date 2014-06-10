Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 23F526B00CC
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 20:00:26 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so3238528iec.17
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 17:00:26 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id nm6si20713006igb.37.2014.06.09.17.00.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 17:00:25 -0700 (PDT)
Received: by mail-ig0-f179.google.com with SMTP id r2so2553319igi.12
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 17:00:25 -0700 (PDT)
Date: Mon, 9 Jun 2014 17:00:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04/10] mm, compaction: skip rechecks when lock was already
 held
In-Reply-To: <1402305982-6928-4-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.02.1406091700100.17705@chino.kir.corp.google.com>
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Mon, 9 Jun 2014, Vlastimil Babka wrote:

> Compaction scanners try to lock zone locks as late as possible by checking
> many page or pageblock properties opportunistically without lock and skipping
> them if not unsuitable. For pages that pass the initial checks, some properties
> have to be checked again safely under lock. However, if the lock was already
> held from a previous iteration in the initial checks, the rechecks are
> unnecessary.
> 
> This patch therefore skips the rechecks when the lock was already held. This is
> now possible to do, since we don't (potentially) drop and reacquire the lock
> between the initial checks and the safe rechecks anymore.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
