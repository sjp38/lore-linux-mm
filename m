Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 947E36B00B2
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 10:57:53 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id q58so3624348wes.19
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 07:57:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id pc6si4850943wjb.130.2013.12.09.07.57.52
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 07:57:52 -0800 (PST)
Message-ID: <52A5E87B.9080209@redhat.com>
Date: Mon, 09 Dec 2013 10:57:47 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/18] mm: numa: Clear numa hinting information on mprotect
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-10-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:
> On a protection change it is no longer clear if the page should be still
> accessible.  This patch clears the NUMA hinting fault bits on a protection
> change.

I had to think about this one, because my first thought was
"wait, aren't NUMA ptes inaccessible already?".

Then I thought about doing things like adding read or write
permission in the mprotect, eg. changing from PROT_NONE to
PROT_READ ... and it became unclear what to do with the NUMA
bit in that case...

This patch clears up some confusing situations :)

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
