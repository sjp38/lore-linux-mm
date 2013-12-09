Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2596B00A8
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 09:50:20 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id w61so3574054wes.14
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 06:50:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id mv9si4481434wic.0.2013.12.09.06.50.19
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 06:50:19 -0800 (PST)
Message-ID: <52A5D8A2.1030807@redhat.com>
Date: Mon, 09 Dec 2013 09:50:10 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/18] sched: numa: Skip inaccessible VMAs
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-9-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:
> Inaccessible VMA should not be trapping NUMA hint faults. Skip them.
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
