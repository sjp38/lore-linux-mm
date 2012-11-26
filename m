Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 2B6E16B0062
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 08:05:05 -0500 (EST)
Date: 26 Nov 2012 08:05:04 -0500
Message-ID: <20121126130504.29434.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
In-Reply-To: <20121126100102.GH8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, mgorman@suse.de
Cc: dave@linux.vnet.ibm.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com

Mel Gorman <mgorman@suse.de> wrote:
> Ok, can you try this patch from Rik on top as well please? This is in
> addition to Dave Hansen's accounting fix.
> 
> ---8<---
> From: Rik van Riel <riel@redhat.com>
> Subject: mm,vmscan: only loop back if compaction would fail in all zones

Booted and running.  Judging from the patch, the expected result is
"stops hanging", as opposed to more informative diagnostics, so I'll
keep you posted.

Peraonally, I like to use "bool" for such flags where possible;
it helps document the intent of the variable better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
