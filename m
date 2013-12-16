Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id 31A186B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 15:52:44 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id w11so2535345bkz.29
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 12:52:43 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id lu3si4467517bkb.302.2013.12.16.12.52.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 12:52:43 -0800 (PST)
Date: Mon, 16 Dec 2013 15:52:37 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] mm: page_alloc: Only account batch allocations
 requests that are eligible
Message-ID: <20131216205237.GB21724@cmpxchg.org>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-7-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386943807-29601-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 13, 2013 at 02:10:06PM +0000, Mel Gorman wrote:
> Not signed off. Johannes, was the intent really to decrement the batch
> counts regardless of whether the policy was being enforced or not?

Yes.  Bursts of allocations for which the policy does not get enforced
will still create memory pressure and affect cache aging on a given
node.  So even if we only distribute page cache, we want to distribute
it in a way that all allocations on the eligible zones equal out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
