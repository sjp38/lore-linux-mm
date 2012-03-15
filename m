Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id A8B366B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 14:08:16 -0400 (EDT)
Date: Thu, 15 Mar 2012 19:08:04 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: thp: fix pmd_bad() triggering in code paths holding
 mmap_sem read mode
Message-ID: <20120315180804.GB1841@cmpxchg.org>
References: <1331822671-21508-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331822671-21508-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>

On Thu, Mar 15, 2012 at 03:44:31PM +0100, Andrea Arcangeli wrote:
> Reported-by: Ulrich Obergfell <uobergfe@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
