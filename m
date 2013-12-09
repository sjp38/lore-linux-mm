Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 789366B00B6
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:10:42 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id k14so3664348wgh.22
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:10:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id wa3si4879421wjc.149.2013.12.09.08.10.41
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 08:10:41 -0800 (PST)
Message-ID: <52A5EB7B.503@redhat.com>
Date: Mon, 09 Dec 2013 11:10:35 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/18] mm: numa: Avoid unnecessary disruption of NUMA
 hinting during migration
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-11-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:
> do_huge_pmd_numa_page() handles the case where there is parallel THP
> migration.  However, by the time it is checked the NUMA hinting information
> has already been disrupted. This patch adds an earlier check with some helpers.
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
