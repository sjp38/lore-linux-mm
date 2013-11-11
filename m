Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0CBD16B018E
	for <linux-mm@kvack.org>; Sun, 10 Nov 2013 19:23:03 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so4552003pab.26
        for <linux-mm@kvack.org>; Sun, 10 Nov 2013 16:23:03 -0800 (PST)
Received: from psmtp.com ([74.125.245.111])
        by mx.google.com with SMTP id dl5si14017792pbd.56.2013.11.10.16.23.01
        for <linux-mm@kvack.org>;
        Sun, 10 Nov 2013 16:23:02 -0800 (PST)
Message-ID: <52802361.5040601@redhat.com>
Date: Sun, 10 Nov 2013 19:22:57 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: numa: Return the number of base pages altered by
 protection changes
References: <20131109143718.GC5040@suse.de>
In-Reply-To: <20131109143718.GC5040@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/09/2013 09:37 AM, Mel Gorman wrote:
> Commit 0255d491 (mm: Account for a THP NUMA hinting update as one PTE
> update) was added to account for the number of PTE updates when marking
> pages prot_numa. task_numa_work was using the old return value to track
> how much address space had been updated. Altering the return value causes
> the scanner to do more work than it is configured or documented to in a
> single unit of work.
> 
> This patch reverts 0255d491 and accounts for the number of THP updates
> separately in vmstat. It is up to the administrator to interpret the pair
> of values correctly. This is a straight-forward operation and likely to
> only be of interest when actively debugging NUMA balancing problems.
> 
> The impact of this patch is that the NUMA PTE scanner will scan slower when
> THP is enabled and workloads may converge slower as a result. On the flip
> size system CPU usage should be lower than recent tests reported. This is
> an illustrative example of a short single JVM specjbb test

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
