Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 121246B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 10:09:43 -0400 (EDT)
Date: Wed, 14 Mar 2012 09:09:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: fix vmstat_update to keep scheduling itself on all
 cores
In-Reply-To: <CAOtvUMdVrjUHLx2jZ2xbpBoDBMCX8sdCASEkmXCtBrU-gQ3EhQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1203140908010.5485@router.home>
References: <CAOtvUMdVrjUHLx2jZ2xbpBoDBMCX8sdCASEkmXCtBrU-gQ3EhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@linux.intel.com>, Linux-MM <linux-mm@kvack.org>

On Wed, 14 Mar 2012, Gilad Ben-Yossef wrote:

> We set up per-cpu work structures for vmstat and schedule them on
> each cpu when they go online only to re-schedule them on the general
> work queue when they first run.

schedule_delayed_work queues on the current cpu unless the
WQ_UNBOUND flag is set. Which is not set for vmstat_work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
