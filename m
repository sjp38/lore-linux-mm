Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A43DA6B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 13:16:36 -0400 (EDT)
Date: Thu, 15 Mar 2012 13:16:28 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] mm: thp: fix pmd_bad() triggering in code paths holding
 mmap_sem read mode
Message-ID: <20120315171627.GB22255@redhat.com>
References: <1331822671-21508-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331822671-21508-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>

On Thu, Mar 15, 2012 at 03:44:31PM +0100, Andrea Arcangeli wrote:

 > At some point prior to the panic, a "bad pmd ..." message similar to the
 > following is logged on the console:
 > 
 >   mm/memory.c:145: bad pmd ffff8800376e1f98(80000000314000e7).

Hmm, I wonder if this could explain some of the many bad page state bug
reports we've seen in Fedora recently.  (See my recent mail to linux-mm)

 > Reported-by: Ulrich Obergfell <uobergfe@redhat.com>
 > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Should probably go to stable too ? How far back does this bug go ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
