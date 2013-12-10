Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0DAC06B0036
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 11:56:13 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so2374914eae.33
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 08:56:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id i1si15124229eev.152.2013.12.10.08.56.12
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 08:56:13 -0800 (PST)
Message-ID: <52A747A8.9030307@redhat.com>
Date: Tue, 10 Dec 2013 11:56:08 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/18] mm: numa: Defer TLB flush for THP migration as
 long as possible
References: <1386690695-27380-1-git-send-email-mgorman@suse.de> <1386690695-27380-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-13-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/10/2013 10:51 AM, Mel Gorman wrote:
> THP migration can fail for a variety of reasons. Avoid flushing the TLB
> to deal with THP migration races until the copy is ready to start.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
