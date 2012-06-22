Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 51E8D6B0259
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 16:19:03 -0400 (EDT)
Date: Fri, 22 Jun 2012 13:19:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: clear pages_scanned only if draining a pcp adds
 pages to the buddy allocator again
Message-Id: <20120622131901.28f273e3.akpm@linux-foundation.org>
In-Reply-To: <1339690570-7471-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1339690570-7471-1-git-send-email-kosaki.motohiro@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Thu, 14 Jun 2012 12:16:10 -0400
kosaki.motohiro@gmail.com wrote:

> commit 2ff754fa8f (mm: clear pages_scanned only if draining a pcp adds pages
> to the buddy allocator again) fixed one free_pcppages_bulk() misuse. But two
> another miuse still exist.

This changelog is irritating.  One can understand it a bit if one
happens to have a git repo handy (and why do this to the reader?), but
the changelog for 2ff754fa8f indicates that the patch might fix a
livelock.  Is that true of this patch?  Who knows...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
