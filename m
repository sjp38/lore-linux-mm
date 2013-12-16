Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 92AEA6B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 10:20:18 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so2306637eae.19
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:20:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e48si750009eeh.92.2013.12.16.07.20.17
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 07:20:17 -0800 (PST)
Message-ID: <52AF1A22.1070708@redhat.com>
Date: Mon, 16 Dec 2013 10:20:02 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/7] mm: Annotate page cache allocations
References: <1386943807-29601-1-git-send-email-mgorman@suse.de> <1386943807-29601-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1386943807-29601-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/13/2013 09:10 AM, Mel Gorman wrote:
> Annotations will be used for fair zone allocation policy. Patch is mostly
> taken from a link posted by Johannes on IRC. It's not perfect because all
> callers of these paths are not guaranteed to be allocating pages for page
> cache. However, it's probably close enough to cover all cases that matter
> with minimal distortion.
> 
> Not-signed-off

Whenever you and Johannes sign it off, you can add my

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
