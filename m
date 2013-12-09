Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id A963D6B00C9
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:47:21 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id hn9so4083730wib.6
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:47:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t9si1072035wif.6.2013.12.09.08.47.20
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 08:47:20 -0800 (PST)
Message-ID: <52A5F40F.40206@redhat.com>
Date: Mon, 09 Dec 2013 11:47:11 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/18] mm: numa: Limit scope of lock for NUMA migrate
 rate limiting
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-15-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:
> NUMA migrate rate limiting protects a migration counter and window using
> a lock but in some cases this can be a contended lock. It is not
> critical that the number of pages be perfect, lost updates are
> acceptable. Reduce the importance of this lock.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
