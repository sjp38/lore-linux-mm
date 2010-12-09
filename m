Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 23A476B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 03:55:13 -0500 (EST)
Received: by gyg10 with SMTP id 10so1277869gyg.14
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 00:55:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101208172324.d45911f4.akpm@linux-foundation.org>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
	<20101209003621.GB3796@hostway.ca>
	<20101208172324.d45911f4.akpm@linux-foundation.org>
Date: Thu, 9 Dec 2010 10:55:10 +0200
Message-ID: <AANLkTi=3WFrrhbrRUi986KCaMknUeXGsb8Lq6O8K4RMd@mail.gmail.com>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Kirby <sim@hostway.ca>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 9, 2010 at 3:23 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> This problem would have got worse when slub came along doing its stupid
> unnecessary high-order allocations.

Stupid, maybe but not unnecessary because they're a performance
improvement on large CPU systems (needed because of current SLUB
design). We're scaling the allocation order based on number of CPUs
but maybe we could shrink it even more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
