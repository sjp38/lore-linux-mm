Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CFB976B0047
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 02:21:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2J6LRE0031154
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 19 Mar 2010 15:21:27 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E44D45DE4D
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D36CB45DE52
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C8B55EF8006
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:24 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 79FB3E38003
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 04/11] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA or memory hot-remove
In-Reply-To: <20100318112414.GL12388@csn.ul.ie>
References: <20100318085226.8726.A69D9226@jp.fujitsu.com> <20100318112414.GL12388@csn.ul.ie>
Message-Id: <20100319152106.8775.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 19 Mar 2010 15:21:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, Mar 18, 2010 at 08:56:23AM +0900, KOSAKI Motohiro wrote:
> > > On Wed, 17 Mar 2010, Mel Gorman wrote:
> > > 
> > > > > If select MIGRATION works, we can remove "depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE"
> > > > > line from config MIGRATION.
> > > > >
> > > >
> > > > I'm not quite getting why this would be an advantage. COMPACTION
> > > > requires MIGRATION but conceivable both NUMA and HOTREMOVE can work
> > > > without it.
> > > 
> > > Avoids having to add additional CONFIG_XXX on the page migration "depends"
> > > line in the future.
> > 
> > Yes, Kconfig mess freqently shot ourself in past days. if we have a chance
> > to remove unnecessary dependency, we should do. that's my intention of the last mail.
> > 
> 
> But if the depends line is removed, it could be set without NUMA, memory
> hot-remove or compaction enabled. That wouldn't be very useful. I'm
> missing something obvious.

Perhaps I'm missing something. 

my point is, force enabling useless config is not good idea (yes, i agree). but config 
selectability doesn't cause any failure. IOW, usefulness and dependency aren't 
related so much. personally I dislike _unnecessary_ dependency.

If my opinion cause any bad thing, I'll withdraw it. of course.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
