Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 220A56B00A7
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:41:35 -0400 (EDT)
Date: Tue, 19 Oct 2010 09:41:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [resend][PATCH 2/2] mm, mem-hotplug: update pcp->stat_threshold
 when memory hotplug occur
In-Reply-To: <20101019140955.A1EE.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010190941160.29434@router.home>
References: <20101019140831.A1EB.A69D9226@jp.fujitsu.com> <20101019140955.A1EE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 19 Oct 2010, KOSAKI Motohiro wrote:

> Currently, cpu hotplug updates pcp->stat_threashold, but memory
> hotplug doesn't. there is no reason.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
