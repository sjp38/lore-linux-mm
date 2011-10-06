Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 06FAF6B002D
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 17:54:49 -0400 (EDT)
Received: by pzk4 with SMTP id 4so8675954pzk.6
        for <linux-mm@kvack.org>; Thu, 06 Oct 2011 14:54:47 -0700 (PDT)
Date: Thu, 6 Oct 2011 14:54:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] Fix compaction about mlocked pages
Message-Id: <20111006145445.ed8d6dbb.akpm@linux-foundation.org>
In-Reply-To: <cover.1321112552.git.minchan.kim@gmail.com>
References: <cover.1321112552.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>

On Sun, 13 Nov 2011 01:37:40 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> This patch's goal is to enable mlocked page migration.
> The compaction can migrate mlocked page to get a contiguous memory unlike lumpy.
> 

This patch series appears to be a resend of stuff I already have.

Given the various concerns which were voiced during review of
mm-compaction-compact-unevictable-pages.patch and the uncertainty of
the overall usefulness of the feature, I'm inclined to drop

mm-compaction-compact-unevictable-pages.patch
mm-compaction-compact-unevictable-pages-checkpatch-fixes.patch
mm-compaction-accounting-fix.patch

for now, OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
